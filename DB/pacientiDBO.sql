/****** Object:  Table [dbo].[pacienti]    Script Date: 09.06.2025 12:12:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[pacienti](
	[CNP] [char](13) NOT NULL,
	[Nume] [varchar](100) NOT NULL,
	[Prenume] [varchar](100) NOT NULL,
	[Sex] [char](1) NOT NULL,
	[Data_nasterii] [date] NOT NULL,
	[Adresa] [varchar](100) NOT NULL,
	[Telefon] [varchar](20) NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[Status_activ] [bit] NOT NULL,
	[CNP_medic] [char](13) NOT NULL,
 CONSTRAINT [PK_pacienti] PRIMARY KEY CLUSTERED 
(
	[CNP] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[pacienti]  WITH CHECK ADD  CONSTRAINT [FK_pacienti_utilizatori] FOREIGN KEY([CNP])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[pacienti] CHECK CONSTRAINT [FK_pacienti_utilizatori]
GO

