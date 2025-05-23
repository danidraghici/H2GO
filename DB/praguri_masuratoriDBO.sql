/****** Object:  Table [dbo].[praguri_masuratori]    Script Date: 23.05.2025 18:29:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[praguri_masuratori](
	[id] [int] NOT NULL,
	[tip_masurare] [varchar](100) NOT NULL,
	[limita_minima] [numeric](10, 2) NOT NULL,
	[limita_maxima] [numeric](10, 2) NOT NULL,
 CONSTRAINT [PK_praguri_masuratori] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

