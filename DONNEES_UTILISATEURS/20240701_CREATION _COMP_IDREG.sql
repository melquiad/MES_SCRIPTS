-- Documentation dans MetaIFN

--- creation unite
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('COMP_IDREG', 'IFN', 'NOMINAL', 'Partition idéalisée et régionalisée de la composition', 'Partition idéalisée et régionalisée de la composition en espèces ligneuses des forêts françaises');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('COMP_IDREG', 'F1.1', 1, 1, 1, 'Chêne pédonculé pur/avec feuillus', $$Chêne pédonculé pur/avec feuillus (autres que châtaignier pour greco F, hêtre pour greco A, hêtre/charme/frêne pour greco B/C$$)
, ('COMP_IDREG', 'F1.2', 2, 2, 1, 'Chêne pédonculé avec feuillus', $$Chêne pédonculé avec feuillus$$)
, ('COMP_IDREG', 'F1.3', 3, 3, 1, 'Chêne pédonculé', $$Chêne pédonculé$$)
, ('COMP_IDREG', 'F2', 4, 4, 1, 'Frêne pur/avec feuillus', $$Frêne pur/avec feuillus$$)
, ('COMP_IDREG', 'F3', 5, 5, 1, 'Chêne pubescent', $$Chêne pubescent$$)
, ('COMP_IDREG', 'F4', 6, 6, 1, 'Chêne sessile', $$Chêne sessile$$)
, ('COMP_IDREG', 'F5', 7, 7, 1, 'Charme pur/avec chênes (+feuillus)', $$Charme pur/avec chênes (+feuillus)$$)
, ('COMP_IDREG', 'F6.1', 8, 8, 1, 'Hêtre', $$Hêtre$$)
, ('COMP_IDREG', 'F6.2', 9, 9, 1, 'Hêtre et chênes (+feuillus)', $$Hêtre et chênes (+feuillus)$$)
, ('COMP_IDREG', 'F6.3', 10, 10, 1, 'Hêtre pur/avec chênes (+feuillus)', $$Hêtre pur/avec chênes (+feuillus)$$)
, ('COMP_IDREG', 'F7.1', 11, 11, 1, 'Chêne vert', $$Chêne vert$$)
, ('COMP_IDREG', 'F7.2', 12, 12, 1, 'Chêne vert et feuillus', $$Chêne vert et feuillus$$)
, ('COMP_IDREG', 'F8.1', 13, 13, 1, 'Châtaignier pur/avec feuillus', $$Châtaignier pur/avec feuillus (essentiellement chênes)$$)
, ('COMP_IDREG', 'F8.2', 14, 14, 1, 'Châtaignier', $$Châtaignier$$)
, ('COMP_IDREG', 'F9', 15, 15, 1, 'Chênes vert/pubescent', $$Chênes vert/pubescent$$)
, ('COMP_IDREG', 'R1', 16, 16, 1, 'Pin maritime', $$Pin maritime$$)
, ('COMP_IDREG', 'R2', 17, 17, 1, 'Pin sylvestre', $$Pin sylvestre$$)
, ('COMP_IDREG', 'R3', 18, 18, 1, 'Epicéa commun', $$Epicéa commun$$)
, ('COMP_IDREG', 'R4', 19, 19, 1, 'Sapin pectiné', $$Sapin pectiné$$)
, ('COMP_IDREG', 'R5', 20, 20, 1, 'Pins', $$Pins : pin maritime, sylvestre et laricio (et noir pour greco B)$$)
, ('COMP_IDREG', 'R6', 21, 21, 1, 'Douglas', $$Douglas$$)
, ('COMP_IDREG', 'R7', 22, 22, 1, 'Pin d’Alep', $$Pin d’Alep$$)
, ('COMP_IDREG', 'R8', 23, 23, 1, 'Mélèze', $$Mélèze$$)
, ('COMP_IDREG', 'R9', 24, 24, 1, 'Epicéa commun/sapin pectiné', $$Epicéa commun/sapin pectiné$$)
, ('COMP_IDREG', 'R10', 25, 25, 1, 'Pin noir', $$Pin noir$$)
, ('COMP_IDREG', 'R11', 26, 26, 1, 'Pin laricio', $$Pin laricio$$)
, ('COMP_IDREG', 'M1', 27, 27, 1, 'Pin sylvestre et feuillus', $$Pin sylvestre et feuillus$$)
, ('COMP_IDREG', 'M2', 28, 28, 1, 'Hêtre et sapin pectiné ou épicéa commun (+autres)', $$Hêtre et sapin pectiné ou épicéa commun (+autres essences)$$)
, ('COMP_IDREG', 'M3', 29, 29, 1, 'Chênes et pins', $$Chênes et pins$$)
, ('COMP_IDREG', 'F0', 30, 30, 1, 'Divers feuillus', $$Divers feuillus$$)
, ('COMP_IDREG', 'M0', 31, 31, 1, 'Divers mixtes', $$Divers mixtes$$)
, ('COMP_IDREG', 'R0', 32, 32, 1, 'Divers résineux', $$Divers résineux$$)
, ('COMP_IDREG', 'I', 33, 33, 1, 'Indéterminée ou marginale', $$Composition indéterminée ou marginale$$);


--- partie donnee
SELECT * FROM metaifn.ajoutdonnee('COMP_IDREG', NULL, 'COMP_IDREG', 'IFN', NULL, 33, 'char(4)', 'CC', TRUE, TRUE,
'Partition idéalisée et régionalisée de la composition', 'Partition idéalisée et régionalisée de la composition en espèces ligneuses des forêts françaises');


--- partie champ
SELECT * FROM metaifn.ajoutchamp('COMP_IDREG', 'G3FORET', 'INV_EXP_NM', FALSE, 0, 17, 'bpchar', 4);
SELECT * FROM metaifn.ajoutchamp('COMP_IDREG', 'P3POINT', 'INV_EXP_NM', FALSE, 0, 17, 'bpchar', 4);


--- creation du champ dans la table
ALTER TABLE inv_exp_nm.g3foret ADD COLUMN comp_idreg CHAR(4);
ALTER TABLE inv_exp_nm.p3point ADD COLUMN comp_idreg CHAR(4);
   
   	
--- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'COMP_IDREG');


--- controle
SELECT *
FROM metaifn.afchamp
WHERE famille='INV_EXP_NM'
AND format='TG3FORET'
ORDER BY POSITION DESC;


--- controle : la colonne est disponible et vide au debut, complétée a la fin
SELECT npp, comp_idreg
FROM inv_exp_nm.g3foret
WHERE comp_idreg IS NOT NULL
;

-- Recopie de la donnée depuis u_g3foret vers g3_foret et depuis u_p3point vers p3point, pour les incref 0 à 17

UPDATE inv_exp_nm.g3foret g
SET comp_idreg = ug.u_comp_idreg
FROM inv_exp_nm.u_g3foret ug
WHERE ug.npp = g.npp
AND g.incref <= 17;

UPDATE inv_exp_nm.p3point p
SET comp_idreg = up.u_comp_idreg
FROM inv_exp_nm.u_p3point up
WHERE up.npp = p.npp
AND p.incref <= 17;



-- MAJ incref 18
BEGIN;

UPDATE inv_exp_nm.g3foret uf
SET comp_idreg = 
CASE 
	WHEN greco = 'A' AND uf.comp_r IN ('CHP', 'DIVCHP1', 'BETCHP1', 'CASCHP1', 'CHPCHS', 'FRECHP1', 'CASCHP2', 'FRECHP2', 'CHPFS', 'DIVCHP2'
	, 'CHACHP1', 'CHACHP2', 'CHPCHB') THEN 'F1.1'
	WHEN greco = 'A' AND uf.comp_r IN ('CHS') THEN 'F4'
	WHEN greco = 'A' AND uf.comp_r IN ('HETCHP1', 'HETCHS1', 'HET', 'HETCHP2', 'HETCHS2', 'HETCHM1', 'HETCHM2') THEN 'F6.3'
	WHEN greco = 'A' AND uf.comp_r IN ('PMAR', 'PLAR', 'PSYL') THEN 'R5'
	WHEN greco = 'A' AND uf.comp_r IN ('FIND', 'DIVF2', 'CAS', 'PEU', 'BET', 'CASCHS1', 'FREDIV1', 'BETCHS1', 'CASCHM1'
	, 'FREDIV2', 'FRE', 'DIVF3', 'BETCHM1', 'CHACHS1', 'FREHET', 'HETFS', 'DIVF4', 'CHACHM1', 'CHA', 'FRECHS2', 'CHMFS', 'ROB', 'CASCHS2', 'DIVF5'
	, 'DIVCHM1', 'FREERA', 'CHACHS2', 'DIVCHS1', 'CHB', 'CASFS', 'CHSFS', 'FRECHS1', 'FEXO', 'FREFS', 'YEUCHD', 'CHACHM2', 'CHM') THEN 'F0'
	WHEN greco = 'A' AND uf.comp_r IN ('FR2', 'CHMPMAR', 'FR3', 'PMARF2', 'CHMPSYL', 'PMARF1', 'PSYLF2', 'FR5', 'PSYLF1', 'HETSAPIM', 'FR4'
	, 'HETSAPIP', 'HETPESSP', 'HETPESSM') THEN 'M0'
	WHEN greco = 'A' AND uf.comp_r IN ('CIND', 'DOUG', 'DIVR2', 'PSYLR', 'SPEC', 'EPIC', 'CEXO', 'MELZ', 'DIVR3P', 'SAPIPESS') THEN 'R0'
	WHEN greco = 'A' THEN 'I'
	WHEN greco = 'B' AND uf.comp_r IN ('CHP', 'CHPCHS', 'DIVCHP1', 'BETCHP1', 'CHPFS', 'CASCHP1', 'CHPCHB', 'CASCHP2', 'DIVCHP2') THEN 'F1.1'
	WHEN greco = 'B' AND uf.comp_r IN ('FRECHP2', 'FRE', 'FREERA', 'FREDIV1', 'FRECHP1', 'FREDIV2', 'FREHET', 'FREFS', 'FRECHS2', 'FRECHS1'
	, 'FRECHM1', 'FRECHB2', 'FRECHB1') THEN 'F2'
	WHEN greco = 'B' AND uf.comp_r IN ('CHS') THEN 'F4'
	WHEN greco = 'B' AND uf.comp_r IN ('CHACHP1', 'CHACHS1', 'CHACHM1', 'CHACHP2', 'CHA', 'CHACHS2', 'CHACHM2', 'CHACHB1', 'CHACHB2') THEN 'F5'
	WHEN greco = 'B' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'B' AND uf.comp_r IN ('HETCHS1', 'HETCHP2', 'HETCHP1', 'HETCHS2', 'HETCHM1', 'HETCHM2') THEN 'F6.2'
	WHEN greco = 'B' AND uf.comp_r IN ('DIVF2', 'PEU', 'FIND', 'CAS', 'CASCHS1', 'BET', 'CHB', 'DIVF3', 'BETCHS1', 'ROB', 'DIVCHS1', 'HETFS'
	, 'CASCHS2', 'CASCHM1', 'CHSCHB', 'CHSFS', 'FRECHM2', 'BETCHM1', 'CHMFS', 'CASCHM2', 'CASFS', 'DIVCHB1', 'DIVCHM1', 'DIVCHS2', 'CHM', 'DIVF4', 'DIVF5'
	, 'CASCHB1', 'ROBFS', 'DIVCHB2', 'CHBFS', 'CASCHB2', 'BETCHB1', 'FEXO') THEN 'F0'
	WHEN greco = 'B' AND uf.comp_r IN ('CHMPSYL', 'FR2', 'PSYLF1', 'FR3', 'CHMPMAR', 'PMARF1', 'PMARF2', 'FR5', 'FR4', 'HETSAPIM', 'HETPESSM', 'HETSAPIP', 'PSYLF2') THEN 'M0'
	WHEN greco = 'B' AND uf.comp_r IN ('PSYL', 'PMAR', 'PLAR', 'PNIG') THEN 'R5'
	WHEN greco = 'B' AND uf.comp_r IN ('DOUG', 'PSYLR', 'EPIC', 'DIVR2', 'CIND', 'SPEC', 'MELZ', 'CEXO', 'SAPIPESS') THEN 'R0'
	WHEN greco = 'B' THEN 'I'
	WHEN greco = 'C' AND uf.comp_r IN ('CHP', 'CHPCHS', 'DIVCHP1', 'BETCHP1', 'CHPFS', 'DIVCHP2', 'CASCHP2', 'CASCHP1', 'CHPCHB') THEN 'F1.1'
	WHEN greco = 'C' AND uf.comp_r IN ('FRECHP2', 'FREDIV1', 'FREHET', 'FRE', 'FREERA', 'FRECHS2', 'FRECHP1', 'FREDIV2', 'FREFS', 'FRECHS1'
	, 'FRECHM2', 'FRECHM1', 'FRECHB2', 'FRECHB1') THEN 'F2'
	WHEN greco = 'C' AND uf.comp_r IN ('CHS') THEN 'F4'
	WHEN greco = 'C' AND uf.comp_r IN ('CHACHP1', 'CHACHS1', 'CHACHP2', 'CHA', 'CHACHS2', 'CHACHM1', 'CHACHM2', 'CHACHB1', 'CHACHB2') THEN 'F5'
	WHEN greco = 'C' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'C' AND uf.comp_r IN ('HETCHS1', 'HETCHS2', 'HETCHP2', 'HETCHP1', 'HETCHM2', 'HETCHM1', 'HETCHB1', 'HETCHB2') THEN 'F6.2'
	WHEN greco = 'C' AND uf.comp_r IN ('DIVF2', 'HETFS', 'DIVF3', 'FIND', 'CAS', 'PEU', 'ROB', 'DIVCHS1', 'BETCHS1', 'CHB', 'CASCHS1', 'BET', 'CHMFS', 'CASCHS2'
	, 'CHSCHB', 'DIVCHS2', 'CHSFS', 'DIVF5', 'DIVF4', 'DIVCHB1', 'DIVCHM1', 'CASFS', 'BETCHM1', 'DIVCHB2', 'ROBFS', 'CHM', 'CHBFS', 'CASCHB1', 'YEU') THEN 'F0'
	WHEN greco = 'C' AND uf.comp_r IN ('FR2', 'FR3', 'PSYLF2', 'FR5', 'CHMPSYL', 'HETPESSM', 'PSYLF1', 'HETSAPIM', 'FR4', 'HETPESSP', 'HETSAPIP', 'HETSAPPES', 'PMARF1') THEN 'M0'
	WHEN greco = 'C' AND uf.comp_r IN ('EPIC', 'PSYL', 'DOUG', 'PNIG', 'SPEC', 'PSYLR', 'DIVR2', 'MELZ', 'SAPIPESS', 'CIND', 'PLAR', 'CEXO', 'DIVR3P') THEN 'R0'
	WHEN greco = 'C' THEN 'I'
	WHEN greco = 'D' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'D' AND uf.comp_r IN ('HETCHS1', 'HETCHS2', 'HETCHP1', 'HETCHP2', 'HETCHM1', 'HETCHM2') THEN 'F6.2'
	WHEN greco = 'D' AND uf.comp_r IN ('CHS', 'DIVF2', 'FIND', 'BET', 'CHACHS1', 'CHP', 'FREERA', 'HETFS', 'FRE', 'FREDIV1', 'ROB', 'FRECHS2', 'DIVF3', 'BETCHP1', 'CAS'
	, 'CHACHP1', 'FREHET', 'CHACHP2', 'FRECHP2', 'FREFS', 'FREDIV2', 'FRECHP1', 'CASCHS2', 'CHA', 'CHPCHS', 'CASCHS1', 'BETCHS1', 'CHPFS', 'DIVCHP1', 'CHACHS2', 'DIVCHS1'
	, 'FRECHM2', 'FRECHS1', 'CHSFS', 'CASCHP1', 'BETCHM1', 'CHACHM2', 'DIVF5', 'DIVF4', 'PEU') THEN 'F0'
	WHEN greco = 'D' AND uf.comp_r IN ('HETSAPIP', 'HETSAPIM', 'HETSAPPES', 'HETPESSP', 'HETPESSM') THEN 'M2'
	WHEN greco = 'D' AND uf.comp_r IN ('FR2', 'FR3', 'PSYLF1', 'PSYLF2', 'CHMPSYL', 'FR5', 'FR4') THEN 'M0'
	WHEN greco = 'D' AND uf.comp_r IN ('EPIC') THEN 'R3'
	WHEN greco = 'D' AND uf.comp_r IN ('SPEC') THEN 'R4'
	WHEN greco = 'D' AND uf.comp_r IN ('SAPIPESS') THEN 'R9'
	WHEN greco = 'D' AND uf.comp_r IN ('PSYLR', 'PSYL', 'DOUG', 'DIVR2', 'MELZ') THEN 'R0'
	WHEN greco = 'D' THEN 'I'
	WHEN greco = 'E' AND uf.comp_r IN ('FRECHS2', 'FREHET', 'FRECHP2', 'FREERA', 'FRE', 'FREDIV1', 'FREFS', 'FREDIV2', 'FRECHS1', 'FRECHM2', 'FRECHB2', 'FRECHP1'
	, 'FRECHB1', 'FRECHM1') THEN 'F2'
	WHEN greco = 'E' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'E' AND uf.comp_r IN ('DIVF2', 'CHS', 'CHACHS1', 'HETCHS2', 'HETCHS1', 'CHACHP1', 'DIVCHS1', 'DIVF3', 'CHB', 'CHACHS2', 'CHACHP2', 'HETFS', 'FIND', 'CHP'
	, 'HETCHP2', 'DIVCHB1', 'CHA', 'ROB', 'CHSCHB', 'CHSFS', 'CHACHB1', 'CHACHM1', 'DIVCHS2', 'CHPCHS', 'DIVCHP1', 'DIVCHB2', 'HETCHM2', 'HETCHP1', 'CHACHM2', 'CHMFS'
	, 'CAS', 'HETCHB2', 'CHPFS', 'DIVCHP2', 'CASCHS1', 'CASCHS2', 'CHPCHB', 'CHBFS', 'HETCHB1', 'BET', 'DIVCHM1', 'BETCHP1', 'CHACHB2', 'ROBFS', 'BETCHS1', 'DIVF5', 'PEU') THEN 'F0'	
	WHEN greco = 'E' AND uf.comp_r IN ('HETSAPIP', 'HETPESSP', 'HETSAPPES', 'HETSAPIM', 'HETPESSM') THEN 'M2'
	WHEN greco = 'E' AND uf.comp_r IN ('FR3', 'FR2', 'FR5', 'PSYLF2', 'FR4', 'CHMPSYL', 'PSYLF1') THEN 'M0'
	WHEN greco = 'E' AND uf.comp_r IN ('EPIC') THEN 'R3'
	WHEN greco = 'E' AND uf.comp_r IN ('SPEC') THEN 'R4'
	WHEN greco = 'E' AND uf.comp_r IN ('SAPIPESS') THEN 'R9'
	WHEN greco = 'E' THEN 'I'
	WHEN greco = 'F' AND uf.comp_r IN ('CHP', 'CHPCHB', 'DIVCHP1', 'CHACHP1', 'FRECHP1', 'DIVCHP2', 'CHPFS', 'CHPCHS', 'FRECHP2', 'CHACHP2', 'HETCHP1', 'BETCHP1', 'HETCHP2') THEN 'F1.1'
	WHEN greco = 'F' AND uf.comp_r IN ('CHB') THEN 'F3'
	WHEN greco = 'F' AND uf.comp_r IN ('FIND', 'DIVCHB1', 'DIVF2', 'PEU', 'CHS', 'ROB', 'FRE', 'CHACHB1', 'CHA', 'FREDIV1', 'CHACHM1', 'DIVF3', 'CHSCHB', 'FREERA', 'FRECHB2'
	, 'DIVCHB2', 'FREDIV2', 'CHM', 'FRECHB1', 'CHMFS', 'YEUCHB', 'DIVCHM1', 'HET', 'CHACHS1', 'HETCHB1', 'YEUCHD', 'YEU', 'ROBFS', 'FRECHM1', 'FREFS', 'HETCHM1', 'YEUDIV'
	, 'CHBFS', 'DIVCHS1', 'CHACHB2', 'FRECHM2', 'BET', 'FRECHS1', 'HETFS', 'FRECHS2', 'CHACHM2', 'CHACHS2', 'HETCHS2', 'DIVF4', 'CHSFS', 'BETCHS1', 'HETCHS1', 'FREHET'
	, 'HETCHB2', 'HETCHM2', 'DIVCHS2', 'FEXO') THEN 'F0'
	WHEN greco = 'F' AND uf.comp_r IN ('CHMPMAR', 'PMARF2', 'PMARF1', 'FR2', 'FR3', 'CHMPSYL', 'PSYLF2', 'FR5', 'PSYLF1', 'FR4', 'CHMPALE', 'HETPESSM', 'HETSAPIP') THEN 'M0'
	WHEN greco = 'F' AND uf.comp_r IN ('PMAR') THEN 'R1'
	WHEN greco = 'F' AND uf.comp_r IN ('CAS', 'CASCHP1', 'CASCHP2', 'CASCHB1', 'CASCHM1', 'CASFS', 'CASCHS1', 'CASCHB2', 'CASCHM2', 'CASCHS2') THEN 'F8.1'
	WHEN greco = 'F' AND uf.comp_r IN ('PLAR', 'PNIG', 'PSYL', 'CIND', 'DOUG', 'PSYLR', 'DIVR2', 'EPIC', 'MELZ') THEN 'R0'
	WHEN greco = 'F' THEN 'I'
	WHEN greco = 'G' AND uf.comp_r IN ('CHP') THEN 'F1.3'	
	WHEN greco = 'G' AND uf.comp_r IN ('CASCHP1', 'HETCHP1', 'FRECHP2', 'HETCHP2', 'FRECHP1', 'BETCHP1', 'CASCHP2', 'CHACHP1', 'DIVCHP1', 'CHPCHS', 'CHPFS', 'CHACHP2', 'DIVCHP2'
	, 'CHPCHB') THEN 'F1.2'	
	WHEN greco = 'G' AND uf.comp_r IN ('CHB') THEN 'F3'	
	WHEN greco = 'G' AND uf.comp_r IN ('CHS') THEN 'F4'	
	WHEN greco = 'G' AND uf.comp_r IN ('HET') THEN 'F6.1'	
	WHEN greco = 'G' AND uf.comp_r IN ('CAS') THEN 'F8.2'	
	WHEN greco = 'G' AND uf.comp_r IN ('DIVF2', 'HETCHS1', 'YEU', 'FREDIV1', 'FIND', 'FRE', 'CASCHS1', 'YEUDIV', 'DIVF3', 'CASCHB1', 'FRECHS2', 'YEUCHB', 'FREDIV2', 'CHACHS1', 'BET'
	, 'FREHET', 'FRECHB1', 'FRECHS1', 'HETCHS2', 'FREERA', 'HETCHB1', 'ROB', 'HETFS', 'DIVCHB1', 'CHA', 'FRECHB2', 'HETCHM1', 'FREFS', 'DIVCHS1', 'CHSCHB', 'CASCHM1', 'PEU'
	, 'FRECHM1', 'CASFS', 'BETCHS1', 'CHSFS', 'FRECHM2', 'CHACHM1', 'CASCHB2', 'CASCHS2', 'YEUARB', 'DIVF5', 'CHBFS', 'CHACHS2', 'CASCHM2', 'HETCHM2', 'DIVCHM1', 'DIVF4', 'DIVCHB2'
	, 'CHACHB1', 'HETCHB2', 'CHMFS', 'DIVCHS2', 'BETCHM1', 'CHM', 'CHACHM2', 'CHACHB2') THEN 'F0'	
	WHEN greco = 'G' AND uf.comp_r IN ('PSYLF1', 'PSYLF2', 'CHMPSYL') THEN 'M1'	
	WHEN greco = 'G' AND uf.comp_r IN ('FR2', 'FR3', 'HETSAPIP', 'HETSAPIM', 'FR5', 'PMARF1', 'HETPESSP', 'CHMPMAR', 'HETPESSM', 'FR4', 'HETSAPPES', 'PMARF2') THEN 'M0'	
	WHEN greco = 'G' AND uf.comp_r IN ('PSYL') THEN 'R2'	
	WHEN greco = 'G' AND uf.comp_r IN ('EPIC') THEN 'R3'
	WHEN greco = 'G' AND uf.comp_r IN ('SPEC') THEN 'R4'	
	WHEN greco = 'G' AND uf.comp_r IN ('DOUG') THEN 'R6'	
	WHEN greco = 'G' AND uf.comp_r IN ('DIVR2', 'PSYLR', 'SAPIPESS', 'PLAR', 'PNIG', 'PMAR', 'CIND', 'MELZ', 'DIVR3P', 'PCRO') THEN 'R0'	
	WHEN greco = 'G' THEN 'I'	
	WHEN greco = 'H' AND uf.comp_r IN ('CHB') THEN 'F3'		
	WHEN greco = 'H' AND uf.comp_r IN ('HET') THEN 'F6.1'		
	WHEN greco = 'H' AND uf.comp_r IN ('DIVF2', 'DIVCHB1', 'FREHET', 'FREERA', 'YEU', 'HETFS', 'FIND', 'FRE', 'FREDIV1', 'HETCHB1', 'HETCHB2', 'DIVF3', 'HETCHS1', 'FRECHS2'
	, 'CHBFS', 'DIVCHB2', 'FREDIV2', 'YEUCHB', 'HETCHS2', 'CHS', 'CHSCHB', 'DIVCHS1', 'FRECHS1', 'CAS', 'BET', 'FRECHB2', 'FRECHB1', 'CASCHS1', 'FREFS', 'FRECHM2', 'FRECHP1'
	, 'CASFS', 'FRECHP2', 'ROB', 'DIVCHS2', 'CHSFS', 'DIVCHP2', 'HETCHM1', 'CHACHB1', 'FEXO', 'CASCHB1', 'HETCHM2', 'DIVF5') THEN 'F0'		
	WHEN greco = 'H' AND uf.comp_r IN ('CHMPSYL', 'PSYLF1', 'PSYLF2') THEN 'M1'		
	WHEN greco = 'H' AND uf.comp_r IN ('HETSAPIP', 'HETPESSP', 'HETSAPPES', 'HETPESSM', 'HETSAPIM') THEN 'M2'		
	WHEN greco = 'H' AND uf.comp_r IN ('FR2', 'FR3', 'FR5', 'FR4', 'CHMPALE') THEN 'M0'		
	WHEN greco = 'H' AND uf.comp_r IN ('PSYL') THEN 'R2'		
	WHEN greco = 'H' AND uf.comp_r IN ('EPIC') THEN 'R3'		
	WHEN greco = 'H' AND uf.comp_r IN ('MELZ') THEN 'R8'		
	WHEN greco = 'H' AND uf.comp_r IN ('PNIG') THEN 'R10'		
	WHEN greco = 'H' AND uf.comp_r IN ('PSYLR', 'SAPIPESS', 'DIVR2', 'SPEC', 'PCRO', 'DIVR3P', 'PLAR', 'PCEM', 'CIND', 'PMAR', 'PALE') THEN 'R0'		
	WHEN greco = 'H' THEN 'I'		
	WHEN greco = 'I' AND uf.comp_r IN ('CHP', 'CASCHP1', 'HETCHP1', 'CASCHP2', 'DIVCHP1', 'CHPCHB', 'HETCHP2', 'BETCHP1', 'CHPFS', 'DIVCHP2', 'CHPCHS') THEN 'F1.1'	
	WHEN greco = 'I' AND uf.comp_r IN ('FRE', 'FREDIV1', 'FRECHP2', 'FREHET', 'FREDIV2', 'FRECHP1', 'FREFS', 'FRECHB2', 'FRECHB1', 'FRECHS2', 'FRECHM2', 'FRECHS1', 'FRECHM1') THEN 'F2'	
	WHEN greco = 'I' AND uf.comp_r IN ('CHB') THEN 'F3'	
	WHEN greco = 'I' AND uf.comp_r IN ('HET') THEN 'F6.1'	
	WHEN greco = 'I' AND uf.comp_r IN ('DIVF2', 'FIND', 'YEU', 'CAS', 'YEUCHB', 'CHS', 'BET', 'ROB', 'DIVCHB1', 'HETCHB1', 'DIVF3', 'HETCHS1', 'HETFS', 'FREERA', 'BETCHS1'
	, 'CASCHB1', 'HETCHB2', 'DIVCHB2', 'YEUDIV', 'HETCHS2', 'CASCHB2', 'CHBFS', 'CASCHS1', 'CHSCHB', 'YEUARB', 'BETCHB1', 'CASFS', 'DIVCHS1', 'CASCHM1', 'HETCHM2', 'YEUCHL'
	, 'HETCHM1', 'PEU', 'ROBFS', 'DIVF5', 'CHMFS', 'CASCHS2', 'BETCHM1') THEN 'F0'	
	WHEN greco = 'I' AND uf.comp_r IN ('HETSAPIP', 'FR2', 'FR3', 'CHMPSYL', 'PSYLF2', 'HETSAPIM', 'PSYLF1', 'FR4', 'FR5', 'HETPESSM', 'HETSAPPES', 'HETPESSP') THEN 'M0'	
	WHEN greco = 'I' AND uf.comp_r IN ('SPEC') THEN 'R4'
	WHEN greco = 'I' AND uf.comp_r IN ('PCRO', 'PSYL', 'PNIG', 'PSYLR', 'DIVR2', 'EPIC', 'PLAR', 'DOUG', 'MELZ', 'CIND', 'SAPIPESS', 'DIVR3P', 'PALE', 'PMAR') THEN 'R0'
	WHEN greco = 'I' THEN 'I'
	WHEN greco = 'J' AND uf.comp_r IN ('CHB') THEN 'F3'
	WHEN greco = 'J' AND uf.comp_r IN ('YEU') THEN 'F7.1'
	WHEN greco = 'J' AND uf.comp_r IN ('FIND', 'DIVCHB1', 'DIVF2', 'YEUDIV', 'YEUARB', 'YEUCHL', 'FREDIV1', 'CAS', 'DIVCHB2', 'HET', 'CASCHB1', 'HETCHB1', 'FRE', 'FREDIV2'
	, 'FRECHB2', 'FRECHB1', 'CHBFS', 'PEU', 'CHS', 'HETFS', 'ROB', 'DIVF3', 'CASCHB2', 'FREERA', 'HETCHB2', 'ROBFS', 'FREFS', 'DIVCHP1', 'FRECHM2', 'HETCHS1', 'FEXO', 'DIVCHP2'
	, 'FREHET', 'CHP') THEN 'F0'
	WHEN greco = 'J' AND uf.comp_r IN ('CHMPALE', 'CHMPSYL', 'CHMPMAR') THEN 'M3'
	WHEN greco = 'J' AND uf.comp_r IN ('FR2', 'FR3', 'PSYLF2', 'PALEF1', 'PALEF2', 'FR4', 'PMARF2', 'PSYLF1', 'PMARF1') THEN 'M0'
	WHEN greco = 'J' AND uf.comp_r IN ('PALE') THEN 'R7'
	WHEN greco = 'J' AND uf.comp_r IN ('YEUCHB') THEN 'F9'
	WHEN greco = 'J' AND uf.comp_r IN ('PSYL', 'PMAR', 'CIND', 'PNIG', 'DIVR2', 'PSYLR', 'PLAR', 'PCRO', 'DIVR3P', 'EPIC', 'DOUG') THEN 'R0'
	WHEN greco = 'J' THEN 'I'	
	WHEN greco = 'K' AND uf.comp_r IN ('YEU') THEN 'F7.1'	
	WHEN greco = 'K' AND uf.comp_r IN ('YEUDIV', 'YEUARB', 'YEUCHL', 'YEUCHB') THEN 'F7.2'		
	WHEN greco = 'K' AND uf.comp_r IN ('HET', 'DIVF2', 'CAS', 'CASCHB1', 'CHB', 'FRECHB2', 'DIVF3', 'CHBFS', 'FRECHB1', 'CASCHB2', 'BET', 'FREDIV1', 'FREDIV2', 'DIVCHB1'
	, 'FREHET', 'CHS', 'HETCHB1') THEN 'F0'	
	WHEN greco = 'K' AND uf.comp_r IN ('FR2', 'CHMPMAR', 'PMARF2', 'PMARF1', 'FR3', 'HETSAPIP') THEN 'M0'	
	WHEN greco = 'K' AND uf.comp_r IN ('PMAR') THEN 'R1'	
	WHEN greco = 'K' AND uf.comp_r IN ('PLAR') THEN 'R11'		
	ELSE 'I'
END
FROM inv_exp_nm.g3foret f
INNER JOIN inv_exp_nm.e2point using (npp)
WHERE uf.npp = f.npp 
and f.incref IN (18);

COMMIT;

BEGIN;

UPDATE inv_exp_nm.p3point uf
SET comp_idreg = 
CASE 
	WHEN greco = 'A' AND uf.comp_r IN ('CHP', 'DIVCHP1', 'BETCHP1', 'CASCHP1', 'CHPCHS', 'FRECHP1', 'CASCHP2', 'FRECHP2', 'CHPFS', 'DIVCHP2'
	, 'CHACHP1', 'CHACHP2', 'CHPCHB') THEN 'F1.1'
	WHEN greco = 'A' AND uf.comp_r IN ('CHS') THEN 'F4'
	WHEN greco = 'A' AND uf.comp_r IN ('HETCHP1', 'HETCHS1', 'HET', 'HETCHP2', 'HETCHS2', 'HETCHM1', 'HETCHM2') THEN 'F6.3'
	WHEN greco = 'A' AND uf.comp_r IN ('PMAR', 'PLAR', 'PSYL') THEN 'R5'
	WHEN greco = 'A' AND uf.comp_r IN ('FIND', 'DIVF2', 'CAS', 'FIND', 'DIVF2', 'CAS', 'PEU', 'BET', 'CASCHS1', 'FREDIV1', 'BETCHS1', 'CASCHM1'
	, 'FREDIV2', 'FRE', 'DIVF3', 'BETCHM1', 'CHACHS1', 'FREHET', 'HETFS', 'DIVF4', 'CHACHM1', 'CHA', 'FRECHS2', 'CHMFS', 'ROB', 'CASCHS2', 'DIVF5'
	, 'DIVCHM1', 'FREERA', 'CHACHS2', 'DIVCHS1', 'CHB', 'CASFS', 'CHSFS', 'FRECHS1', 'FEXO', 'FREFS', 'YEUCHD', 'CHACHM2', 'CHM') THEN 'F0'
	WHEN greco = 'A' AND uf.comp_r IN ('FR2', 'CHMPMAR', 'FR3', 'PMARF2', 'CHMPSYL', 'PMARF1', 'PSYLF2', 'FR5', 'PSYLF1', 'HETSAPIM', 'FR4'
	, 'HETSAPIP', 'HETPESSP', 'HETPESSM') THEN 'M0'
	WHEN greco = 'A' AND uf.comp_r IN ('CIND', 'DOUG', 'DIVR2', 'PSYLR', 'SPEC', 'EPIC', 'CEXO', 'MELZ', 'DIVR3P', 'SAPIPESS') THEN 'R0'
	WHEN greco = 'A' THEN 'I'
	WHEN greco = 'B' AND uf.comp_r IN ('CHP', 'CHPCHS', 'DIVCHP1', 'BETCHP1', 'CHPFS', 'CASCHP1', 'CHPCHB', 'CASCHP2', 'DIVCHP2') THEN 'F1.1'
	WHEN greco = 'B' AND uf.comp_r IN ('FRECHP2', 'FRE', 'FREERA', 'FREDIV1', 'FRECHP1', 'FREDIV2', 'FREHET', 'FREFS', 'FRECHS2', 'FRECHS1'
	, 'FRECHM1', 'FRECHB2', 'FRECHB1') THEN 'F2'
	WHEN greco = 'B' AND uf.comp_r IN ('CHS') THEN 'F4'
	WHEN greco = 'B' AND uf.comp_r IN ('CHACHP1', 'CHACHS1', 'CHACHM1', 'CHACHP2', 'CHA', 'CHACHS2', 'CHACHM2', 'CHACHB1', 'CHACHB2') THEN 'F5'
	WHEN greco = 'B' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'B' AND uf.comp_r IN ('HETCHS1', 'HETCHP2', 'HETCHP1', 'HETCHS2', 'HETCHM1', 'HETCHM2') THEN 'F6.2'
	WHEN greco = 'B' AND uf.comp_r IN ('DIVF2', 'PEU', 'FIND', 'CAS', 'CASCHS1', 'BET', 'CHB', 'DIVF3', 'BETCHS1', 'ROB', 'DIVCHS1', 'HETFS'
	, 'CASCHS2', 'CASCHM1', 'CHSCHB', 'CHSFS', 'FRECHM2', 'BETCHM1', 'CHMFS', 'CASCHM2', 'CASFS', 'DIVCHB1', 'DIVCHM1', 'DIVCHS2', 'CHM', 'DIVF4', 'DIVF5'
	, 'CASCHB1', 'ROBFS', 'DIVCHB2', 'CHBFS', 'CASCHB2', 'BETCHB1', 'FEXO') THEN 'F0'
	WHEN greco = 'B' AND uf.comp_r IN ('CHMPSYL', 'FR2', 'PSYLF1', 'FR3', 'CHMPMAR', 'PMARF1', 'PMARF2', 'FR5', 'FR4', 'HETSAPIM', 'HETPESSM', 'HETSAPIP', 'PSYLF2') THEN 'M0'
	WHEN greco = 'B' AND uf.comp_r IN ('PSYL', 'PMAR', 'PLAR', 'PNIG') THEN 'R5'
	WHEN greco = 'B' AND uf.comp_r IN ('DOUG', 'PSYLR', 'EPIC', 'DIVR2', 'CIND', 'SPEC', 'MELZ', 'CEXO', 'SAPIPESS') THEN 'R0'
	WHEN greco = 'B' THEN 'I'
	WHEN greco = 'C' AND uf.comp_r IN ('CHP', 'CHPCHS', 'DIVCHP1', 'BETCHP1', 'CHPFS', 'DIVCHP2', 'CASCHP2', 'CASCHP1', 'CHPCHB') THEN 'F1.1'
	WHEN greco = 'C' AND uf.comp_r IN ('FRECHP2', 'FREDIV1', 'FREHET', 'FRE', 'FREERA', 'FRECHS2', 'FRECHP1', 'FREDIV2', 'FREFS', 'FRECHS1'
	, 'FRECHM2', 'FRECHM1', 'FRECHB2', 'FRECHB1') THEN 'F2'
	WHEN greco = 'C' AND uf.comp_r IN ('CHS') THEN 'F4'
	WHEN greco = 'C' AND uf.comp_r IN ('CHACHP1', 'CHACHS1', 'CHACHP2', 'CHA', 'CHACHS2', 'CHACHM1', 'CHACHM2', 'CHACHB1', 'CHACHB2') THEN 'F5'
	WHEN greco = 'C' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'C' AND uf.comp_r IN ('HETCHS1', 'HETCHS2', 'HETCHP2', 'HETCHP1', 'HETCHM2', 'HETCHM1', 'HETCHB1', 'HETCHB2') THEN 'F6.2'
	WHEN greco = 'C' AND uf.comp_r IN ('DIVF2', 'HETFS', 'DIVF3', 'FIND', 'CAS', 'PEU', 'ROB', 'DIVCHS1', 'BETCHS1', 'CHB', 'CASCHS1', 'BET', 'CHMFS', 'CASCHS2'
	, 'CHSCHB', 'DIVCHS2', 'CHSFS', 'DIVF5', 'DIVF4', 'DIVCHB1', 'DIVCHM1', 'CASFS', 'BETCHM1', 'DIVCHB2', 'ROBFS', 'CHM', 'CHBFS', 'CASCHB1', 'YEU') THEN 'F0'
	WHEN greco = 'C' AND uf.comp_r IN ('FR2', 'FR3', 'PSYLF2', 'FR5', 'CHMPSYL', 'HETPESSM', 'PSYLF1', 'HETSAPIM', 'FR4', 'HETPESSP', 'HETSAPIP', 'HETSAPPES', 'PMARF1') THEN 'M0'
	WHEN greco = 'C' AND uf.comp_r IN ('EPIC', 'PSYL', 'DOUG', 'PNIG', 'SPEC', 'PSYLR', 'DIVR2', 'MELZ', 'SAPIPESS', 'CIND', 'PLAR', 'CEXO', 'DIVR3P') THEN 'R0'
	WHEN greco = 'C' THEN 'I'
	WHEN greco = 'D' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'D' AND uf.comp_r IN ('HETCHS1', 'HETCHS2', 'HETCHP1', 'HETCHP2', 'HETCHM1', 'HETCHM2') THEN 'F6.2'
	WHEN greco = 'D' AND uf.comp_r IN ('CHS', 'DIVF2', 'FIND', 'BET', 'CHACHS1', 'CHP', 'FREERA', 'HETFS', 'FRE', 'FREDIV1', 'ROB', 'FRECHS2', 'DIVF3', 'BETCHP1', 'CAS'
	, 'CHACHP1', 'FREHET', 'CHACHP2', 'FRECHP2', 'FREFS', 'FREDIV2', 'FRECHP1', 'CASCHS2', 'CHA', 'CHPCHS', 'CASCHS1', 'BETCHS1', 'CHPFS', 'DIVCHP1', 'CHACHS2', 'DIVCHS1'
	, 'FRECHM2', 'FRECHS1', 'CHSFS', 'CASCHP1', 'BETCHM1', 'CHACHM2', 'DIVF5', 'DIVF4', 'PEU') THEN 'F0'
	WHEN greco = 'D' AND uf.comp_r IN ('HETSAPIP', 'HETSAPIM', 'HETSAPPES', 'HETPESSP', 'HETPESSM') THEN 'M2'
	WHEN greco = 'D' AND uf.comp_r IN ('FR2', 'FR3', 'PSYLF1', 'PSYLF2', 'CHMPSYL', 'FR5', 'FR4') THEN 'M0'
	WHEN greco = 'D' AND uf.comp_r IN ('EPIC') THEN 'R3'
	WHEN greco = 'D' AND uf.comp_r IN ('SPEC') THEN 'R4'
	WHEN greco = 'D' AND uf.comp_r IN ('SAPIPESS') THEN 'R9'
	WHEN greco = 'D' AND uf.comp_r IN ('PSYLR', 'PSYL', 'DOUG', 'DIVR2', 'MELZ') THEN 'R0'
	WHEN greco = 'D' THEN 'I'
	WHEN greco = 'E' AND uf.comp_r IN ('FRECHS2', 'FREHET', 'FRECHP2', 'FREERA', 'FRE', 'FREDIV1', 'FREFS', 'FREDIV2', 'FRECHS1', 'FRECHM2', 'FRECHB2', 'FRECHP1'
	, 'FRECHB1', 'FRECHM1') THEN 'F2'
	WHEN greco = 'E' AND uf.comp_r IN ('HET') THEN 'F6.1'
	WHEN greco = 'E' AND uf.comp_r IN ('DIVF2', 'CHS', 'CHACHS1', 'HETCHS2', 'HETCHS1', 'CHACHP1', 'DIVCHS1', 'DIVF3', 'CHB', 'CHACHS2', 'CHACHP2', 'HETFS', 'FIND', 'CHP'
	, 'HETCHP2', 'DIVCHB1', 'CHA', 'ROB', 'CHSCHB', 'CHSFS', 'CHACHB1', 'CHACHM1', 'DIVCHS2', 'CHPCHS', 'DIVCHP1', 'DIVCHB2', 'HETCHM2', 'HETCHP1', 'CHACHM2', 'CHMFS'
	, 'CAS', 'HETCHB2', 'CHPFS', 'DIVCHP2', 'CASCHS1', 'CASCHS2', 'CHPCHB', 'CHBFS', 'HETCHB1', 'BET', 'DIVCHM1', 'BETCHP1', 'CHACHB2', 'ROBFS', 'BETCHS1', 'DIVF5', 'PEU') THEN 'F0'	
	WHEN greco = 'E' AND uf.comp_r IN ('HETSAPIP', 'HETPESSP', 'HETSAPPES', 'HETSAPIM', 'HETPESSM') THEN 'M2'
	WHEN greco = 'E' AND uf.comp_r IN ('FR3', 'FR2', 'FR5', 'PSYLF2', 'FR4', 'CHMPSYL', 'PSYLF1') THEN 'M0'
	WHEN greco = 'E' AND uf.comp_r IN ('EPIC') THEN 'R3'
	WHEN greco = 'E' AND uf.comp_r IN ('SPEC') THEN 'R4'
	WHEN greco = 'E' AND uf.comp_r IN ('SAPIPESS') THEN 'R9'
	WHEN greco = 'E' THEN 'I'
	WHEN greco = 'F' AND uf.comp_r IN ('CHP', 'CHPCHB', 'DIVCHP1', 'CHACHP1', 'FRECHP1', 'DIVCHP2', 'CHPFS', 'CHPCHS', 'FRECHP2', 'CHACHP2', 'HETCHP1', 'BETCHP1', 'HETCHP2') THEN 'F1.1'
	WHEN greco = 'F' AND uf.comp_r IN ('CHB') THEN 'F3'
	WHEN greco = 'F' AND uf.comp_r IN ('FIND', 'DIVCHB1', 'DIVF2', 'PEU', 'CHS', 'ROB', 'FRE', 'CHACHB1', 'CHA', 'FREDIV1', 'CHACHM1', 'DIVF3', 'CHSCHB', 'FREERA', 'FRECHB2'
	, 'DIVCHB2', 'FREDIV2', 'CHM', 'FRECHB1', 'CHMFS', 'YEUCHB', 'DIVCHM1', 'HET', 'CHACHS1', 'HETCHB1', 'YEUCHD', 'YEU', 'ROBFS', 'FRECHM1', 'FREFS', 'HETCHM1', 'YEUDIV'
	, 'CHBFS', 'DIVCHS1', 'CHACHB2', 'FRECHM2', 'BET', 'FRECHS1', 'HETFS', 'FRECHS2', 'CHACHM2', 'CHACHS2', 'HETCHS2', 'DIVF4', 'CHSFS', 'BETCHS1', 'HETCHS1', 'FREHET'
	, 'HETCHB2', 'HETCHM2', 'DIVCHS2', 'FEXO') THEN 'F0'
	WHEN greco = 'F' AND uf.comp_r IN ('CHMPMAR', 'PMARF2', 'PMARF1', 'FR2', 'FR3', 'CHMPSYL', 'PSYLF2', 'FR5', 'PSYLF1', 'FR4', 'CHMPALE', 'HETPESSM', 'HETSAPIP') THEN 'M0'
	WHEN greco = 'F' AND uf.comp_r IN ('PMAR') THEN 'R1'
	WHEN greco = 'F' AND uf.comp_r IN ('CAS', 'CASCHP1', 'CASCHP2', 'CASCHB1', 'CASCHM1', 'CASFS', 'CASCHS1', 'CASCHB2', 'CASCHM2', 'CASCHS2') THEN 'F8.1'
	WHEN greco = 'F' AND uf.comp_r IN ('PLAR', 'PNIG', 'PSYL', 'CIND', 'DOUG', 'PSYLR', 'DIVR2', 'EPIC', 'MELZ') THEN 'R0'
	WHEN greco = 'F' THEN 'I'
	WHEN greco = 'G' AND uf.comp_r IN ('CHP') THEN 'F1.3'	
	WHEN greco = 'G' AND uf.comp_r IN ('CASCHP1', 'HETCHP1', 'FRECHP2', 'HETCHP2', 'FRECHP1', 'BETCHP1', 'CASCHP2', 'CHACHP1', 'DIVCHP1', 'CHPCHS', 'CHPFS', 'CHACHP2', 'DIVCHP2'
	, 'CHPCHB') THEN 'F1.2'	
	WHEN greco = 'G' AND uf.comp_r IN ('CHB') THEN 'F3'	
	WHEN greco = 'G' AND uf.comp_r IN ('CHS') THEN 'F4'	
	WHEN greco = 'G' AND uf.comp_r IN ('HET') THEN 'F6.1'	
	WHEN greco = 'G' AND uf.comp_r IN ('CAS') THEN 'F8.2'	
	WHEN greco = 'G' AND uf.comp_r IN ('DIVF2', 'HETCHS1', 'YEU', 'FREDIV1', 'FIND', 'FRE', 'CASCHS1', 'YEUDIV', 'DIVF3', 'CASCHB1', 'FRECHS2', 'YEUCHB', 'FREDIV2', 'CHACHS1', 'BET'
	, 'FREHET', 'FRECHB1', 'FRECHS1', 'HETCHS2', 'FREERA', 'HETCHB1', 'ROB', 'HETFS', 'DIVCHB1', 'CHA', 'FRECHB2', 'HETCHM1', 'FREFS', 'DIVCHS1', 'CHSCHB', 'CASCHM1', 'PEU'
	, 'FRECHM1', 'CASFS', 'BETCHS1', 'CHSFS', 'FRECHM2', 'CHACHM1', 'CASCHB2', 'CASCHS2', 'YEUARB', 'DIVF5', 'CHBFS', 'CHACHS2', 'CASCHM2', 'HETCHM2', 'DIVCHM1', 'DIVF4', 'DIVCHB2'
	, 'CHACHB1', 'HETCHB2', 'CHMFS', 'DIVCHS2', 'BETCHM1', 'CHM', 'CHACHM2', 'CHACHB2') THEN 'F0'	
	WHEN greco = 'G' AND uf.comp_r IN ('PSYLF1', 'PSYLF2', 'CHMPSYL') THEN 'M1'	
	WHEN greco = 'G' AND uf.comp_r IN ('FR2', 'FR3', 'HETSAPIP', 'HETSAPIM', 'FR5', 'PMARF1', 'HETPESSP', 'CHMPMAR', 'HETPESSM', 'FR4', 'HETSAPPES', 'PMARF2') THEN 'M0'	
	WHEN greco = 'G' AND uf.comp_r IN ('PSYL') THEN 'R2'	
	WHEN greco = 'G' AND uf.comp_r IN ('EPIC') THEN 'R3'
	WHEN greco = 'G' AND uf.comp_r IN ('SPEC') THEN 'R4'	
	WHEN greco = 'G' AND uf.comp_r IN ('DOUG') THEN 'R6'	
	WHEN greco = 'G' AND uf.comp_r IN ('DIVR2', 'PSYLR', 'SAPIPESS', 'PLAR', 'PNIG', 'PMAR', 'CIND', 'MELZ', 'DIVR3P', 'PCRO') THEN 'R0'	
	WHEN greco = 'G' THEN 'I'	
	WHEN greco = 'H' AND uf.comp_r IN ('CHB') THEN 'F3'		
	WHEN greco = 'H' AND uf.comp_r IN ('HET') THEN 'F6.1'		
	WHEN greco = 'H' AND uf.comp_r IN ('DIVF2', 'DIVCHB1', 'FREHET', 'FREERA', 'YEU', 'HETFS', 'FIND', 'FRE', 'FREDIV1', 'HETCHB1', 'HETCHB2', 'DIVF3', 'HETCHS1', 'FRECHS2'
	, 'CHBFS', 'DIVCHB2', 'FREDIV2', 'YEUCHB', 'HETCHS2', 'CHS', 'CHSCHB', 'DIVCHS1', 'FRECHS1', 'CAS', 'BET', 'FRECHB2', 'FRECHB1', 'CASCHS1', 'FREFS', 'FRECHM2', 'FRECHP1'
	, 'CASFS', 'FRECHP2', 'ROB', 'DIVCHS2', 'CHSFS', 'DIVCHP2', 'HETCHM1', 'CHACHB1', 'FEXO', 'CASCHB1', 'HETCHM2', 'DIVF5') THEN 'F0'		
	WHEN greco = 'H' AND uf.comp_r IN ('CHMPSYL', 'PSYLF1', 'PSYLF2') THEN 'M1'		
	WHEN greco = 'H' AND uf.comp_r IN ('HETSAPIP', 'HETPESSP', 'HETSAPPES', 'HETPESSM', 'HETSAPIM') THEN 'M2'		
	WHEN greco = 'H' AND uf.comp_r IN ('FR2', 'FR3', 'FR5', 'FR4', 'CHMPALE') THEN 'M0'		
	WHEN greco = 'H' AND uf.comp_r IN ('PSYL') THEN 'R2'		
	WHEN greco = 'H' AND uf.comp_r IN ('EPIC') THEN 'R3'		
	WHEN greco = 'H' AND uf.comp_r IN ('MELZ') THEN 'R8'		
	WHEN greco = 'H' AND uf.comp_r IN ('PNIG') THEN 'R10'		
	WHEN greco = 'H' AND uf.comp_r IN ('PSYLR', 'SAPIPESS', 'DIVR2', 'SPEC', 'PCRO', 'DIVR3P', 'PLAR', 'PCEM', 'CIND', 'PMAR', 'PALE') THEN 'R0'		
	WHEN greco = 'H' THEN 'I'		
	WHEN greco = 'I' AND uf.comp_r IN ('CHP', 'CASCHP1', 'HETCHP1', 'CASCHP2', 'DIVCHP1', 'CHPCHB', 'HETCHP2', 'BETCHP1', 'CHPFS', 'DIVCHP2', 'CHPCHS') THEN 'F1.1'	
	WHEN greco = 'I' AND uf.comp_r IN ('FRE', 'FREDIV1', 'FRECHP2', 'FREHET', 'FREDIV2', 'FRECHP1', 'FREFS', 'FRECHB2', 'FRECHB1', 'FRECHS2', 'FRECHM2', 'FRECHS1', 'FRECHM1') THEN 'F2'	
	WHEN greco = 'I' AND uf.comp_r IN ('CHB') THEN 'F3'	
	WHEN greco = 'I' AND uf.comp_r IN ('HET') THEN 'F6.1'	
	WHEN greco = 'I' AND uf.comp_r IN ('DIVF2', 'FIND', 'YEU', 'CAS', 'YEUCHB', 'CHS', 'BET', 'ROB', 'DIVCHB1', 'HETCHB1', 'DIVF3', 'HETCHS1', 'HETFS', 'FREERA', 'BETCHS1'
	, 'CASCHB1', 'HETCHB2', 'DIVCHB2', 'YEUDIV', 'HETCHS2', 'CASCHB2', 'CHBFS', 'CASCHS1', 'CHSCHB', 'YEUARB', 'BETCHB1', 'CASFS', 'DIVCHS1', 'CASCHM1', 'HETCHM2', 'YEUCHL'
	, 'HETCHM1', 'PEU', 'ROBFS', 'DIVF5', 'CHMFS', 'CASCHS2', 'BETCHM1') THEN 'F0'	
	WHEN greco = 'I' AND uf.comp_r IN ('HETSAPIP', 'FR2', 'FR3', 'CHMPSYL', 'PSYLF2', 'HETSAPIM', 'PSYLF1', 'FR4', 'FR5', 'HETPESSM', 'HETSAPPES', 'HETPESSP') THEN 'M0'	
	WHEN greco = 'I' AND uf.comp_r IN ('SPEC') THEN 'R4'
	WHEN greco = 'I' AND uf.comp_r IN ('PCRO', 'PSYL', 'PNIG', 'PSYLR', 'DIVR2', 'EPIC', 'PLAR', 'DOUG', 'MELZ', 'CIND', 'SAPIPESS', 'DIVR3P', 'PALE', 'PMAR') THEN 'R0'
	WHEN greco = 'I' THEN 'I'
	WHEN greco = 'J' AND uf.comp_r IN ('CHB') THEN 'F3'
	WHEN greco = 'J' AND uf.comp_r IN ('YEU') THEN 'F7.1'
	WHEN greco = 'J' AND uf.comp_r IN ('FIND', 'DIVCHB1', 'DIVF2', 'YEUDIV', 'YEUARB', 'YEUCHL', 'FREDIV1', 'CAS', 'DIVCHB2', 'HET', 'CASCHB1', 'HETCHB1', 'FRE', 'FREDIV2'
	, 'FRECHB2', 'FRECHB1', 'CHBFS', 'PEU', 'CHS', 'HETFS', 'ROB', 'DIVF3', 'CASCHB2', 'FREERA', 'HETCHB2', 'ROBFS', 'FREFS', 'DIVCHP1', 'FRECHM2', 'HETCHS1', 'FEXO', 'DIVCHP2'
	, 'FREHET', 'CHP') THEN 'F0'
	WHEN greco = 'J' AND uf.comp_r IN ('CHMPALE', 'CHMPSYL', 'CHMPMAR') THEN 'M3'
	WHEN greco = 'J' AND uf.comp_r IN ('FR2', 'FR3', 'PSYLF2', 'PALEF1', 'PALEF2', 'FR4', 'PMARF2', 'PSYLF1', 'PMARF1') THEN 'M0'
	WHEN greco = 'J' AND uf.comp_r IN ('PALE') THEN 'R7'
	WHEN greco = 'J' AND uf.comp_r IN ('YEUCHB') THEN 'F9'
	WHEN greco = 'J' AND uf.comp_r IN ('PSYL', 'PMAR', 'CIND', 'PNIG', 'DIVR2', 'PSYLR', 'PLAR', 'PCRO', 'DIVR3P', 'EPIC', 'DOUG') THEN 'R0'
	WHEN greco = 'J' THEN 'I'	
	WHEN greco = 'K' AND uf.comp_r IN ('YEU') THEN 'F7.1'	
	WHEN greco = 'K' AND uf.comp_r IN ('YEUDIV', 'YEUARB', 'YEUCHL', 'YEUCHB') THEN 'F7.2'		
	WHEN greco = 'K' AND uf.comp_r IN ('HET', 'DIVF2', 'CAS', 'CASCHB1', 'CHB', 'FRECHB2', 'DIVF3', 'CHBFS', 'FRECHB1', 'CASCHB2', 'BET', 'FREDIV1', 'FREDIV2', 'DIVCHB1'
	, 'FREHET', 'CHS', 'HETCHB1') THEN 'F0'	
	WHEN greco = 'K' AND uf.comp_r IN ('FR2', 'CHMPMAR', 'PMARF2', 'PMARF1', 'FR3', 'HETSAPIP') THEN 'M0'	
	WHEN greco = 'K' AND uf.comp_r IN ('PMAR') THEN 'R1'	
	WHEN greco = 'K' AND uf.comp_r IN ('PLAR') THEN 'R11'		
	ELSE 'I'
END
FROM inv_exp_nm.p3point f
INNER JOIN inv_exp_nm.e2point using (npp)
WHERE uf.npp = f.npp
AND f.incref IN (18);


SELECT incref, count(*)
FROM inv_exp_nm.g3foret
where comp_idreg IS NOT NULL
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(*)
FROM inv_exp_nm.p3point
where comp_idreg IS NOT NULL
GROUP BY incref
ORDER BY incref DESC;


COMMIT;
ROLLBACK;

BEGIN;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18, defout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'COMP_IDREG';

COMMIT;








