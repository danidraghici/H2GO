/****** Object:  Table [dbo].[utilizatori]    Script Date: 08.06.2025 18:40:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[utilizatori](
	[id] [uniqueidentifier] NOT NULL,
	[username] [varchar](100) NOT NULL,
	[parola_hash] [varchar](255) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[telefon] [varchar](20) NOT NULL,
	[rol] [varchar](50) NOT NULL,
	[id_permisiune] [int] NOT NULL,
	[data_crearii] [date] NOT NULL,
	[ultima_logare] [date] NOT NULL,
	[CNP] [char](13) NOT NULL,
 CONSTRAINT [PK_utilizatori] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_utilizatori] UNIQUE NONCLUSTERED 
(
	[CNP] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[utilizatori]  WITH NOCHECK ADD  CONSTRAINT [FK_permisiune] FOREIGN KEY([id_permisiune])
REFERENCES [dbo].[permisiuni] ([id])
GO

ALTER TABLE [dbo].[utilizatori] CHECK CONSTRAINT [FK_permisiune]
GO

