/****** Object:  Table [dbo].[masuratori]    Script Date: 08.06.2025 18:31:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[masuratori](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[masurare_ekg] [numeric](10, 2) NOT NULL,
	[masurare_puls] [numeric](10, 2) NOT NULL,
	[masurare_umiditate] [numeric](10, 2) NOT NULL,
	[masurare_temperatura] [numeric](10, 2) NOT NULL,
	[data_masurare] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_masurare] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[masuratori]  WITH CHECK ADD  CONSTRAINT [FK_masurare_pacienti] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[masuratori] CHECK CONSTRAINT [FK_masurare_pacienti]
GO

