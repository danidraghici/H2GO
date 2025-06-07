/****** Object:  Table [dbo].[log_modificari]    Script Date: 07.06.2025 11:45:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[log_modificari](
	[id_modificare] [int] IDENTITY(1,1) NOT NULL,
	[id_utilizator] [uniqueidentifier] NOT NULL,
	[tabela_modificata] [varchar](50) NOT NULL,
	[coloana_modificata] [varchar](50) NOT NULL,
	[valoare_veche] [varchar](100) NULL,
	[valoare_noua] [varchar](100) NULL,
	[data_modificare] [datetime2](3) NOT NULL,
	[operatie] [varchar](50) NOT NULL,
	[detalii] [varchar](100) NULL,
 CONSTRAINT [PK_log_modificari] PRIMARY KEY CLUSTERED 
(
	[id_modificare] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[log_modificari]  WITH CHECK ADD  CONSTRAINT [FK_ID_UTILIZATOR_LOGS] FOREIGN KEY([id_utilizator])
REFERENCES [dbo].[utilizatori] ([id])
GO

ALTER TABLE [dbo].[log_modificari] CHECK CONSTRAINT [FK_ID_UTILIZATOR_LOGS]
GO

