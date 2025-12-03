
SELECT npp, azdcoi, azdlim, azdlim2, azlim1, azlim2, dcoi, dlim, dlim2, plas15, plas25,
azdcoi_gd, azdlim_gd, azdlim2_gd, azlim1_gd, azlim2_gd, dcoi_cm, dlim_cm, dlim2_cm, 'g3f' AS table
FROM prod_exp.g3foret
UNION
SELECT npp, azdcoi, azdlim, azdlim2, azlim1, azlim2, dcoi, dlim, dlim2, plas15, plas25,
azdcoi_gd, azdlim_gd, azdlim2_gd, azlim1_gd, azlim2_gd, dcoi_cm, dlim_cm, dlim2_cm, 'p3p' AS table
FROM prod_exp.p3point
ORDER BY npp;
