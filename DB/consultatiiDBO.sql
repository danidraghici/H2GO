/****** Object:  Table [dbo].[consultatii]    Script Date: 08.06.2025 18:29:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[consultatii](
	[id_consultatie] [int] IDENTITY(1,1) NOT NULL,
	[id_programare] [int] NOT NULL,
	[diagnostic] [text] NOT NULL,
	[tratament] [text] NOT NULL,
	[recomandari] [text] NOT NULL,
	[data_consultatie] [datetime2](3) NOT NULL,
	[observatii] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_consultatie] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[consultatii]  WITH CHECK ADD FOREIGN KEY([id_programare])
REFERENCES [dbo].[programari] ([id])
GO

