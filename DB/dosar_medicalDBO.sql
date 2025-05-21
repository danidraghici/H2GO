/****** Object:  Table [dbo].[dosar_medical]    Script Date: 21.05.2025 18:11:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dosar_medical](
	[id_dosar] [uniqueidentifier] NOT NULL,
	[id_medic] [uniqueidentifier] NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[problema_sanatate] [text] NOT NULL,
	[status] [varchar](50) NOT NULL,
	[data_inregistrare] [date] NOT NULL,
	[versiune] [int] NOT NULL,
	[sters] [bit] NOT NULL,
 CONSTRAINT [PK_dosar_medical] PRIMARY KEY CLUSTERED 
(
	[id_dosar] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[dosar_medical]  WITH CHECK ADD  CONSTRAINT [FK_CNP] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[dosar_medical] CHECK CONSTRAINT [FK_CNP]
GO

ALTER TABLE [dbo].[dosar_medical]  WITH CHECK ADD  CONSTRAINT [FK_Medic] FOREIGN KEY([id_medic])
REFERENCES [dbo].[utilizatori] ([id])
GO

ALTER TABLE [dbo].[dosar_medical] CHECK CONSTRAINT [FK_Medic]
GO

