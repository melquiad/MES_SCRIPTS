--------------- insertion dans abmode ------------------------

INSERT INTO metaifn.abmode (unite, "mode", libelle, definition)
VALUES 
('CODESP', '8000', 'Bryophyta', 'Bryophyta'),
('CODESP', '2052', 'Heliopsis helianthoides', 'Heliopsis helianthoides'),
('CODESP', '9500', 'Carex (grands hygrophiles)', 'Carex (grands hygrophiles)'),
('CODESP', '1206', 'Convolvulus pubescens', 'Convolvulus pubescens'),
('CODESP', '3100', 'Paeonia albiflora', 'Paeonia albiflora'),
('CODESP', '8062', 'Cladoniaceae', 'Cladoniaceae'),
('CODESP', '8005', 'Lichens', 'Lichens'),
('CODESP', '8102', 'Globulariaceae', 'Globulariaceae'),
('CODESP', '3750', 'Ruta tuberculata', 'Ruta tuberculata'),
('CODESP', '8880', 'Ligusticum', 'Ligusticum');

--------------- insertion dans abgroupe ------------------------

INSERT INTO metaifn.abgroupe (unite, "mode", gunite, gmode)
VALUES ('CODESP', '8000', 'CDREF13', '187105'),
('CODESP', '2052', 'CDREF13', '187227'),
('CODESP', '9500', 'CDREF13', '190355'),
('CODESP', '1206', 'CDREF13', '191107'),
('CODESP',	'3100', 'CDREF13', '195673'),
('CODESP',	'8062', 'CDREF13', '443238'),
('CODESP',	'8005', 'CDREF13', '443238'),
('CODESP',	'8102', 'CDREF13', '525386'),
('CODESP',	'3750', 'CDREF13', '611163'),
('CODESP',	'8880', 'CDREF13', '715622');