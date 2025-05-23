/****** Object:  Table [dbo].[probleme_sanatate]    Script Date: 23.05.2025 19:09:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[probleme_sanatate](
	[id] [uniqueidentifier] NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[cnp_doctor] [char](13) NOT NULL,
	[diagnostic] [varchar](100) NOT NULL,
	[cod_diagnostic] [varchar](50) NOT NULL,
	[status] [varchar](50) NOT NULL,
	[data_start] [date] NOT NULL,
	[data_sfarsit] [date] NOT NULL,
	[data_creare] [date] NOT NULL,
 CONSTRAINT [PK_probleme_sanatate] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[probleme_sanatate]  WITH CHECK ADD  CONSTRAINT [FK_probleme_sanatate_pacienti] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[probleme_sanatate] CHECK CONSTRAINT [FK_probleme_sanatate_pacienti]
GO

ALTER TABLE [dbo].[probleme_sanatate]  WITH CHECK ADD  CONSTRAINT [FK_probleme_sanatate_utilizatori] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[probleme_sanatate] CHECK CONSTRAINT [FK_probleme_sanatate_utilizatori]
GO

