

-- via DuckDB
LOAD postgres;


ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg1 (TYPE postgres);













