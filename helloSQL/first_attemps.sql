SELECT animal.nom, race.nom as race_animal, pere_race.nom as race_du_pere, mere_race.nom as race_de_la_mere, espece.nom_courant as espece_animal
FROM animal
INNER JOIN animal as pere 
    ON animal.pere_id = pere.id
INNER JOIN race as pere_race 
    ON pere.race_id = pere_race.id
INNER JOIN animal as mere 
    ON animal.mere_id = mere.id
INNER JOIN race as mere_race 
    ON mere.race_id = mere_race.id
INNER JOIN race 
    ON animal.race_id = race.id
INNER JOIN espece 
    ON animal.espece_id = espece.id;

/*SELECT animal.nom from animal
INNER JOIN animal AS pere 
    ON animal.pere_id = pere.id
where pere.nom = "Bouli"*/
a
/*SELECT animal.nom, pere.nom, mere.nom
FROM animal
INNER JOIN animal AS pere 
    ON animal.pere_id = pere.id
INNER JOIN animal AS mere
    ON animal.mere_id = mere.id 
INNER JOIN espece 
    ON animal.espece_id = espece.id
WHERE espece.nom_courant = "CHAT";*/

/* SELECT animal.nom AS nom_animal, animal.sexe AS sexe_animal, espece.nom_latin AS nom_latin , race.nom AS race_animal
FROM animal
INNER JOIN espece ON animal.espece_id = espece.id 
LEFT JOIN RACE ON animal.race_id = race.id
WHERE espece.nom_courant IN ('CHAT','Perroquet amazone')
ORDER BY nom_latin, race_animal; */

/*SELECT animal.nom AS nom_animal, animal.date_naissance as animal_date, race.nom as race_animal 
FROM animal
INNER JOIN race on animal.race_id = race.id
INNER JOIN espece on animal.espece_id = espece.id
WHERE animal.sexe = "F" AND animal.date_naissance < "2010-01-01" AND espece.nom_courant = "chien";*/

/*SELECT animal.nom 
FROM animal 
LEFT JOIN espece ON animal.espece_id = espece.id
WHERE animal.pere_id IS NOT NULL AND animal.mere_id IS NOT NULL AND espece.nom_courant = "CHAT"; */
