/****** Object:  Table [dbo].[istoric_medicatie]    Script Date: 23.05.2025 18:57:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[istoric_medicatie](
	[id] [uniqueidentifier] NOT NULL,
	[cnp_doctor] [char](13) NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[denumire_medicament] [varchar](100) NOT NULL,
	[forma_farmaceutica] [varchar](100) NOT NULL,
	[posologie] [varchar](50) NOT NULL,
	[data_incepere] [date] NOT NULL,
	[data_finalizare] [date] NOT NULL,
	[motiv_intrerupere] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[istoric_medicatie]  WITH CHECK ADD  CONSTRAINT [FK_CNP_DOCTOR_MEDICATIE_ISTORIC] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[istoric_medicatie] CHECK CONSTRAINT [FK_CNP_DOCTOR_MEDICATIE_ISTORIC]
GO

ALTER TABLE [dbo].[istoric_medicatie]  WITH CHECK ADD  CONSTRAINT [FK_CNP_PACIENT_MEDICATIE_ISTORIC] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[istoric_medicatie] CHECK CONSTRAINT [FK_CNP_PACIENT_MEDICATIE_ISTORIC]
GO

