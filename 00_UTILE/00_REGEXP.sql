

SELECT regexp_matches('foobarbequebazilbarfbonk', '(b[^b]+)(b[^b]+)', 'g');

SELECT regexp_replace('foobarbaz', 'b..', 'X');                    
SELECT regexp_replace('foobarbaz', 'b..', 'X', 'g');                               
SELECT regexp_replace('foobarbaz', 'b(..)', 'X\1Y', 'g');
                                