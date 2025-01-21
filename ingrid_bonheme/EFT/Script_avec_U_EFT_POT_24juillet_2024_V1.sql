--Script pour calculer les EFT_final, incluant les habitats arbustifs et les faciès à partir : 
-- de l'unité U_EFT_POT qui classe tous les HAB en EFT_potentiels, y compris les habitats dunaires, arbustifs
-- d'un tri par faciès selon les critères EFT
--NB : ajout d'une colonne (à partir unité U_EFT_VALIDE) pour préciser si l'habitat est un habitat forestier dunaire, un habitat forestier non-dunaire, ou un habitat arbustif
--NB suite : en effet, dans le référentiel EFT, les habitats arbustifs sont exclus et les dunes aussi.

--Ingrid Bonhême

-- --- Forêts de production hors peupleraies - VERSION 1 avec unité U_EFT_POT - V1_EFT_POT 24/07/2024 : 
-- adaptation du script précédent pour supprimer les lignes qui sont inutiles car les habitats sont donnés directement dans EFT_POT pour les habitats dunaires ou arbustifs
-- case when : 1ère condition remplie est celle qui est effective, l'exécution s'arrête pour le npp, importance de l'ordre
select 2005 + g3f.incref as campagne, p1.idp, g3f.npp, hab.hab1, g3e.distriv, g3f.mdeb, g3f.tcar, g2.gmode as EFT_pot, g3f.tplant, ug3f.u_divespar, g3f.peupnr , g3f.sver, g3f.sfo_nm, p2.greco, p2.ser_86, g3f.esparpre, m.libelle as lib_esparpre, ug3f.u_indsparpre, g3.gmode as EFT_VALIDE,
case
	when (g3f.esparpre  not in ('62', '52', '53CO', '54', '53CA')  and ug3f.u_indsparpre = 'NI')
	then '14.2'
	when (g3f.esparpre  = '52' and ug3f.u_indsparpre = 'NI'and g3f.tplant != 'P' ) -- pin sylvestre hors zone d'indigénat non planté en régulier
	then '2.2'
	when (g3f.esparpre  = '52' and ug3f.u_indsparpre = 'NI'and g3f.tplant = 'P' ) -- pin sylvestre hors zone d'indigénat avec traces de plantation
	then '14.2'
	when (g3f.esparpre  = '62' and ug3f.u_indsparpre = 'NI' and g3f.tplant != 'P') -- Epicéa commun hors zone d'indigénat non planté en régulier
	then '2.3'
	when (g3f.esparpre  = '62' and ug3f.u_indsparpre = 'NI'and g3f.tplant = 'P' ) -- Epicéa commun hors zone d'indigénat avec traces de plantation
	then '14.2'
	when ((g3f.esparpre  in ('54', '53CA', '53CO') and ug3f.u_indsparpre = 'NI') and g3f.tplant != 'P') -- Pin noir d'Autriche, Pin de Calabre, Pin laricio de Corse non planté en régulier
	then '2.4'
	when (g3f.esparpre  in ('53CO', '54', '53CA') and ug3f.u_indsparpre = 'NI'and g3f.tplant = 'P') -- Pins noirs plantés en régulier
	then '14.2'
	when (g3f.tplant = 'P' and ug3f.u_indsparpre  = 'I' and (g3f.sver in ('2', '5', '6') or g3f.sfo_nm = '1'))
	then '14.1'
	when (g3f.esparpre = '10' and (g3f.tplant != 'P' or (g3f.tplant = 'P' and (g3f.sver in ('3', '4') or g3f.sfo_nm != '1')))) -- ici tous les peuplements de châtaignier sauf ceux plantés en régulier
	then '8.7'
	when (p2.greco = 'K' and hab.hab1 in ('41.9F', '41.9H') and g3f.esparpre = '13C' and g3e.distriv = '0')
	then '13.2'
	when ((g2.gmode not in ('11.1','11.2','11.3', '12.1', '12.2','12.3') or hab.hab1 not in ('51.1136','44.92', '44.921', '44.921A', '44.921B', '44.921C', '44.921D', '44.921K', '44.922', '44.92A', '44.92B', '44.92C', '44.92D', '44.92E', '44.92H', '44.93', '44.93A', '44.9A')) and g3f.esparpre in ( '12P', '12V'))
	then '13.4' -- tous les peuplements dominés par les bouleaux en dehors des peuplements liés à l'eau
	when ((g2.gmode not in ('11.1','11.2','11.3', '12.1', '12.2','12.3') or hab.hab1 not in ('51.1136','44.92', '44.921', '44.921A', '44.921B', '44.921C', '44.921D', '44.921K', '44.922', '44.92A', '44.92B', '44.92C', '44.92D', '44.92E', '44.92H', '44.93', '44.93A', '44.9A')) and g3f.esparpre ='24')
	then '13.5' -- tous les peuplements dominés par le tremble en dehors des peuplements liés à l'eau
	when (g3f.esparpre in ('51','52','53CO','53CA','53S','54','55','56','57A','57B','58','59','60','61','62','63','64','65','66','67','68CM','68CB','68CH','68PM','68CA','68EO','68TG','68CL','68SC','68SI','68PC','68SV','68SG','68CC','68TH','68CJ','68CE','69','70SE','70SC','70SB','71','72V','72N','73','74J','74H','76','77') and hab.hab1 in ('51.1136', '44.92', '44.921', '44.921A', '44.921B', '44.921C', '44.921D', '44.921K', '44.922', '44.92A', '44.92B', '44.92C', '44.92D', '44.92E', '44.92H', '44.93', '44.93A', '44.9A')) 
	then '11.1' -- on a enlevé les cas de plantations etc avant (cf. explications au début sur le rôle de l'ordre des lignes)
	when (g3f.esparpre in ('12V', '12P') and hab.hab1 in ('51.1136', '44.92', '44.921', '44.921A', '44.921B', '44.921C', '44.921D', '44.921K', '44.922', '44.92A', '44.92B', '44.92C', '44.92D', '44.92E', '44.92H', '44.93', '44.93A', '44.9A')) 
	then '11.3'
	when (g3f.esparpre in ('02', '03') and hab.hab1 in ('51.1136', '44.92', '44.921', '44.921A', '44.921B', '44.921C', '44.921D', '44.921K', '44.922', '44.92A', '44.92B', '44.92C', '44.92D', '44.92E', '44.92H', '44.93', '44.93A', '44.9A')) 
	then '11.4'
	when (hab.hab1 in ('51.1136', '44.92', '44.921', '44.921A', '44.921B', '44.921C', '44.921D', '44.921K', '44.922', '44.92A', '44.92B', '44.92C', '44.92D', '44.92E', '44.92H', '44.93', '44.93A', '44.9A')) 
	then '11.2' -- ici pas besoin de spécifier les essences, car cette ligne ne sera utilisée que si celles d'avant ne permettent pas de remplir la case, donc cela revient à dire, si autres essences et hab dans la liste alors 11.2
	when (hab.hab1 = '16.29' and p2.greco ='B' and g3f.esparpre = '18C') then '5.8'
	when (hab.hab1 = '16.29' and p2.greco ='B' and g3f.esparpre != '18C' and g3e.indic_hydro in ('1', '2', '3'))  then '11.3'
	when (hab.hab1 = '16.29' and p2.greco ='B' and g3f.esparpre = '15S' and g3e.indic_hydro in ('4', '5', 'X'))  then '5.3'
	when (hab.hab1 = '16.29' and p2.greco ='B' and g3f.esparpre not in('15S', '18C') and g3e.indic_hydro in ('4', '5', 'X'))  then '4.2'
	when (hab.hab1 = '41.15' and (p2.greco in ('I', 'G') or p2.ser_86 in ('H10', 'H21', 'H22'))) then '7.1'
	when (hab.hab1 = '41.15' and p2.greco in ('D', 'E')) then '7.2'
	when (hab.hab1 = '41.15' and (p2.greco in ('J', 'K') or p2.ser_86 in ('H30', 'H41', 'H42'))) then '7.3'
	when (hab.hab1 = '41.16' and (p2.greco in ('I', 'G') or p2.ser_86 in ('H10', 'H21', 'H22'))) then '7.1'
	when (hab.hab1 = '41.16' and p2.greco in ('D', 'E')) then '7.2'
	when (hab.hab1 = '41.16' and (p2.greco in ('J', 'K') or p2.ser_86 in ('H30', 'H41', 'H42'))) then '7.3'
	when (hab.hab1 = '41.16' and p2.greco in ('A', 'B')) then '6.2'
	when (hab.hab1 = '41.16' and p2.greco in ('C', 'F')) then '6.3'
	when (hab.hab1 = '41.17' and (p2.greco in ('I', 'G') or p2.ser_86 in ('H10', 'H21', 'H22'))) then '7.1'
	when (hab.hab1 = '41.17' and (p2.greco in ('J', 'K') or p2.ser_86 in ('H30', 'H41', 'H42'))) then '7.3'
	when (hab.hab1 = '41.511' and g3f.esparpre in ('12V', '12P')) then '4.2'
	when (hab.hab1 = '41.511' and g3f.esparpre not in ('12V', '12P')) then '4.1'
	when (hab.hab1 in ('44.1', '44.112A', '44.12', '44.12A', '44.12B', '44.12C', '44.12E', '44.12F', '44.12G', '44.12K') and p2.greco in ('J', 'K')) then '12.3'
	when (hab.hab1 in ('44.1', '44.112A', '44.12', '44.12A', '44.12B', '44.12C', '44.12E', '44.12F', '44.12G', '44.12K') and p2.greco in ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I')) then '12.1'
else g2.gmode end
AS EFT_final_detail
from inv_exp_nm.e1point as p1
inner join inv_exp_nm.g3foret as g3f on p1.npp = g3f.npp and g3f.incref in ('7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17')
left join inv_exp_nm.g3ecologie as g3e on p1.npp = g3e.npp 
left join inv_exp_nm.u_g3foret as ug3f on p1.npp = ug3f.npp
left join inv_exp_nm.e2point as p2 on p1.npp = p2.npp
left JOIN inv_exp_nm.habitats as hab ON p1.npp = hab.npp
left JOIN metaifn.abgroupe as g2 ON g2.gunite = 'U_EFT_POT' AND g2.unite = 'HAB' AND hab.hab1 = g2.mode
left join metaifn.abgroupe as g3 ON g3.gunite = 'U_EFT_VALIDE' AND g2.unite = 'HAB' AND hab.hab1 = g3.mode
left join metaifn.abmode as m ON m.unite = 'ESPAR' AND g3f.esparpre = m.mode
inner join inv_exp_nm.u_e2point as up2 on g3f.npp = up2.npp and up2.u_inv_facon is false; -- 63897 points