

SELECT ga.incref, ga.mortb, count(ga.mortb)
FROM inv_exp_nm.g3arbre ga
WHERE ga.incref IN  (17, 18, 19)
AND ga.ess = '51'
GROUP BY ga.incref, ga.mortb
ORDER BY incref DESC;

SELECT ga.incref, ga.mortb, count(ga.mortb)
FROM inv_exp_nm.p3arbre ga
WHERE ga.incref IN  (17, 18, 19)
GROUP BY ga.incref, ga.mortb
ORDER BY incref DESC;


SELECT ga.incref, ga.incid, count(ga.incid)
FROM inv_exp_nm.g3foret ga
WHERE ga.incref IN  (17, 18, 19)
GROUP BY ga.incref, ga.incid
ORDER BY incref DESC;

SELECT ga.incref, ga.incid, count(ga.mortb)
FROM inv_exp_nm.p3point ga
WHERE ga.incref IN  (17, 18, 19)
GROUP BY ga.incref, ga.incid
ORDER BY incref DESC;