--- Setup 
	set PATH=%PATH%;"c:\Program Files\MySQL\MySQL Server 8.0\bin"
	mysql -u root -p --default-character-set=utf8
--- Create & select database
	CREATE DATABASE elevage CHARACTER SET 'utf8';
	USE elevage 
	DROP DATABASE elevage 
---	Create tables
	CREATE TABLE Animal (
	    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
	    espece VARCHAR(40) NOT NULL,
	    sexe CHAR(1),
	    date_naissance DATETIME NOT NULL,
	    nom VARCHAR(30),
	    commentaires TEXT,
	    PRIMARY KEY (id)
		)
		ENGINE=INNODB;

	CREATE TABLE Commande (
	    numero INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	    client INT UNSIGNED NOT NULL,
	    produit VARCHAR(40),
	    quantite SMALLINT DEFAULT 1,
	    CONSTRAINT fk_client_numero          -- On donne un nom à notre clé
	        FOREIGN KEY (client)             -- Colonne sur laquelle on crée la clé
	        REFERENCES Client(numero)        -- Colonne de référence
		)
	ENGINE=InnoDB;                          -- MyISAM interdit, je le rappelle encore une fois !

	SHOW databases;
	DESCRIBE Animal;

---	Modify tables
	ALTER TABLE Test_tuto ADD COLUMN date_insertion DATE NOT NULL;
	ALTER TABLE Test_tuto CHANGE nom prenom VARCHAR(10) NOT NULL;
	ALTER TABLE Test_tuto MODIFY id BIGINT NOT NULL AUTO_INCREMENT;
	ALTER TABLE "table_name" DROP "column_name";

--- create index (UNIQUE |FULLTEXT)
	CREATE INDEX nom_index
		ON nom_table (colonne_index [, colonne2_index ...]);  -- Crée un index simple
	CREATE UNIQUE INDEX nom_index
		ON nom_table (colonne_index [, colonne2_index ...]);  -- Crée un index UNIQUE
	CREATE FULLTEXT INDEX ind_full_titre
		ON Livre (titre);
	ALTER TABLE nom_table
		ADD CONSTRAINT [symbole_contrainte] UNIQUE ind_uni_col2 (colonne2);
--- Create keys 
	ALTER TABLE Commande
		ADD CONSTRAINT fk_client_numero 
			FOREIGN KEY (client) 
			REFERENCES Client(numero);
---	Insert data
	INSERT INTO Animal VALUES (1, 'chien', 'M', '2010-04-05 13:43:00', 'Rox', 'Mordille beaucoup');
	INSERT INTO Animal (espece, sexe, date_naissance, nom) 
	   VALUES ('chien', 'F', '2008-12-06 05:18:00', 'Caroline'),
	                  ('chat', 'M', '2008-09-11 15:38:00', 'Bagherra'),
	                  ('tortue', NULL, '2010-08-23 05:18:00', NULL);
	INSERT INTO Animal 
	   SET nom='Bobo', espece='chien', sexe='M', date_naissance='2010-07-21 15:41:00';
	
	LOAD DATA LOCAL INFILE 'animal.csv'
	   INTO TABLE Animal
	   FIELDS TERMINATED BY ';' ENCLOSED BY '"'
	   LINES TERMINATED BY '\n' -- ou '\r\n' selon l'ordinateur et le programme utilisés pour créer le fichier
	   (espece, sexe, date_naissance, nom, commentaires);
	
---	Show data
	SELECT * FROM Animal;
	SELECT * FROM Animal ORDER BY id LIMIT 6 OFFSET 3;
	SELECT * FROM Animal WHERE espece='chien'  AND nom IS NOT NULL ORDER BY nom DESC;
	SELECT * FROM Animal WHERE sexe='M' XOR espece='perroquet' ORDER BY nom ASC;
	SELECT * FROM espece WHERE Espece.nom_courant IN ('Perroquet amazone', 'Chat')
	
---	Backup & load
	mysqldump -u root -p --opt elevage > elevage_sauvegarde.sql
	CREATE DATABASE nom_base
	mysql nom_base < chemin_fichier_de_sauvegarde.sql
	
---	Call script
		Source file.sql
		\. file.sql
---	Delete lines
	DELETE FROM Animal WHERE nom = 'Zoulou';
---	Change values 
	UPDATE Animal SET sexe='F', nom='Pataude' WHERE id=21;
--- Search using patterns and jockers	
	SELECT * FROM Livre WHERE MATCH(auteur) AGAINST ('Terry');
	SELECT *  FROM Livre WHERE MATCH(titre) AGAINST ('+bonheur* -ogres' IN BOOLEAN MODE);
--- Jointures
	SELECT Espece.description 
        FROM Espece 
        INNER JOIN Animal ON Espece.id = Animal.espece_id 
        WHERE Animal.nom =  'Cartouche';
    SELECT Espece.id, Espece.description, Animal.nom 
        FROM Espece 
        INNER JOIN Animal ON Espece.id = Animal.espece_id 
        WHERE Animal.nom LIKE 'Ch%';
--- Left Join	
    SELECT Animal.nom AS nom_animal, Race.nom AS race
        FROM Animal                         -- Table de gauche
        LEFT JOIN Race                      -- Table de droite
            ON Animal.race_id = Race.id
        WHERE Animal.espece_id = 2 AND Animal.nom LIKE 'C%'
        ORDER BY Race.nom, Animal.nom;
--- Right joing
    SELECT Animal.nom AS nom_animal, Race.nom AS race
        FROM Animal                                              -- Table de gauche
        RIGHT OUTER JOIN Race                                    -- Table de droite
            ON Animal.race_id = Race.id
        WHERE Race.espece_id = 2
        ORDER BY Race.nom, Animal.nom;
--- Alternatives for using join (column with same name)
    SELECT * FROM table1 JOIN table2 USING (colonneJ);  -- colonneJ est présente dans les deux tables
    SELECT * FROM table1 NATURAL JOIN table2;
--- Sous requêtes
    	SELECT MIN(date_naissance)
	        FROM (
	            SELECT Animal.id, Animal.sexe, Animal.date_naissance, Animal.nom, Animal.espece_id
	            FROM Animal
	            INNER JOIN Espece
	                ON Espece.id = Animal.espece_id
	            WHERE sexe = 'F' AND Espece.nom_courant IN ('Tortue d''Hermann', 'Perroquet amazone')
                ) AS tortues_perroquets_F;
    --- return one value
        SELECT id, sexe, nom, commentaires, espece_id, race_id
	        FROM Animal
	        WHERE race_id = (SELECT id FROM Race WHERE nom = 'Berger Allemand');  -- la sous-requête renvoie simplement 1
    	SELECT id, nom, espece_id
        	FROM Race
        	WHERE espece_id = ( SELECT MIN(id) FROM Espece );
    	SELECT id, nom, espece_id
        	FROM Race  
        	WHERE espece_id < (
	            SELECT id    
	            FROM Espece
                WHERE nom_courant = 'Tortue d''Hermann');
    -- return a line
        SELECT id, sexe, nom, espece_id, race_id 
	        FROM Animal
	        WHERE (id, race_id) = (
	            SELECT id, espece_id
	            FROM Race
                WHERE id = 7);
    --- return a column
        SELECT id, nom, espece_id
        	FROM Animal
        	WHERE espece_id IN (
	            SELECT id 
	            FROM Espece
	            WHERE nom_courant IN ('Tortue d''Hermann', 'Perroquet amazone'));
    --- ANY (SOME) & ALL
        SELECT * FROM Animal
            WHERE espece_id < ANY (
                SELECT id
                FROM Espece
                WHERE nom_courant IN ('Tortue d''Hermann', 'Perroquet amazone'));
    --- sous requêtes corrélées
        SELECT id, nom, espece_id 
            FROM Race 
            WHERE EXISTS (SELECT * FROM Animal WHERE nom = 'Balou'); -- list all races as exists return TRUE
        ---Exemple : je veux sélectionner toutes les races dont on ne possède aucun animal.
            SELECT * FROM Race
                WHERE NOT EXISTS (SELECT * FROM Animal WHERE Animal.race_id = Race.id);
    --- sous requêtes for insertion
        INSERT INTO Animal 
	        (nom, sexe, date_naissance, race_id, espece_id) -- Je précise les colonnes puisque je ne donne pas une valeur pour toutes.
	        SELECT  'Yoda', 'M', '2010-11-09', id AS race_id, espece_id   -- Attention à l'ordre !
                FROM Race WHERE nom = 'Maine coon';
    --- sous requêtes for modification
       	UPDATE Animal 
            SET commentaires = 'Coco veut un gâteau !' 
            WHERE espece_id = (SELECT id FROM Espece WHERE nom_courant LIKE 'Perroquet%');
		UPDATE Animal 
            SET race_id = (SELECT id FROM Race WHERE nom = 'Nebelung' AND espece_id = 2)
            WHERE nom = 'Cawette';
    --- sous requêtes for deletion
       	DELETE FROM Animal
	        WHERE nom = 'Carabistouille' AND espece_id = (SELECT id FROM Espece WHERE nom_courant = 'Chat');
            --- same as (using join)
                DELETE Animal   -- Je précise de quelles tables les données doivent être supprimées
                    FROM Animal     -- Table principale
                    INNER JOIN Espece ON Animal.espece_id = Espece.id  -- Jointure     
                    WHERE Animal.nom = 'Carabistouille' AND Espece.nom_courant = 'Chat';
        --- For update and DELETE we can can't delete tables which is used into the subquery
--- UNIONS        
    --- ALL & DISTINCT
		SELECT * FROM Espece
		UNION ALL
		SELECT * FROM Espece; --- duplication

    	SELECT * FROM Espece 
		UNION 
        SELECT * FROM Espece; --- no duplication
    --- limit
        SELECT id, nom, 'Race' AS table_origine FROM Race LIMIT 3
		UNION
        (SELECT id, nom_latin, 'Espèce' AS table_origine FROM Espece LIMIT 2); -- need bracket for limit on last query
    --- order
		(SELECT id, nom, 'Race' AS table_origine FROM Race ORDER BY nom DESC LIMIT 6)
		UNION
        (SELECT id, nom_latin, 'Espèce' AS table_origine FROM Espece LIMIT 3);
-- ON DELETE
    --- create Foreign Key
        	ALTER TABLE nom_table
		        ADD [CONSTRAINT fk_col_ref]         -- On donne un nom à la clé (facultatif)
		        FOREIGN KEY colonne             -- La colonne sur laquelle on ajoute la clé
                    REFERENCES table_ref(col_ref);  -- La table et la colonne de référence
    --- Configure action (NO ACTION | RESTRICT | SET NULL | CASCADE )
        ALTER TABLE Animal DROP FOREIGN KEY fk_race_id; -- first delete previous config
		ALTER TABLE Animal 
			ADD CONSTRAINT fk_race_id 
            FOREIGN KEY (race_id) 
                REFERENCES Race(id) 
                ON DELETE SET NULL;
--- ACTION on constraint violation (IGNORE | REPLACE)
    --- IGNORE
    	INSERT IGNORE INTO Espece (nom_courant, nom_latin, description)
        	VALUES ('Chien en peluche', 'Canis canis', 'Tout doux, propre et  silencieux');
	
    	UPDATE IGNORE Espece 
            SET nom_latin = 'Canis canis' 
            WHERE nom_courant = 'Chat';
	
    	LOAD DATA [LOCAL] INFILE 'nom_fichier' IGNORE    -- IGNORE se place juste avant INTO, comme dans INSERT
	        INTO TABLE nom_table
	            [FIELDS
	                [TERMINATED BY '\t']
	                [ENCLOSED BY '']
	                [ESCAPED BY '\\' ]
	            ]           
            	[LINES 
	                [STARTING BY '']    
	                [TERMINATED BY '\n']
            	]
            	[IGNORE nombre LINES]
            	[(nom_colonne,...)];
    --- REPLACE (modify as many lines as needed to handle unicity)
        REPLACE INTO Animal (sexe, nom, date_naissance, espece_id)
		    VALUES ('F', 'Spoutnik', '2010-08-06 15:05:00', 3);  -- 2 rows affected, delete previous, insert new
		
		REPLACE INTO Animal (id, sexe, nom, date_naissance, espece_id) 
		    VALUES (32, 'M', 'Spoutnik', '2009-07-26 11:52:00', 3); --	3 rows affected : old 32 , old spoutnik , new insertion
	
		LOAD DATA [LOCAL] INFILE 'nom_fichier' REPLACE       -- se place au même endroit que IGNORE
		    INTO TABLE nom_table
            ...
    --- ON DUPLICATE KEY UPDATE (insert si no constraint of unicity. DANGER: if many lines are concerned il will modify one RANDOMLY)
        INSERT INTO Animal (sexe, date_naissance, espece_id, nom, mere_id)
		    VALUES ('M', '2010-05-27 11:38:00', 3, 'Spoutnik', 52) 
            ON DUPLICATE KEY UPDATE mere_id = 52;
