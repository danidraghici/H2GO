/****** Object:  Table [dbo].[ingrijitori]    Script Date: 08.06.2025 18:30:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ingrijitori](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cnp_ingrijitor] [char](13) NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[creat_de] [char](13) NOT NULL,
	[data_start] [date] NOT NULL,
	[data_sfarsit] [date] NULL,
	[observatii] [text] NULL,
	[status] [varchar](50) NOT NULL,
	[data_creare] [datetime2](3) NOT NULL,
	[rol_ingrijitor] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ingrijitori] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ingrijitori]  WITH CHECK ADD  CONSTRAINT [FK_ingrijitori_pacienti] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[ingrijitori] CHECK CONSTRAINT [FK_ingrijitori_pacienti]
GO

ALTER TABLE [dbo].[ingrijitori]  WITH CHECK ADD  CONSTRAINT [FK_ingrijitori_utilizatori] FOREIGN KEY([cnp_ingrijitor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[ingrijitori] CHECK CONSTRAINT [FK_ingrijitori_utilizatori]
GO

ALTER TABLE [dbo].[ingrijitori]  WITH CHECK ADD  CONSTRAINT [FK_ingrijitori_utilizatori1] FOREIGN KEY([creat_de])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[ingrijitori] CHECK CONSTRAINT [FK_ingrijitori_utilizatori1]
GO

