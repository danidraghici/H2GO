/****** Object:  Table [dbo].[masuratori]    Script Date: 21.05.2025 18:12:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[masuratori](
	[id] [int] NOT NULL,
	[cnp_pacient] [char](13) NOT NULL,
	[tip_masurare] [varchar](100) NOT NULL,
	[valoare] [numeric](10, 2) NOT NULL,
	[data_masurare] [date] NOT NULL,
 CONSTRAINT [PK_masuratori] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[masuratori]  WITH CHECK ADD  CONSTRAINT [FK_CNP_Masurare] FOREIGN KEY([cnp_pacient])
REFERENCES [dbo].[pacienti] ([CNP])
GO

ALTER TABLE [dbo].[masuratori] CHECK CONSTRAINT [FK_CNP_Masurare]
GO

