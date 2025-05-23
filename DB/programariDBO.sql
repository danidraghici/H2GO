/****** Object:  Table [dbo].[programari]    Script Date: 23.05.2025 19:12:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[programari](
	[id] [uniqueidentifier] NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[cnp_doctor] [char](13) NOT NULL,
	[data_programare] [date] NOT NULL,
	[status] [varchar](50) NOT NULL,
	[comentarii] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[programari]  WITH CHECK ADD  CONSTRAINT [FK_CNP_PACIENT_PROGRAMARE] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[programari] CHECK CONSTRAINT [FK_CNP_PACIENT_PROGRAMARE]
GO

ALTER TABLE [dbo].[programari]  WITH CHECK ADD  CONSTRAINT [FK_programari_utilizatori] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[programari] CHECK CONSTRAINT [FK_programari_utilizatori]
GO

