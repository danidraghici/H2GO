/****** Object:  Table [dbo].[permisiuni]    Script Date: 08.06.2025 18:33:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[permisiuni](
	[id] [int] NOT NULL,
	[nume_permisiune] [varchar](50) NOT NULL,
	[descriere] [text] NOT NULL,
 CONSTRAINT [PK_permisiuni] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

