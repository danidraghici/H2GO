/****** Object:  Table [dbo].[medicatie_curenta]    Script Date: 07.06.2025 22:50:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[medicatie_curenta](
	[cnp_doctor] [char](13) NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[denumire_medicament] [varchar](100) NOT NULL,
	[forma_farmaceutica] [varchar](100) NOT NULL,
	[posologie] [text] NULL,
	[data_incepere] [date] NOT NULL,
	[data_ultima_prescriere] [date] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_nume_tabela] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[medicatie_curenta]  WITH CHECK ADD  CONSTRAINT [FK_CNP_DOCTOR_MEDICATIE] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[medicatie_curenta] CHECK CONSTRAINT [FK_CNP_DOCTOR_MEDICATIE]
GO

