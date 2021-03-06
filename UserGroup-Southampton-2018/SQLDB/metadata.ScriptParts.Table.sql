USE [sdbamsdapdev001]
GO
/****** Object:  Table [metadata].[ScriptParts]    Script Date: 06/06/2018 14:51:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [metadata].[ScriptParts](
	[ScriptId] [int] IDENTITY(1,1) NOT NULL,
	[ScriptName] [varchar](128) NOT NULL,
	[Script] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ScriptParts] PRIMARY KEY CLUSTERED 
(
	[ScriptId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
