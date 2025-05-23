/****** Object:  Table [dbo].[consultatii]    Script Date: 23.05.2025 19:08:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[consultatii](
	[id] [uniqueidentifier] NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[cnp_doctor] [char](13) NOT NULL,
	[data_consultatie] [date] NOT NULL,
	[tip_consultatie] [varchar](100) NOT NULL,
	[diagnostic_preliminar] [text] NOT NULL,
	[observatii] [text] NULL,
	[recomandari] [text] NULL,
 CONSTRAINT [PK_consultatii] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[consultatii]  WITH CHECK ADD  CONSTRAINT [FK_consultatii_pacienti] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[consultatii] CHECK CONSTRAINT [FK_consultatii_pacienti]
GO

ALTER TABLE [dbo].[consultatii]  WITH CHECK ADD  CONSTRAINT [FK_consultatii_utilizatori] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[consultatii] CHECK CONSTRAINT [FK_consultatii_utilizatori]
GO

