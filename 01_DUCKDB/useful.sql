-- EXTENSION POSTGRES
INSTALL postgres; --> le faire hors réseau !
LOAD postgres;


-- IMPORT CSV
CREATE TABLE pdsa AS SELECT * FROM read_csv('/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref18/donnees/Poids_Arbres_Incref18.csv');
-- ou
CREATE TABLE main.pdsa_bis AS FROM read_csv('/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref18/donnees/Poids_Arbres_Incref18.csv');

SELECT * FROM read_csv('/home/lhaugomat/Documents/GITLAB/exploitation/inv_exp_nm/Incref18/donnees/Poids_Arbres_Incref18.csv');

-- EXPORT csv
COPY tbl TO 'output.csv' (HEADER, DELIMITER ',');
COPY (SELECT * FROM tbl) TO 'output.csv' (HEADER, DELIMITER ',');


-- IMPORT / EXPORT EXCEL sheets
INSTALL spatial;
LOAD spatial;

SELECT * FROM st_read('test_excel.xlsx');
SELECT * FROM st_read('test_excel.xlsx', layer = 'Sheet1');

CREATE TABLE new_tbl AS SELECT * FROM st_read('test_excel.xlsx', layer = 'Sheet1');  
INSERT INTO tbl SELECT * FROM st_read('test_excel.xlsx', layer = 'Sheet1');
    
COPY tbl TO 'output.xlsx' WITH (FORMAT GDAL, DRIVER 'xlsx');
COPY (SELECT * FROM tbl) TO 'output.xlsx' WITH (FORMAT GDAL, DRIVER 'xlsx');
   
  