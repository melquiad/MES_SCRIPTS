-- Mise à jour de l'échelon dans point_lt
WITH e AS
	(
	SELECT pt.id_ech, pt.id_point, pt.formation, d.ex AS echelon_init
	FROM points_tir_final pt
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

-- En utilisant les vues => 3 requêtes
SET enable_nestloop = TRUE;

   -- points 1ère visite
WITH e AS
	(
	SELECT vlp1.id_ech, p.id_point, d.ex AS echelon_init
	FROM v_liste_points_lt1 vlp1
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp1.annee = 2024
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 2ème visite
WITH e AS
	(
	SELECT vlp2.id_ech, p.id_point, d.ex AS echelon_init
	FROM v_liste_points_lt2 vlp2
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp2.annee = 2024
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 1ère visite 2ème pi
WITH e AS
	(
	SELECT c.id_ech, p.id_point, d.ex AS echelon_init
	FROM v_liste_points_lt1_pi2 c
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.dir d ON ST_Intersects(d.geom, p.geom)
	WHERE c.annee = 2024
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;



-- Mise à jour de SECTEUR_CN dans point_lt

-- En utilisant les vues => 3 requêtes
SET enable_nestloop = TRUE;

   -- points 1ère visite
WITH e AS
	(
	SELECT vlp1.id_ech, p.id_point, d.nom_sect AS secteur_cn
	FROM v_liste_points_lt1 vlp1
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.secteurs_cn d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp1.annee = 2024
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 2ème visite
WITH e AS
	(
	SELECT vlp2.id_ech, p.id_point, d.nom_sect AS secteur_cn
	FROM v_liste_points_lt2 vlp2
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.secteurs_cn d ON ST_Intersects(d.geom, p.geom)
	WHERE vlp2.annee = 2024
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

   -- points 1ère visite 2ème pi
WITH e AS
	(
	SELECT vplp.id_ech, p.id_point, d.nom_sect AS secteur_cn
	FROM v_liste_points_lt1_pi2 vplp 
	INNER JOIN point p USING (id_point)
	INNER JOIN sig_inventaire.secteurs_cn d ON ST_Intersects(d.geom, p.geom)
	WHERE vplp.annee = 2024
	)
UPDATE point_lt pl
SET echelon_init = e.echelon_init
FROM e
WHERE pl.id_ech = e.id_ech AND pl.id_point = e.id_point;

