/****** Object:  Table [dbo].[programari]    Script Date: 08.06.2025 18:40:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[programari](
	[cnp_pacient] [char](13) NOT NULL,
	[cnp_doctor] [char](13) NOT NULL,
	[data_programare] [date] NOT NULL,
	[status] [varchar](50) NOT NULL,
	[comentarii] [text] NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_programari] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[programari]  WITH CHECK ADD  CONSTRAINT [FK_programari_pacienti] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[programari] CHECK CONSTRAINT [FK_programari_pacienti]
GO

ALTER TABLE [dbo].[programari]  WITH CHECK ADD  CONSTRAINT [FK_programari_utilizatori] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[programari] CHECK CONSTRAINT [FK_programari_utilizatori]
GO

