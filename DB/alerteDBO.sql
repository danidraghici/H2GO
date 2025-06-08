/****** Object:  Table [dbo].[alerte]    Script Date: 08.06.2025 23:15:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[alerte](
	[cnp_pacient] [char](13) NOT NULL,
	[masurare_id] [int] NOT NULL,
	[mesaj] [text] NOT NULL,
	[severitate] [varchar](50) NOT NULL,
	[status] [varchar](50) NOT NULL,
	[data_generare] [datetime2](3) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_alerte] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[alerte]  WITH CHECK ADD  CONSTRAINT [FK_alerte_masuratori] FOREIGN KEY([masurare_id])
REFERENCES [dbo].[masuratori] ([id])
GO

ALTER TABLE [dbo].[alerte] CHECK CONSTRAINT [FK_alerte_masuratori]
GO

ALTER TABLE [dbo].[alerte]  WITH CHECK ADD  CONSTRAINT [FK_alerte_pacienti] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[alerte] CHECK CONSTRAINT [FK_alerte_pacienti]
GO

