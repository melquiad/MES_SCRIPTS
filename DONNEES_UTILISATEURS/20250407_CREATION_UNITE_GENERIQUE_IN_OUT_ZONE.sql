
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('IN_ZONE', 'IFN', 'NOMINAL', $$Points à l'intérieur ou à l'extérieur de la zone$$, $$Précise si un point est à l'intérieur ou à l'extérieur de la zone$$);

INSERT INTO metaifn.abmode(unite, mode, libelle, definition, position)
VALUES ('IN_ZONE', '0','Points hors zone','Points hors zone', 0)
, ('IN_ZONE', '1','Points dans la zone','Points dans la zone', 1);


UPDATE metaifn.abmode
SET position = 2 WHERE unite = 'IN_ZONE' AND mode = '1'; 

UPDATE metaifn.abmode
SET position = 1 WHERE unite = 'IN_ZONE' AND mode = '0';


-----------------------------------------------------------------------------------------------------------------------------------------------------
