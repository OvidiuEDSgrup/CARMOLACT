CREATE PROCEDURE [dbo].[httpXMLSOAPRequest]
@uri NVARCHAR (1000), @method NVARCHAR (1000), @requestBody NVARCHAR (MAX), @soapAction NVARCHAR (4000)=N'', @userName NVARCHAR (100)=N'', @password NVARCHAR (100)=N'', @contentType NVARCHAR (1000)=N'', @responsetext NVARCHAR (MAX) OUTPUT
AS EXTERNAL NAME [AswHttpRequest].[AswHttpRequest.HttpRequest].[AswHttpRequest]

