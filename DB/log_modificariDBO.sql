/****** Object:  Table [dbo].[log_modificari]    Script Date: 07.06.2025 21:13:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[log_modificari](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cnp_doctor] [char](13) NOT NULL,
	[tabela_modificata] [varchar](50) NOT NULL,
	[coloana_modificata] [varchar](50) NOT NULL,
	[valoare_veche] [varchar](50) NULL,
	[valoare_noua] [varchar](50) NULL,
	[data_modificare] [datetime2](3) NOT NULL,
	[operatie] [varchar](50) NOT NULL,
	[detalii] [varchar](100) NULL,
 CONSTRAINT [PK_logs_modificari] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[log_modificari]  WITH CHECK ADD  CONSTRAINT [FK_logs_modificari_utilizatori] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[log_modificari] CHECK CONSTRAINT [FK_logs_modificari_utilizatori]
GO

