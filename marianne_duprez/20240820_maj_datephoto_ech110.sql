
-- Mise à jour de la date photo de l'échantillon 110 composé de points pi 2020 re-photointerprétés pour la densification pi 2024
-- pour cause de nouvelle prise de vue de 2021

CREATE TABLE public.date_photo_point_densif (
    npp CHAR(16),
    datephoto date);

\COPY date_photo_point_densif FROM '/home/lhaugomat/Documents/GITLAB/production/Campagne_2025/donnees/pi2024_datepva_densif.csv' WITH CSV DELIMITER '|' NULL AS '' HEADER


-- Sélection de spoints dont la datephoto doit être mise à jour
SELECT v.id_ech, v.npp, v.id_point, d.npp, v.datephoto1, d.datephoto AS new_datephoto, pp.datephoto
FROM v_liste_points_pi2 v
INNER JOIN public.date_photo_point_densif d ON v.npp = d.npp
INNER JOIN inv_prod_new.point_pi pp ON v.id_ech = pp.id_ech AND v.id_point = pp.id_point
WHERE v.id_ech = 110;


-- Mise à jour
UPDATE inv_prod_new.point_pi pp
SET datephoto = d.datephoto 
FROM public.date_photo_point_densif d
INNER JOIN v_liste_points_pi2 v ON d.npp = v.npp
WHERE pp.id_ech = v.id_ech
AND pp.id_point = v.id_point
AND v.id_ech = 110;

DROP TABLE public.date_photo_point_densif;

