﻿
CREATE PROCEDURE [dbo].[SP_MOVE_TABLES]  
@SourceFileGroupID int,
@TargetFileGroupID int,
@TableToMove NVARCHAR(128),
@MovePKAndAllUniqueConstraints bit,
@MoveAllNonClusteredIndexes bit

AS
/*
Modifed By: Boris Schubert 2015-01-21
I believe Roberto Stefanetti - MCM NAV created this stored procedure. https://gallery.technet.microsoft.com/scriptcenter/c1da9334-2885-468c-a374-775da60f256f

This modification corrects the stored procedure to preserve indexes with INCLUDE (non index keys). Original stored procedure had some issues on that.
Details:
-------
Before Executing the Stored Procedure:    
Index Definition --> create index idxtest on t1_emp(eno) include (city,ssn)
(table was on File Group: Primary)

After Executing the Stored Procedure:    
Index Definition --> create index idxtest on t1_emp(city, ssn, eno)
(table correctly placed on File Group: FG1 )
-------

Status: Fixed

*/
SET NOCOUNT ON
DECLARE @ScriptMsg NVARCHAR(512)
DECLARE @DatabaseName sysname
DECLARE @ServerName sysname
DECLARE @TableHasCI BIT
DECLARE @TableHasIdent BIT
DECLARE @TableHasPK BIT
DECLARE @TableHasUQ BIT
DECLARE @File1Name NVARCHAR(128)
DECLARE @File2Name NVARCHAR(128)
DECLARE @IdentColName NVARCHAR(128)
DECLARE @ColList NVARCHAR(1024)
DECLARE @IncludeColumnList NVARCHAR(1024)
DECLARE @IncludeColExists BIT
DECLARE @Keyno INT
DECLARE @indid NVARCHAR(128)
DECLARE @Type CHAR(2)
DECLARE @KeyName NVARCHAR(128)
DECLARE @AssocFKeyName NVARCHAR(128)
DECLARE @FKTableName NVARCHAR(128)
DECLARE @CIName NVARCHAR(128)
DECLARE @IsPadIndex BIT
DECLARE @i INT
DECLARE @J INT
DECLARE @SQLStr NVARCHAR(4000)

-- This temp table holds the column names of keys/constraints, and such.
IF OBJECT_ID('tempdb..#tblColTable', 'U') IS NOT NULL
        DROP TABLE #tblColTable

CREATE TABLE #tblColTable (
        Idx INT IDENTITY(1, 1),
        ColName NVARCHAR(128),
        IdxOrder CHAR(4),
		Keyno INT)

-- This temp table is used to store the key/constraint properties
-- of the moved table.
IF OBJECT_ID('tempdb..#tblKeysTable', 'U') IS NOT NULL
        DROP TABLE #tblKeysTable

CREATE TABLE #tblKeysTable (
        Idx INT IDENTITY(1, 1),
        KeyName NVARCHAR(128),
        indid INT,
        Type CHAR(2))

-- This temp table holds the foreign keys of the table.
-- The SQLStmt column is used to build dynamic SQL statements
-- that are related to these foreign keys.
IF OBJECT_ID('tempdb..#tblFKTable', 'U') IS NOT NULL
        DROP TABLE #tblFKTable

CREATE TABLE #tblFKTable (
        Idx INT IDENTITY(1, 1),
        ForeignTableName NVARCHAR(128),
        KeyName NVARCHAR(128),
        SQLStmt NVARCHAR(1024))

-- This temp table holds the colunms of the foriegn key of the table.
IF OBJECT_ID('tempdb..#tblFKColTable', 'U') IS NOT NULL
        DROP TABLE #tblFKColTable

CREATE TABLE #tblFKColTable (
        Idx INT IDENTITY(1, 1),
        ColName NVARCHAR(128),
        FOrP CHAR(1))


-- Get server and database names
SET @ServerName = CAST(ISNULL(SERVERPROPERTY('ServerName'), 'Unknown') AS sysname)
SET @DatabaseName = db_name()

-- Some basic verifications:
-- 1. Check that file groups exist, and that the table exists.

SET @File1Name = FILEGROUP_NAME(@SourceFileGroupID)

IF @File1Name IS NULL
BEGIN
        IF @SourceFileGroupID IS NULL
                SET @SourceFileGroupID = 'NULL'

        SET @ScriptMsg = N'The source file group ' + CAST(@SourceFileGroupID AS VARCHAR(64)) + N' does not exist on the database ' + @DatabaseName + N', on server ' + @ServerName + N'. Please provide a valid filegroup id.'
        RAISERROR(@ScriptMsg, 16, 1)
        RETURN
END


SET @File2Name = FILEGROUP_NAME(@TargetFileGroupID)

IF @File2Name IS NULL
BEGIN
        IF @TargetFileGroupID IS NULL
                SET @TargetFileGroupID = 'NULL'

        SET @ScriptMsg = N'The target file group ' + CAST(@TargetFileGroupID AS VARCHAR(64)) + N' does not exist on the database ' + @DatabaseName + N', on server ' + @ServerName + N'. Please provide a valid filegroup id.'
        RAISERROR(@ScriptMsg, 16, 1)
        RETURN
END

IF @SourceFileGroupID = @TargetFileGroupID
BEGIN
        SET @ScriptMsg = N'The file groups provided are the same. This is not allow in this script.'
        RAISERROR(@ScriptMsg, 16, 1)
        RETURN
END

SET @TableToMove = LTRIM(RTRIM(@TableToMove))

--Doing a replace here instead of left and right remove of brakets
SELECT @TableToMove = REPLACE(@TableToMove,'[','')
SELECT @TableToMove = REPLACE(@TableToMove,']','')

/*
IF RIGHT(@TableToMove, 1) = ']'
        SET @TableToMove = LEFT(@TableToMove, LEN(@TableToMove) - 1)
IF LEFT(@TableToMove, 1) = '['
        SET @TableToMove = RIGHT(@TableToMove, LEN(@TableToMove) - 1)
*/

-- Validate the table name and check that it exists in the system catalog.
IF @TableToMove IS NULL OR @TableToMove = ''
BEGIN
        SET @ScriptMsg = N'The table name provided in the script is either null or empty, on server '
                + @ServerName + N' and database ' + @DatabaseName
                + N'. Please provide a valid table name.'
        RAISERROR(@ScriptMsg, 16, 1)
        RETURN
END

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @TableToMove AND TABLE_TYPE = 'BASE TABLE')
BEGIN
        SET @ScriptMsg = N'The table name provided in the script is not found in database '
                + @DatabaseName + N', on server ' + @ServerName + N'. Please provide a valid table name.'
        RAISERROR(@ScriptMsg, 16, 1)
        RETURN
END

-- Check that the table is indeed defined on the source file group.
IF (SELECT TOP 1 groupid FROM sysindexes WHERE id = OBJECT_ID(@TableToMove) and indid IN (0, 1)) <> @SourceFileGroupID
BEGIN
        SET @ScriptMsg = N'The table ' + @TableToMove + ' is not found on filegroup ' + CAST(@SourceFileGroupID AS VARCHAR(32))
                + N'. Please provide a valid table name and source file group.'
        RAISERROR(@ScriptMsg, 16, 1)
        RETURN
END

-- 2. Check that the target file group is not read-only.

IF FILEGROUPPROPERTY(FILEGROUP_NAME(@TargetFileGroupID), 'IsReadOnly') = 1
BEGIN
        SET @ScriptMsg = N'The taget file group (i.e., with file group id = ' + CAST(@TargetFileGroupID AS VARCHAR(32)) + N') is read-only. Aborting table move.'
        RAISERROR(@ScriptMsg, 16, 1)
        RETURN
END


-- 3. If we have gotten this far, then it is ok to move the table to the
-- requested filegroup.

-- First thing first: Check whether the table has a clustered index.
SET @TableHasCI = OBJECTPROPERTY(OBJECT_ID(@TableToMove), 'TableHasClustIndex')

-- If not - check whether the table has an identity column.
-- If it does - apply the CI with the new filegroup on the identity column.
-- Once done - remove the CI. If it does not - check whether the table has a primary
-- key and apply the CI there on the new file group, and then drop the CI.
-- If the table does not have an identity column, or a primary key,
-- then a new identity column is created for the table and the CI
-- is applied on it, and then the CI and the identity column are removed.
-- This whole shabang is done in order to make the CI creation as fast as possible.
-- The case where the table does not have a clustered index to begin with implies
-- bad table design, and should not be common anyhow.

IF @TableHasCI = 0
BEGIN
        SET @TableHasIdent = OBJECTPROPERTY(OBJECT_ID(@TableToMove), 'TableHasIdentity')

        IF @TableHasIdent = 0
        BEGIN
                SET @TableHasPK = OBJECTPROPERTY(OBJECT_ID(@TableToMove), 'TableHasPrimaryKey')
                SET @TableHasUQ = OBJECTPROPERTY(OBJECT_ID(@TableToMove), 'TableHasUniqueCnst')

                -- Only if the table has no PK/UQ or clustered index, then create an identity
                -- column on it. This new column will hold the CI.
                IF @TableHasPK = 0 AND @TableHasUQ = 0
                BEGIN
                        EXEC(N' ALTER TABLE [' + @TableToMove + N'] ADD
                                [This_Is_My_Ident_Col_Name] BIGINT IDENTITY (1, 1) ')

                        SET @IdentColName = 'This_Is_My_Ident_Col_Name'

                        -- Apply the CI on the identity column. We don't create the CI
                        -- as unique, since the identity column may be non-unique,
                        -- due to reseeding.

                        EXEC(N'CREATE CLUSTERED INDEX [This_Is_My_Clsuetered_Index_Name]
                        ON [' + @TableToMove + N']([' + @IdentColName + '])
                        ON [' + @File2Name + N']')

                        -- The table is now moved -> Remove the CI.

                        EXEC(N'DROP INDEX [' + @TableToMove + N'].[This_Is_My_Clsuetered_Index_Name]')

                        -- Finally, remove the added identity column

                        EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                DROP COLUMN [This_Is_My_Ident_Col_Name] ')
                END
                ELSE
                BEGIN
                        -- In this case, the table has a PK/UQ, so we might as well
                        -- apply the CI on the column(s) of the PK/UQ.
                        -- First, get the column(s) of the PK/UQ.

                        SELECT @KeyName = CONSTRAINT_NAME
                        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WITH (NOLOCK)
                        WHERE TABLE_NAME = @TableToMove
                                AND CONSTRAINT_TYPE = 'PRIMARY KEY'

                        IF @@ROWCOUNT = 0
                                SELECT TOP 1 @KeyName = CONSTRAINT_NAME
                                FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WITH (NOLOCK)
                                WHERE TABLE_NAME = @TableToMove
                                        AND CONSTRAINT_TYPE = 'UNIQUE'

                        -- The varialbe @KeyName now holds the name of the PK/UQ
                        INSERT INTO #tblColTable (ColName, IdxOrder)
                        SELECT  COL_NAME(OBJECT_ID(@TableToMove), colid),
                                -- append the DESC/ASC string, based on the ASC/DESC order of the PK columns
                                CASE    WHEN INDEXKEY_PROPERTY(OBJECT_ID(@TableToMove),
                                                INDEXPROPERTY(OBJECT_ID(@TableToMove),
                                                @KeyName,
                                                'IndexID'),
                                                keyno,
                                                'IsDescending') = 1
                                        THEN 'DESC'
                                        ELSE 'ASC'
                                END
                        FROM sysindexkeys
                        WHERE id = OBJECT_ID(@TableToMove)
                                AND indid = INDEXPROPERTY(OBJECT_ID(@TableToMove), @KeyName, 'IndexID')

                        IF @@ROWCOUNT > 0
                                SET @i = 1

                        SET @ColList = N''

                        WHILE EXISTS(SELECT * FROM #tblColTable WHERE Idx = @i)
                        BEGIN
                                SELECT @ColList = @ColList + N'[' + ColName + N'] ' + IdxOrder + N' ,'
                                FROM #tblColTable
                                WHERE Idx = @i

                                SET @i = @i + 1
                        END

                        SET @ColList = LEFT(@ColList, LEN(@ColList) - 1)

                        -- Now, apply the CI on the primary key columns. The CI is not
                        -- created as a unique CI, since if the PK/UQ was added with the NOCHECK
                        -- option, there could be duplicate entries in the PK/UQ.

                        EXEC(N'CREATE CLUSTERED INDEX [This_Is_My_Clsuetered_Index_Name]
                        ON [' + @TableToMove + N'](' + @ColList + ')
                        ON [' + @File2Name + N']')

                        -- The last command moved the CI (and thus the table), so we
                        -- can now drop the CI.

                        EXEC(N'DROP INDEX [' + @TableToMove + N'].[This_Is_My_Clsuetered_Index_Name]')
                END
        END
        ELSE
        BEGIN
                -- Here, the table originally had an identity. We apply the CI
                -- on the identity column, and then remove it.
                SELECT @IdentColName = COLUMN_NAME
                FROM INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK)
                WHERE TABLE_NAME = @TableToMove
                        AND COLUMNPROPERTY(OBJECT_ID(@TableToMove), COLUMN_NAME, 'IsIdentity') = 1

                EXEC(N'CREATE CLUSTERED INDEX [This_Is_My_Clsuetered_Index_Name]
                ON [' + @TableToMove + N']([' + @IdentColName + '])
                ON [' + @File2Name + N']')

                -- The table is now moved -> Remove the CI.

                EXEC(N'DROP INDEX [' + @TableToMove + N'].[This_Is_My_Clsuetered_Index_Name]')
        END
END
ELSE
BEGIN
        -- Now, for the big ELSE. The ELSE applies to the case where the 
        -- table already has a clustered index. Here, we select the name of the
        -- existing clustered index, then drop it from the table, and recreate
        -- it on the other filegroup (on the same columns and order as was
        -- originally defined for the table).
        -- If the CI is also a PK/UQ/unique index, then we first check all foreign
        -- keys for the PK/UQ/UI, drop them if they exist, drop the PK/UQ/UI
        -- then recreate the PK/UQ/UI as CLUSTERED, and then reapply all the
        -- foreign keys constraints. If the CI is non-unique (thus is not
        -- associated with a PK/UQ/UI), we just drop and recreate it on the
        -- target file group.

        SELECT @CIName = [name]
        FROM sysindexes WITH (NOLOCK)
        WHERE id = OBJECT_ID(@TableToMove)
                AND indid = 1

        DELETE FROM #tblColTable

        INSERT INTO #tblColTable (ColName, IdxOrder)
        SELECT COL_NAME(OBJECT_ID(@TableToMove), colid),
                -- append the DESC/ASC string, based on the ASC/DESC order of the PK columns
                CASE    WHEN INDEXKEY_PROPERTY(OBJECT_ID(@TableToMove),
                                INDEXPROPERTY(OBJECT_ID(@TableToMove),
                                @CIName,
                                'IndexID'),
                                keyno,
                                'IsDescending') = 1
                        THEN 'DESC'
                        ELSE 'ASC'
                END
        FROM sysindexkeys WITH (NOLOCK)
        WHERE id = OBJECT_ID(@TableToMove)
                AND indid = 1
        ORDER BY keyno ASC

        SELECT @i = MIN(Idx)
        FROM #tblColTable

        SET @ColList = N''

        WHILE EXISTS(SELECT * FROM #tblColTable WHERE Idx = @i)
        BEGIN
                SELECT @ColList = @ColList + N'[' + ColName + N'] ' + IdxOrder + N' ,'
                FROM #tblColTable
                WHERE Idx = @i

                SET @i = @i + 1
        END

        SET @ColList = LEFT(@ColList, LEN(@ColList) - 1)

        -- Check whether the clustered index is also the PK, or a unique constraint (UQ),
        -- or a unique index (UI) that is neither a PK or a UQ.
        -- If the CI is either one of the above, we first check whether any foreign keys
        -- reference this PK/UQ/UI. If so - we drop the FKs, then drop the PK/UQ/UI,
        -- then recreate the PK/UQ/UI on the target filegroup, and then recreate all
        -- the foreign keys dropped earlier.
        -- If the CI is other than the above (i.e., it is a non-unique clustered index)
        -- then we simply drop it and recreate it on the target filegroup.

        IF OBJECTPROPERTY(OBJECT_ID(@CIName), 'IsPrimaryKey') = 1
                OR OBJECTPROPERTY(OBJECT_ID(@CIName), 'IsUniqueCnst') = 1
                OR INDEXPROPERTY(OBJECT_ID(@TableToMove), @CIName, 'IsUnique') = 1
        BEGIN
                -- This case stands for a CI which is a PK/UQ/UI.
                -- First, we drop all foreign keys associated with the PK/UQ/UI.
                -- These FK constraints will be reapplied on the PK later,
                -- (i.e., after the PK/UQ/UI is recreated on the target filegroup).

                DELETE FROM #tblFKTable

                -- Get all the FK constraints associated with the PK/UQ/UI.
                -- Here, we query sysreferences so we could get our hands on all the
                -- foreign keys that reference the PK/UQ/UI of the table
                -- that needs to be moved.
                INSERT INTO #tblFKTable (ForeignTableName, KeyName)
                SELECT OBJECT_NAME(fkeyid), OBJECT_NAME(constid)
                FROM sysreferences WITH (NOLOCK)
                WHERE rkeyid = OBJECT_ID(@TableToMove)
                        AND rkeyindid = INDEXPROPERTY(OBJECT_ID(@TableToMove), @CIName, 'IndexID')

                SELECT @AssocFKeyName = MIN(KeyName)
                FROM #tblFKTable

                WHILE @AssocFKeyName IS NOT NULL
                BEGIN
                        -- Get the list of primary and then foreign columns
                        -- for the collected FK constraints. The CASCADE UPDATE,
                        -- CASCADE DELETE, and NOT FOR REPLICATION properties
                        -- of the FK are considered later.

                        SELECT @FKTableName = ForeignTableName
                        FROM #tblFKTable
                        WHERE KeyName = @AssocFKeyName

                        DELETE FROM #tblFKColTable

                        -- First, the tables of the foreign table. The select is ordered by keyno
                        -- so the order of columns in the FK will remain unchanged by the
                        -- drop/recreate operation.
                        INSERT INTO #tblFKColTable (ColName, FOrP)
                        SELECT COL_NAME(fkeyid, fkey), 'F'
                        FROM sysforeignkeys
                        WHERE constid = OBJECT_ID(@AssocFKeyName)
                        ORDER BY keyno
                        
                        -- Similarly, for the primary table.
                        INSERT INTO #tblFKColTable (ColName, FOrP)
                        SELECT COL_NAME(rkeyid, rkey), 'P'
                        FROM sysforeignkeys
                        WHERE constid = OBJECT_ID(@AssocFKeyName)
                        ORDER BY keyno

                        -- We now build the FK creation statement
                        SELECT @j = MIN(Idx)
                        FROM #tblFKColTable

                        SET @SQLStr = N'ALTER TABLE [' + @FKTableName + N'] '
                                      + N' WITH NOCHECK ADD CONSTRAINT [' + @AssocFKeyName + N'] '
                                      + N' FOREIGN KEY ('

                        -- Foreign table columns
                        WHILE EXISTS(SELECT * FROM #tblFKColTable WHERE Idx = @J AND FOrP = 'F')
                        BEGIN
                                SELECT @SQLStr = @SQLStr + N'[' + ColName + N'],'
                                FROM #tblFKColTable
                                WHERE Idx = @j
                                
                                SET @j = @j + 1
                        END

                        SET @SQLStr = LEFT(@SQLStr, LEN(@SQLStr) - 1) + N') REFERENCES [' + @TableToMove + N']('

                        -- Primary table columns
                        WHILE EXISTS(SELECT * FROM #tblFKColTable WHERE Idx = @J AND FOrP = 'P')
                        BEGIN
                                SELECT @SQLStr = @SQLStr + N'[' + ColName + N'],'
                                FROM #tblFKColTable
                                WHERE Idx = @j
                                
                                SET @j = @j + 1
                        END

                        SET @SQLStr = LEFT(@SQLStr, LEN(@SQLStr) - 1) + ') '

                        IF OBJECTPROPERTY(OBJECT_ID(@AssocFKeyName), 'CnstIsDeleteCascade') = 1
                                SET @SQLStr = @SQLStr + N' ON DELETE CASCADE '

                        IF OBJECTPROPERTY(OBJECT_ID(@AssocFKeyName), 'CnstIsUpdateCascade') = 1
                                SET @SQLStr = @SQLStr + N' ON UPDATE CASCADE '

                        IF OBJECTPROPERTY(OBJECT_ID(@AssocFKeyName), 'CnstIsNotRepl') = 1
                                SET @SQLStr = @SQLStr + N' NOT FOR REPLICATION '


                        -- Now, store this SQL statement, and drop the FK constraint
                        UPDATE #tblFKTable
                        SET SQLStmt = @SQLStr
                        WHERE KeyName = @AssocFKeyName

                        -- Drop the constraint

                        EXEC(N'ALTER TABLE [' + @FKTableName + '] DROP CONSTRAINT [' + @AssocFKeyName + N']')

                        SELECT @AssocFKeyName = MIN(KeyName)
                        FROM #tblFKTable
                        WHERE @AssocFKeyName < KeyName
                END

                -- The CREATE statement is different for PK or UQ
                IF OBJECTPROPERTY(OBJECT_ID(@CIName), 'IsPrimaryKey') = 1
                BEGIN
                        EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                DROP CONSTRAINT [' + @CIName + N'] ')

                        EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                WITH NOCHECK ADD CONSTRAINT [' + @CIName + N']
                                PRIMARY KEY CLUSTERED (' + @ColList + N')
                                ON [' + @File2Name + N']')
                END
                ELSE
                BEGIN
                        IF OBJECTPROPERTY(OBJECT_ID(@CIName), 'IsUniqueCnst') = 1
                        BEGIN
                                EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                        DROP CONSTRAINT [' + @CIName + N'] ')

                                EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                        WITH NOCHECK ADD CONSTRAINT [' + @CIName + N']
                                        UNIQUE CLUSTERED (' + @ColList + N')
                                        ON [' + @File2Name + N']')
                        END
                        ELSE -- the CI here is a unique index
                        BEGIN
                                SET @IsPadIndex = INDEXPROPERTY(OBJECT_ID(@TableToMove), @CIName, 'IsPadIndex')

                                EXEC(N'DROP INDEX [' + @TableToMove + N'].[' + @CIName + N']')

                                -- Recreate the index on the same columns and column order, as 
                                -- they were defined on the original table, and in this
                                -- case, the CI is kept unique.

                                IF @IsPadIndex = 1

                                        EXEC(N'CREATE UNIQUE CLUSTERED INDEX [' + @CIName + N']
                                        ON [' + @TableToMove + N'](' + @ColList + N')
                                        WITH PAD_INDEX
                                        ON [' + @File2Name + N']')

                                ELSE
                                        EXEC(N'CREATE UNIQUE CLUSTERED INDEX [' + @CIName + N']
                                        ON [' + @TableToMove + N'](' + @ColList + N')
                                        ON [' + @File2Name + N']')
                        END
                END

                -- Recreate the FK constraint of the table.
                SELECT @AssocFKeyName = MIN(KeyName)
                FROM #tblFKTable

                WHILE @AssocFKeyName IS NOT NULL
                BEGIN
                        SELECT @SQLStr = SQLStmt
                        FROM #tblFKTable
                        WHERE KeyName = @AssocFKeyName

                        EXEC(@SQLStr)

                        SELECT @AssocFKeyName = MIN(KeyName)
                        FROM #tblFKTable
                        WHERE @AssocFKeyName < KeyName
                END
        END
        ELSE
        BEGIN
                -- Here, the CI is not a PK/UQ/UI, so we drop the CI from
                -- the current filegroup, and recreate it on the
                -- target filegroup, as a non-unique index.

                SET @IsPadIndex = INDEXPROPERTY(OBJECT_ID(@TableToMove), @CIName, 'IsPadIndex')

                EXEC(N'DROP INDEX [' + @TableToMove + N'].[' + @CIName + N']')

                -- Recreate the index on the same columns and column order, as 
                -- they were defined on the original table, and in this
                -- case, the CI is not unique.

                IF @IsPadIndex = 1

                        EXEC(N'CREATE CLUSTERED INDEX [' + @CIName + N']
                        ON [' + @TableToMove + N'](' + @ColList + N')
                        WITH PAD_INDEX
                        ON [' + @File2Name + N']')
                ELSE
                        EXEC(N'CREATE CLUSTERED INDEX [' + @CIName + N']
                        ON [' + @TableToMove + N'](' + @ColList + N')
                        ON [' + @File2Name + N']')
        END
END

-- Great. Now the table is on the new file group.
-- We now check the @MovePKAndAllUniqueConstraints bit,
-- and if it is 1, we move the PK and all unique constraints
-- of the table, to the new file group.
-- Similarly, if the @MoveAllNonClusteredIndexes = 1 then
-- we move the non-clustered indexes of the table to
-- the new file group as well. The structure of the code
-- for the UQ, PK and non-clustered indexes is the same,
-- so we move them all together (with minor syntax changes where needed).
-- One comment: The fillfactor and padindex are not carried over,
-- for the indexes and constraints. A good DBA would set the defaults
-- on both filegroups the same.

-- Gather all the unique constraints that need to be moved to
-- the new file group.
IF @MovePKAndAllUniqueConstraints = 1
BEGIN
        -- Get all unique keys (including the PK) for the table.
        INSERT INTO #tblKeysTable (KeyName, indid, type)
        SELECT a.[name], a.indid, b.xtype
        FROM sysindexes a WITH (NOLOCK)
                INNER JOIN sysobjects b WITH (NOLOCK)
                ON a.[name] = b.[name]
        WHERE b.parent_obj = OBJECT_ID(@TableToMove)
                AND b.xtype IN ('PK', 'UQ')
                AND a.groupid = @SourceFileGroupID
                AND a.indid > 0 AND a.indid < 255
END

-- Gather all the non-clustered indexes that need to be moved to
-- the new file group.
IF @MoveAllNonClusteredIndexes = 1
BEGIN
        INSERT INTO #tblKeysTable (KeyName, indid, type)
        SELECT  a.[name],
                a.indid,
                CASE
                WHEN INDEXPROPERTY(OBJECT_ID(@TableToMove), a.[name], 'IsUnique') = 1
                THEN 'UI' -- to denote unique index.
                ELSE 'I'  -- to denote a non-unique index
                END
        FROM sysindexes a WITH (NOLOCK)
                LEFT OUTER JOIN #tblKeysTable b
                ON a.name = b.KeyName
        WHERE   a.id = OBJECT_ID(@TableToMove)
                AND INDEXPROPERTY(OBJECT_ID(@TableToMove), a.[name], 'IsStatistics') = 0
                AND a.groupid = @SourceFileGroupID
                AND b.KeyName IS NULL -- do not collect the PK and UQs again!
                AND a.indid > 0 AND a.indid < 255
END

-- Now, loop through all keys/indexes collected in #tblKeysTable
-- and move them one by one to the new filegroup, while
-- maintaining the same column order they were previously defined on.
WHILE EXISTS(SELECT * FROM #tblKeysTable)
BEGIN
        SET @indid = NULL
        SET @Type = NULL
        SET @KeyName = NULL

        SELECT TOP 1 @indid = indid,
                @Type = Type,
                @KeyName = KeyName
        FROM #tblKeysTable

        DELETE FROM #tblColTable

        INSERT INTO #tblColTable (ColName, IdxOrder, Keyno)
        SELECT  COL_NAME(OBJECT_ID(@TableToMove), colid),
                -- append the DESC/ASC string, based on the ASC/DESC order of the PK columns
                CASE    WHEN INDEXKEY_PROPERTY(OBJECT_ID(@TableToMove),
                                INDEXPROPERTY(OBJECT_ID(@TableToMove),
                                @KeyName,
                                'IndexID'),
                                keyno,
                                'IsDescending') = 1
                        THEN 'DESC'
                        ELSE 'ASC'
                END,
				Keyno
        FROM sysindexkeys WITH (NOLOCK)
        WHERE id = OBJECT_ID(@TableToMove)
                AND indid = @indid
        ORDER BY keyno ASC

        SELECT @i = MIN(Idx)
        FROM #tblColTable

        SET @ColList = N''

		--Building Index key columns for index
        WHILE EXISTS(SELECT * FROM #tblColTable WHERE Idx = @i)
        BEGIN
			SELECT @Keyno = Keyno FROM #tblColTable WHERE Idx = @i
			IF (@Keyno > 0)
			BEGIN
                SELECT @ColList = @ColList + N'[' + ColName + N'] ' + IdxOrder + N' ,'
                FROM #tblColTable
                WHERE Idx = @i
			END

                SET @i = @i + 1
        END

        SET @ColList = LEFT(@ColList, LEN(@ColList) - 1)

        SELECT @i = MIN(Idx)
        FROM #tblColTable

        SET @IncludeColumnList = N''
		SET @IncludeColExists = 0

		--Building Included columns for index
        WHILE EXISTS(SELECT * FROM #tblColTable WHERE Idx = @i)
        BEGIN
			SELECT @Keyno = Keyno FROM #tblColTable WHERE Idx = @i
			IF (@Keyno = 0)
			BEGIN
                SELECT @IncludeColumnList = @IncludeColumnList + N'[' + ColName + N'] ' + N' ,'
                FROM #tblColTable
                WHERE Idx = @i

				SET @IncludeColExists = 1
			END

                SET @i = @i + 1
        END

		IF LEN(@IncludeColumnList) > 1
		BEGIN
			SET @IncludeColumnList = LEFT(@IncludeColumnList, LEN(@IncludeColumnList) - 1)
		END


        -- Drop the object, and then recreate it on the new filegroup.
        -- Note: If a PK/UQ or a unique index (UI) is on the source file group,
        -- then it must be a NONCLUSTERED PK/UQ, since the CLUSTERED PK/UQ/UI was
        -- already handled above.
        -- Also - we first check whether the PK/UQ/UI are used in any foreign keys, before
        -- we drop/recreate them. If they are - then the FKs are first dropped,
        -- then the PK/UQ/UI is dropped and recreated, and the FK constraints
        -- are then recreated as well.

        IF @Type IN ('PK', 'UQ', 'UI')
        BEGIN
                DELETE FROM #tblFKTable

                -- Get all the FK constraints associated with the PK/UQ/UI (UI = unique index).
                -- Here, we must query sysreferences since it can identify which
                -- foreign keys reference the table that we are moving, as well as
                -- each individual unique constraint/index.
                INSERT INTO #tblFKTable (ForeignTableName, KeyName)
                SELECT OBJECT_NAME(fkeyid), OBJECT_NAME(constid)
                FROM sysreferences WITH (NOLOCK)
                WHERE rkeyid = OBJECT_ID(@TableToMove)
                        AND rkeyindid = INDEXPROPERTY(OBJECT_ID(@TableToMove), @KeyName, 'IndexID')

                SELECT @AssocFKeyName = MIN(KeyName)
                FROM #tblFKTable

                WHILE @AssocFKeyName IS NOT NULL
                BEGIN
                        -- Get the list of primary and then foreign columns
                        -- for the collected FK constraints. The CASCADE UPDATE,
                        -- CASCADE DELETE, and NOT FOR REPLICATION properties
                        -- of the FK are considered later.

                        SELECT @FKTableName = ForeignTableName
                        FROM #tblFKTable
                        WHERE KeyName = @AssocFKeyName

                        DELETE FROM #tblFKColTable

                        -- First, the tables of the foreign table. The select is ordered by keyno
                        -- so the order of columns in the FK will remain unchanged by the
                        -- drop/recreate operation.
                        INSERT INTO #tblFKColTable (ColName, FOrP)
                        SELECT COL_NAME(fkeyid, fkey), 'F'
                        FROM sysforeignkeys
                        WHERE constid = OBJECT_ID(@AssocFKeyName)
                        ORDER BY keyno
                        
                        -- Similarly, for the primary table.
                        INSERT INTO #tblFKColTable (ColName, FOrP)
                        SELECT COL_NAME(rkeyid, rkey), 'P'
                        FROM sysforeignkeys
                        WHERE constid = OBJECT_ID(@AssocFKeyName)
                        ORDER BY keyno

                        -- We now build the FK creation statement
                        SELECT @j = MIN(Idx)
                        FROM #tblFKColTable

                        SET @SQLStr = N'ALTER TABLE [' + @FKTableName + N'] '
                                      + N' WITH NOCHECK ADD CONSTRAINT [' + @AssocFKeyName + N'] '
                                      + N' FOREIGN KEY ('

                        -- Foreign table columns
                        WHILE EXISTS(SELECT * FROM #tblFKColTable WHERE Idx = @J AND FOrP = 'F')
                        BEGIN
                                SELECT @SQLStr = @SQLStr + N'[' + ColName + N'],'
                                FROM #tblFKColTable
                                WHERE Idx = @j
                                
                                SET @j = @j + 1
                        END

                        SET @SQLStr = LEFT(@SQLStr, LEN(@SQLStr) - 1) + N') REFERENCES [' + @TableToMove + N']('

                        -- Primary table columns
                        WHILE EXISTS(SELECT * FROM #tblFKColTable WHERE Idx = @J AND FOrP = 'P')
                        BEGIN
                                SELECT @SQLStr = @SQLStr + N'[' + ColName + N'],'
                                FROM #tblFKColTable
                                WHERE Idx = @j
                                
                                SET @j = @j + 1
                        END

                        SET @SQLStr = LEFT(@SQLStr, LEN(@SQLStr) - 1) + ') '

                        IF OBJECTPROPERTY(OBJECT_ID(@AssocFKeyName), 'CnstIsDeleteCascade') = 1
                                SET @SQLStr = @SQLStr + N' ON DELETE CASCADE '

                        IF OBJECTPROPERTY(OBJECT_ID(@AssocFKeyName), 'CnstIsUpdateCascade') = 1
                                SET @SQLStr = @SQLStr + N' ON UPDATE CASCADE '

                        IF OBJECTPROPERTY(OBJECT_ID(@AssocFKeyName), 'CnstIsNotRepl') = 1
                                SET @SQLStr = @SQLStr + N' NOT FOR REPLICATION '


                        -- Now, store this SQL statement, and drop the FK constraint
                        UPDATE #tblFKTable
                        SET SQLStmt = @SQLStr
                        WHERE KeyName = @AssocFKeyName

                        -- Drop the constraint

                        EXEC(N'ALTER TABLE [' + @FKTableName + '] DROP CONSTRAINT [' + @AssocFKeyName + N']')

                        SELECT @AssocFKeyName = MIN(KeyName)
                        FROM #tblFKTable
                        WHERE @AssocFKeyName < KeyName
                END

                -- Now, drop the PK/UQ/UI and recreate it
                IF @Type = 'PK'
                BEGIN

                        EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                DROP CONSTRAINT [' + @KeyName + N'] ')

                        EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                WITH NOCHECK ADD CONSTRAINT [' + @KeyName + N']
                                PRIMARY KEY NONCLUSTERED (' + @ColList + N')
                                ON [' + @File2Name + N']')
                END
                ELSE
                BEGIN
                        IF @Type = 'UQ'
                        BEGIN

                                EXEC(N' ALTER TABLE [' + @TableToMove + N']
                                        DROP CONSTRAINT [' + @KeyName + N'] ')


								EXEC(N' ALTER TABLE [' + @TableToMove + N']
										WITH NOCHECK ADD CONSTRAINT [' + @KeyName + N']
										UNIQUE NONCLUSTERED (' + @ColList + N')
										ON [' + @File2Name + N']')
                        END
                        ELSE -- must be UI
                        BEGIN
                                SET @IsPadIndex = INDEXPROPERTY(OBJECT_ID(@TableToMove), @KeyName, 'IsPadIndex')

                                EXEC(N' DROP INDEX [' + @TableToMove + N'].[' + @KeyName + N']')

                                IF @IsPadIndex = 1
								BEGIN
 									IF @IncludeColExists = 1
									BEGIN
                                       EXEC(N' CREATE UNIQUE NONCLUSTERED INDEX [' + @KeyName + N']
                                                ON [' + @TableToMove + N'](' + @ColList + N') INCLUDE (' + @IncludeColumnList + N')
                                                WITH PAD_INDEX
                                                ON [' + @File2Name + N']')
									END
									ELSE
									BEGIN
                                       EXEC(N' CREATE UNIQUE NONCLUSTERED INDEX [' + @KeyName + N']
                                                ON [' + @TableToMove + N'](' + @ColList + N')
                                                WITH PAD_INDEX
                                                ON [' + @File2Name + N']')
									END
								END
                                ELSE
								BEGIN
 									IF @IncludeColExists = 1
									BEGIN
                                        EXEC(N' CREATE UNIQUE NONCLUSTERED INDEX [' + @KeyName + N']
                                                ON [' + @TableToMove + N'](' + @ColList + N') INCLUDE (' + @IncludeColumnList + N')
                                                ON [' + @File2Name + N']')
									END
									ELSE
									BEGIN
                                        EXEC(N' CREATE UNIQUE NONCLUSTERED INDEX [' + @KeyName + N']
                                                ON [' + @TableToMove + N'](' + @ColList + N') 
                                                ON [' + @File2Name + N']')
									END
								END
                        END
                END

                -- And recreate the FK constraints attached to the PK/UQ
                -- that was just recreated.
                -- Recreate the FK constraint of the table.
                SELECT @AssocFKeyName = MIN(KeyName)
                FROM #tblFKTable

                WHILE @AssocFKeyName IS NOT NULL
                BEGIN
                        SELECT @SQLStr = SQLStmt
                        FROM #tblFKTable
                        WHERE KeyName = @AssocFKeyName

                        EXEC(@SQLStr)

                        SELECT @AssocFKeyName = MIN(KeyName)
                        FROM #tblFKTable
                        WHERE @AssocFKeyName < KeyName
                END
        END

        IF @Type = 'I'
        BEGIN
                SET @IsPadIndex = INDEXPROPERTY(OBJECT_ID(@TableToMove), @KeyName, 'IsPadIndex')

                EXEC(N' DROP INDEX [' + @TableToMove + N'].[' + @KeyName + N']')

                IF @IsPadIndex = 1
				BEGIN
 					IF @IncludeColExists = 1
					BEGIN
                        EXEC(N' CREATE NONCLUSTERED INDEX [' + @KeyName + N']
                                ON [' + @TableToMove + N'](' + @ColList + N') INCLUDE (' + @IncludeColumnList + N')
                                WITH PAD_INDEX
                                ON [' + @File2Name + N']')
					END
					ELSE
					BEGIN
                        EXEC(N' CREATE NONCLUSTERED INDEX [' + @KeyName + N']
                                ON [' + @TableToMove + N'](' + @ColList + N')
                                WITH PAD_INDEX
                                ON [' + @File2Name + N']')
					END
				END
                ELSE
				BEGIN
 					IF @IncludeColExists = 1
					BEGIN
                        EXEC(N' CREATE NONCLUSTERED INDEX [' + @KeyName + N']
                                ON [' + @TableToMove + N'](' + @ColList + N') INCLUDE (' + @IncludeColumnList + N')
                                ON [' + @File2Name + N']')
					END
					ELSE
					BEGIN
                        EXEC(N' CREATE NONCLUSTERED INDEX [' + @KeyName + N']
                                ON [' + @TableToMove + N'](' + @ColList + N')
                                ON [' + @File2Name + N']')
					END
				END
        END

        DELETE FROM #tblKeysTable
        WHERE KeyName = @KeyName
                AND indid = @indid
END 
