USE [master]
GO
/****** Object:  Database [CdrDb_269_200904]    Script Date: 02/28/2009 15:19:12 ******/
CREATE DATABASE [CdrDb_269_200904] ON  PRIMARY 
( NAME = N'CdrDb_269_200904_Data', FILENAME = N'C:\Timok\Rbr\SqlDb\\CdrDb_269_200904_Data.MDF' , SIZE = 65536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'CdrDb_269_200904_Log', FILENAME = N'C:\Timok\Rbr\SqlDb\\CdrDb_269_200904_Log.LDF' , SIZE = 7168KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
EXEC dbo.sp_dbcmptlevel @dbname=N'CdrDb_269_200904', @new_cmptlevel=90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CdrDb_269_200904].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CdrDb_269_200904] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET ARITHABORT OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [CdrDb_269_200904] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CdrDb_269_200904] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CdrDb_269_200904] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET  ENABLE_BROKER 
GO
ALTER DATABASE [CdrDb_269_200904] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CdrDb_269_200904] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CdrDb_269_200904] SET  READ_WRITE 
GO
ALTER DATABASE [CdrDb_269_200904] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CdrDb_269_200904] SET  MULTI_USER 
GO
ALTER DATABASE [CdrDb_269_200904] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CdrDb_269_200904] SET DB_CHAINING OFF 

--;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
USE [CdrDb_269_200904]
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'NT AUTHORITY\NETWORK SERVICE')
CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CDRIdentity]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CDRIdentity](
	[id] [char](32) NOT NULL,
 CONSTRAINT [XPKCDRIdentity] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IntToDottedIPAddress]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[IntToDottedIPAddress] 
(
 @IPAddressAsInt int
)

/**
--if you need to drop it
if exists (select 1
          from sysobjects
          where  id = object_id(''dbo.IntToDottedIPAddress)
          and type in (''IF'', ''FN'', ''TF''))
   drop function dbo.IntToDottedIPAddress
--go
*/
/**************************************************************************
DESCRIPTION: Returns dotted IPAddress

PARAMETERS:
  (@IPAddressAsInt int) - The int number containing a valid IP
  
RETURNS: IP converted to varchar dot-notation
  
USAGE:         SELECT  dbo.IntToDottedIPAddress(-2037012288)
***************************************************************************/

RETURNS varchar(20)
BEGIN

DECLARE 
 @biOctetA bigint,
 @biOctetB bigint,
 @biOctetC bigint,
 @biOctetD bigint,
 @bIp  bigint,
 @dottedIPAddress varchar(20)
        
SET @bIp = CONVERT(bigint, @IPAddressAsInt)

SET @biOctetD = (@bIp & 0x00000000FF000000) / 256 / 256 / 256
SET @biOctetC = (@bIp & 0x0000000000FF0000) / 256 / 256
SET @biOctetB = (@bIp & 0x000000000000FF00) / 256
SET @biOctetA = (@bIp & 0x00000000000000FF)
        
SET @dottedIPAddress =  
  CONVERT(varchar(4), @biOctetA) + ''.'' +
  CONVERT(varchar(4), @biOctetB) + ''.'' +
  CONVERT(varchar(4), @biOctetC) + ''.'' +
  CONVERT(varchar(4), @biOctetD)
                
RETURN @dottedIPAddress
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CDR](
	[date_logged] [datetime] NOT NULL,
	[timok_date] [int] NOT NULL,
	[start] [datetime] NOT NULL,
	[duration] [smallint] NOT NULL,
	[ccode] [int] NOT NULL,
	[local_number] [varchar](18) NOT NULL,
	[carrier_route_id] [int] NOT NULL,
	[price] [decimal](9, 5) NOT NULL,
	[cost] [decimal](9, 5) NOT NULL,
	[orig_IP_address] [int] NOT NULL,
	[orig_end_point_id] [smallint] NOT NULL,
	[term_end_point_id] [smallint] NOT NULL,
	[customer_acct_id] [smallint] NOT NULL,
	[disconnect_cause] [smallint] NOT NULL,
	[disconnect_source] [tinyint] NOT NULL,
	[rbr_result] [smallint] NOT NULL,
	[prefix_in] [varchar](10) NOT NULL,
	[prefix_out] [varchar](10) NOT NULL,
	[DNIS] [bigint] NOT NULL,
	[ANI] [bigint] NOT NULL,
	[serial_number] [bigint] NOT NULL,
	[end_user_price] [decimal](6, 2) NOT NULL,
	[used_bonus_minutes] [smallint] NOT NULL,
	[node_id] [smallint] NOT NULL,
	[customer_route_id] [int] NOT NULL,
	[mapped_disconnect_cause] [smallint] NOT NULL,
	[carrier_acct_id] [smallint] NOT NULL,
	[customer_duration] [smallint] NOT NULL,
	[retail_acct_id] [int] NOT NULL,
	[reseller_price] [decimal](9, 5) NOT NULL,
	[carrier_duration] [smallint] NOT NULL,
	[retail_duration] [smallint] NOT NULL,
	[info_digits] [tinyint] NOT NULL,
	[id] [char](32) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND name = N'XIECDR_Date_Logged')
CREATE NONCLUSTERED INDEX [XIECDR_Date_Logged] ON [dbo].[CDR] 
(
	[date_logged] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND name = N'XIECDR_Identity')
CREATE NONCLUSTERED INDEX [XIECDR_Identity] ON [dbo].[CDR] 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND name = N'XIECDR_TimokDate_carrier')
CREATE NONCLUSTERED INDEX [XIECDR_TimokDate_carrier] ON [dbo].[CDR] 
(
	[timok_date] ASC,
	[carrier_acct_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND name = N'XIECDR_TimokDate_customer')
CREATE NONCLUSTERED INDEX [XIECDR_TimokDate_customer] ON [dbo].[CDR] 
(
	[timok_date] ASC,
	[customer_acct_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND name = N'XIECDR_TimokDate_OEP')
CREATE NONCLUSTERED INDEX [XIECDR_TimokDate_OEP] ON [dbo].[CDR] 
(
	[timok_date] ASC,
	[orig_end_point_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND name = N'XIECDR_TimokDate_RetailAcct')
CREATE NONCLUSTERED INDEX [XIECDR_TimokDate_RetailAcct] ON [dbo].[CDR] 
(
	[timok_date] ASC,
	[retail_acct_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CDR]') AND name = N'XIECDR_TimokDate_TEP')
CREATE NONCLUSTERED INDEX [XIECDR_TimokDate_TEP] ON [dbo].[CDR] 
(
	[timok_date] ASC,
	[term_end_point_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CDRView]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[CDRView]
AS
SELECT 
dbo.CDR.id, 
dbo.CDR.date_logged, 
dbo.CDR.timok_date, 
dbo.CDR.start, 
dbo.CDR.duration, 
dbo.CDR.ccode, 
dbo.CDR.local_number, 
dbo.CDR.carrier_route_id, 
dbo.CDR.price, 
dbo.CDR.cost, 
dbo.CDR.orig_IP_address, 
dbo.CDR.orig_end_point_id, 
dbo.CDR.term_end_point_id, 
dbo.CDR.customer_acct_id, 
dbo.CDR.disconnect_cause, 
dbo.CDR.disconnect_source, 
dbo.CDR.rbr_result, 
dbo.CDR.prefix_in, 
dbo.CDR.prefix_out, 
dbo.CDR.DNIS, 
dbo.CDR.ANI, 
dbo.CDR.info_digits, 
dbo.CDR.serial_number, 
dbo.CDR.end_user_price, 
dbo.CDR.used_bonus_minutes, 
dbo.CDR.reseller_price, 
dbo.CDR.node_id, 
dbo.CDR.customer_route_id, 
dbo.CDR.mapped_disconnect_cause, 
dbo.CDR.carrier_acct_id, 
dbo.IntToDottedIPAddress(dbo.CDR.orig_IP_address) AS orig_dot_IP_address, 

CASE WHEN dbo.CDR.ccode = 0 THEN '''' 
ELSE CAST(dbo.CDR.ccode AS varchar) END + dbo.CDR.local_number AS dialed_number, 

dbo.CDR.retail_acct_id, 
dbo.CDR.customer_duration, 
dbo.CDR.carrier_duration, 
dbo.CDR.retail_duration, 


CAST(dbo.CDR.customer_duration / 6 + (CASE WHEN dbo.CDR.customer_duration % 6 > 0 THEN 1 ELSE 0 END) 
AS decimal(9, 1)) / 10 AS minutes, /* customer_minutes */

CAST(dbo.CDR.carrier_duration / 6 + (CASE WHEN dbo.CDR.carrier_duration % 6 > 0 THEN 1 ELSE 0 END) 
AS decimal(9, 1)) / 10 AS carrier_minutes, 

CAST(dbo.CDR.retail_duration / 6 + (CASE WHEN dbo.CDR.retail_duration % 6 > 0 THEN 1 ELSE 0 END) 
AS decimal(9, 1)) / 10 AS retail_minutes, 


COALESCE (CRR.name, ''UNKNOWN'') AS carrier_route_name, 
COALESCE (CUR.name, ''UNKNOWN'') AS customer_route_name, 
COALESCE (OEP.alias, ''UNKNOWN'') AS orig_alias, 
COALESCE (TEP.alias, ''UNKNOWN'') AS term_alias, 
COALESCE (TEP.ip_address_range, ''0'') AS term_ip_address_range, 
COALESCE (CU.name, ''UNKNOWN'') AS customer_acct_name, 
COALESCE (CU.partner_id, 0) AS orig_partner_id, 
COALESCE (OPT.name, ''UNKNOWN'') AS orig_partner_name, 
COALESCE (CA.name, ''UNKNOWN'') AS carrier_acct_name, 
COALESCE (CA.partner_id, 0) AS term_partner_id, 
COALESCE (TPT.name, ''UNKNOWN'') AS term_partner_name, 
COALESCE (ND.description, ''UNKNOWN'') AS node_name

FROM  
RbrDb_269.dbo.Node AS ND 
RIGHT OUTER JOIN dbo.CDR ON ND.node_id = dbo.CDR.node_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.CarrierAcct AS CA ON dbo.CDR.carrier_acct_id = CA.carrier_acct_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.Partner AS TPT ON CA.partner_id = TPT.partner_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.CustomerAcct AS CU ON dbo.CDR.customer_acct_id = CU.customer_acct_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.Partner AS OPT ON CU.partner_id = OPT.partner_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.EndPoint AS TEP ON dbo.CDR.term_end_point_id = TEP.end_point_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.EndPoint AS OEP ON dbo.CDR.orig_end_point_id = OEP.end_point_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.Route AS CRR ON dbo.CDR.carrier_route_id = CRR.route_id 
LEFT OUTER JOIN 
RbrDb_269.dbo.Route AS CUR ON dbo.CDR.customer_route_id = CUR.route_id
'
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[R_1]') AND parent_object_id = OBJECT_ID(N'[dbo].[CDR]'))
ALTER TABLE [dbo].[CDR]  WITH CHECK ADD  CONSTRAINT [R_1] FOREIGN KEY([id])
REFERENCES [dbo].[CDRIdentity] ([id])
GO
ALTER TABLE [dbo].[CDR] CHECK CONSTRAINT [R_1]
GO


