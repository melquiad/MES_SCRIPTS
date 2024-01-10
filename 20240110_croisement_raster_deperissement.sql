


# -s use srid 4326
# -I create spatial index
# -C use standard raster constraints
# -M vacuum analyze after load
# *.tif load all these files
# -F include a filename column in the raster table
# -t tile the output 100x100
# public.demelevation load into this table
raster2pgsql -s 4326 -I -C -M -F -t 100x100 *.tif public.demelevation > elev.sql
#suivi de
psql -d gisdb -f elev.SQL
# -d connect to this database
# -f read this file after connecting

# en une seule fois
raster2pgsql -s 4326 -I -C -M -F -t 100x100 *.tif public.demelevation | psql -d gisdb


--------------------------------------------------------------------------------------------------------
raster2pgsql -s 2154 -I -C -M 2017_2classes_2y_CR.tif -F public.2017_rec | psql -d inventaire -p 5433