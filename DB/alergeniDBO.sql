/****** Object:  Table [dbo].[alergeni]    Script Date: 08.06.2025 18:28:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[alergeni](
	[id] [uniqueidentifier] NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[substanta] [varchar](100) NOT NULL,
	[status] [varchar](50) NOT NULL,
	[data_inregistrare] [date] NOT NULL,
	[cnp_doctor] [char](13) NOT NULL,
 CONSTRAINT [PK_alergeni] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[alergeni]  WITH CHECK ADD  CONSTRAINT [FK_CNP_DOCTOR_ALERGENI] FOREIGN KEY([cnp_doctor])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[alergeni] CHECK CONSTRAINT [FK_CNP_DOCTOR_ALERGENI]
GO

