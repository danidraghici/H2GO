/****** Object:  Table [dbo].[praguri_masuratori]    Script Date: 08.06.2025 18:33:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[praguri_masuratori](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[limita_minima_puls] [numeric](10, 2) NOT NULL,
	[limita_maxima_puls] [numeric](10, 2) NOT NULL,
	[limita_minima_temperatura] [numeric](10, 2) NOT NULL,
	[limita_maxima_temperatura] [numeric](10, 2) NOT NULL,
	[limita_minima_ekg] [numeric](10, 2) NOT NULL,
	[limita_maxima_ekg] [numeric](10, 2) NOT NULL,
	[cnp_medic] [char](13) NOT NULL,
	[limita_minima_umiditate] [numeric](10, 2) NOT NULL,
	[limita_maxima_umiditate] [numeric](10, 2) NOT NULL,
 CONSTRAINT [PK_praguri_masuratori] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[praguri_masuratori]  WITH CHECK ADD  CONSTRAINT [FK_praguri_masuratori_pacienti] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[praguri_masuratori] CHECK CONSTRAINT [FK_praguri_masuratori_pacienti]
GO

ALTER TABLE [dbo].[praguri_masuratori]  WITH CHECK ADD  CONSTRAINT [FK_praguri_masuratori_utilizatori] FOREIGN KEY([cnp_medic])
REFERENCES [dbo].[utilizatori] ([CNP])
GO

ALTER TABLE [dbo].[praguri_masuratori] CHECK CONSTRAINT [FK_praguri_masuratori_utilizatori]
GO

