-- en local


shp2pgsql -s 2154 -D -i -I ~/Documents/ECHANGES/SIG/BD_Topage_2024/surf_hydro_2024.shp sig_ign.surf_hydro_2024 | psql service=inv-local


-- mise à jour des droits
ALTER TABLE sig_ign.troncon_carthage_2024 OWNER TO production_admin;
ALTER TABLE sig_ign.hydro_surf_carthage_2024 OWNER TO production_admin;

GRANT ALL ON TABLE sig_ign.troncon_carthage_2024 TO production_admin;
GRANT ALL ON TABLE sig_ign.hydro_surf_carthage_2024 TO production_admin;

GRANT SELECT ON TABLE sig_ign.troncon_carthage_2024 TO sig_datareader;
GRANT SELECT ON TABLE sig_ign.hydro_surf_carthage_2024 TO sig_datareader;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE sig_ign.troncon_carthage_2024 TO sig_datawriter;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE sig_ign.hydro_surf_carthage_2024 TO sig_datawriter;
