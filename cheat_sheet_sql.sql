--- Install my SQL

--- Setup 
	set PATH=%PATH%;"c:\Program Files\MySQL\MySQL Server 8.0\bin"
	mysql -u root -p --default-character-set=utf8
--- Create database
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
	SELECT * FROM Livre WHERE MATCH(titre) AGAINST ('+bonheur* -ogres' IN BOOLEAN MODE);
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
        	--- For update and DELETE we can't delete tables which is used into the subquery
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

--- Operations
		SELECT nom_courant, prix, 
	       prix+100 AS addition, prix/2 AS division,
	       prix-50.5 AS soustraction, prix%3 AS modulo
		FROM Espece;
		
		UPDATE Race  SET prix = prix + 35;
	
--- Functions
	SELECT MIN(date_naissance)     -- On utilise ici une fonction !
	FROM (
	    SELECT Animal.id, Animal.sexe, Animal.date_naissance, Animal.nom, Animal.espece_id
	    FROM Animal
	    INNER JOIN Espece
	        ON Espece.id = Animal.espece_id
	    WHERE Espece.nom_courant IN ('Tortue d''Hermann', 'Perroquet amazone')
	) AS tortues_perroquets;
	
	-- Fonction sans paramètre
		SELECT PI();    -- renvoie le nombre Pi, avec 5 décimales
		INSERT INTO Animal (sexe, date_naissance, nom, espece_id, race_id) 
			VALUES ('M', '2010-11-05', 'Pipo', 1, LAST_INSERT_ID());  -- LAST_INSERT_ID() -- le dernier ID crée par auto-incrémentation , pour la connexion en cours

		SELECT id, nom, espece_id, prix FROM Race;
		SELECT FOUND_ROWS(); -- nombre de lignes de la dernière requête (ne considère pas LIMIT si on rajoute SQL_CALC_FOUND_ROWS)
	-- Fonction avec un paramètre
		SELECT MIN(prix) AS minimum  FROM Espece;
		SELECT nom, prix, ROUND(prix) FROM Race;
		
		SELECT CAST('870303' AS DATE);
	
	-- Fonction avec plusieurs paramètres
		SELECT REPEAT('fort ! Trop ', 4);  -- répète une chaîne (ici : 'fort ! Trop ', répété 4 fois)
		
	--- Fonctions scalaires : Sur chaque ligne
		SELECT CEIL(3.2), CEIL(3.7); -- arrondit au nombre entier supérieur (4 ici). 
		SELECT FLOOR(3.2), FLOOR(3.7); --  arrondit au nombre entier inférieur (3 ici). 
		SELECT ROUND(3.22, 1), ROUND(3.55, 1), ROUND(3.77, 1);  -- arrondit au nombre à d (défault, d = 0) décimales le plus proche (3.2; 3.6; 3.8)
		SELECT TRUNCATE(3.2, 0), TRUNCATE(3.5, 0), TRUNCATE(3.7, 0);--  arrondit en enlévant les décimals ((3;3;3)
		SELECT POW(2, 5), POWER(5, 2);
		SELECT SQRT(4);
		SELECT RAND();
		SELECT SIGN(-43), SIGN(0), SIGN(37); --- (-1;0;1)
		SELECT ABS(-43), ABS(0), ABS(37); --- 43;0;3;7
		SELECT MOD(56, 10); --- 6
		
		SELECT BIT_LENGTH('élevage'), CHAR_LENGTH('élevage'), LENGTH('élevage'); -- Les caractères accentués sont codés sur 2 octets en UTF-8  (64,7,8)
		SELECT STRCMP('texte', 'texte') AS 'texte=texte', 
			STRCMP('texte','texte2') AS 'texte<texte2', 
			STRCMP('chaine','texte') AS 'chaine<texte', 
			STRCMP('texte', 'chaine') AS 'texte>chaine',
			STRCMP('texte3','texte24') AS 'texte3>texte24'; -- 3 est après 24 dans l'ordre alphabétique  --> 0 ;-1;-1;1;1
		LPAD(texte, long, caract)
		RPAD(texte, long, caract) -- retourne une chaine de longeur long ; si texte > long --> raccours; sinon complète avec cartact à gauche ou droit
		TRIM : supprime les characteres avec ou après le texte
		SUBSTRING: retourne un partie du texte
			SELECT SUBSTRING('texte', 2) AS from2,
					SUBSTRING('texte' FROM 3) AS from3,
					SUBSTRING('texte', 2, 3) AS from2long3, 
					SUBSTRING('texte' FROM 3 FOR 1) AS from3long1;
		
		SELECT LOWER('AhAh') AS minuscule, 
				LCASE('AhAh') AS minuscule2, 
				UPPER('AhAh') AS majuscule,
				UCASE('AhAh') AS majuscule2;
		SELECT REVERSE('abcde'); --> edcba
		INSERT(chaine, pos, long, nouvCaract)
		REPLACE(chaine, ancCaract, nouvCaract)
		SELECT CONCAT('My', 'SQL', '!'), 
			CONCAT_WS('-', 'My', 'SQL', '!'); -- MySQL! ; My-SQL-!
		FIELD(rech, chaine1, chaine2, chaine3,…) -- retourne l'index ou "rech" est trouve --> 2 si dans chaine 2,
		SELECT ASCII('T'), CHAR(84), CHAR('84', 84+32, 84.2);
	-- Fonctions d'aggregation : sur tout une colonne 
		SELECT COUNT(*) AS nb_chiens FROM Animal  
			INNER JOIN Espece ON Espece.id = Animal.espece_id WHERE Espece.nom_courant = 'Chien'; -- nbre de chiens
		SELECT COUNT(DISTINCT race_id) FROM Animal; -- le nombre de races disctinctes
		SELECT MIN(prix), MAX(prix) FROM Race;
		SELECT SUM(prix) FROM Espece;
		SELECT AVG(prix) FROM Espece;
		SELECT SUM(prix), GROUP_CONCAT(nom_courant) FROM Espece;  --- 1200.00 |Chien,Chat,Tortue d'Hermann,Perroquet amazone,Rat brun	
		--- Regroupement (faire des sous calculs)
			SELECT COUNT(*) AS nb_animaux FROM Animal GROUP BY espece_id; --- 10 ; 9 ;4 ;3
			SELECT espece_id, COUNT(*) AS nb_animaux  FROM Animal GROUP BY espece_id; -- 1:21 ; 2:50;3:15;4:4
			SELECT nom_courant, sexe, COUNT(*) as nb_animaux
				FROM Animal
				INNER JOIN Espece ON Espece.id = Animal.espece_id
				GROUP BY sexe,nom_courant; --- deux sous groupe, l'ordre est important
			
			SELECT nom_courant, sexe, COUNT(*) as nb_animaux FROM Animal  
				INNER JOIN Espece ON Espece.id = Animal.espece_id  
				WHERE sexe IS NOT NULL GROUP BY sexe, nom_courant WITH ROLLUP; -- sum ss groupes

			SELECT COALESCE(nom_courant, 'Total'), COUNT(*) as nb_animaux FROM Animal  -- COALESCE: return first not null
				INNER JOIN Espece ON Espece.id = Animal.espece_id 
				GROUP BY nom_courant WITH ROLLUP; -- total instean NULL
			
			SELECT nom_courant, COUNT(*) FROM Animal INNER JOIN Espece ON Espece.id = Animal.espece_id GROUP BY nom_courant HAVING COUNT(*) > 15; -- for optimisation keep having for groups and where for where

--- DATE & TIME
	--- summary
		/*
		 	for diff: DATEDIFF(), TIMEDIFF(), TIMESTAMPDIFF()
			INTERVAL(amount, unity)
			ADDDATE, DATE_ADD

		*/

	--- Date
		SELECT CURDATE(), CURRENT_DATE(), CURRENT_DATE;
	--- Time
		SELECT CURTIME(), CURRENT_TIME(), CURRENT_TIME;
		SELECT UNIX_TIMESTAMP();
	--- Now
		SELECT NOW(), SYSDATE();
		SELECT LOCALTIME, CURRENT_TIMESTAMP(), LOCALTIMESTAMP;
	--- Inserer directemetn dans une talbe
	
	-- Usage samples
		CREATE TABLE testDate (
			dateActu DATE, 
			timeActu TIME, 
			datetimeActu DATETIME
		);
		INSERT INTO testDate VALUES (NOW(), NOW(), NOW());

		SELECT nom, date_naissance, DATE(date_naissance) AS uniquementDate
			FROM Animal
			WHERE espece_id = 4;

		SELECT nom, DATE(date_naissance) AS date_naiss, 
				DAY(date_naissance) AS jour, 
				DAYOFMONTH(date_naissance) AS jour, 
				DAYOFWEEK(date_naissance) AS jour_sem,
				WEEKDAY(date_naissance) AS jour_sem2,
				DAYNAME(date_naissance) AS nom_jour, 
				DAYOFYEAR(date_naissance) AS jour_annee
		FROM Animal
		WHERE espece_id = 4;

		SET lc_time_names = 'fr_FR'; --- to have days' name in french

		SELECT nom, date_naissance, WEEK(date_naissance) AS semaine, WEEKOFYEAR(date_naissance) AS semaine2, YEARWEEK(date_naissance) AS semaine_annee
			FROM Animal
			WHERE espece_id = 4;   -- 7 ;  8 ;; 200807

		SELECT nom, date_naissance, 
			TIME(date_naissance) AS time_complet, 
			HOUR(date_naissance) AS heure, 
			MINUTE(date_naissance) AS minutes, 
			SECOND(date_naissance) AS secondes
		FROM Animal
		WHERE espece_id = 4;

		SELECT nom, date_naissance, CONCAT_WS(' ', 'le', DAYNAME(date_naissance), DAY(date_naissance), MONTHNAME(date_naissance), YEAR(date_naissance)) AS jolie_date
			FROM Animal
			WHERE espece_id = 4;

		SELECT nom, date_naissance, DATE_FORMAT(date_naissance, 'le %W %e %M %Y') AS jolie_date
			FROM Animal
			WHERE espece_id = 4;

		SELECT DATE_FORMAT(NOW(), 'Nous sommes aujourd''hui le %d %M de l''année %Y. Il est actuellement %l heures et %i minutes.') AS Top_date_longue;

		SELECT DATE_FORMAT(NOW(), '%d %b. %y - %r') AS Top_date_courte;

				--	%d	Jour du mois (nombre à deux chiffres, de 00 à 31)
				--	%e	Jour du mois (nombre à un ou deux chiffres, de 0 à 31)
				--	%D	Jour du mois, avec suffixe (1rst, 2nd,…, 31th) en anglais
				--	%w	Numéro du jour de la semaine (dimanche = 0,…, samedi = 6)
				--	%W	Nom du jour de la semaine
				--	%a	Nom du jour de la semaine en abrégé
				--	%m	Mois (nombre de deux chiffres, de 00 à 12)
				--	%c	Mois (nombre de un ou deux chiffres, de 0 à 12)
				--	%M	Nom du mois
				--	%b	Nom du mois en abrégé
				--	%y	Année, sur deux chiffres
				--	%Y	Année, sur quatre chiffres
				--	%r	Heure complète, format 12h (hh:mm:ss AM/PM)
				--	%T	Heure complète, format 24h (hh:mm:ss)
				--	%h	Heure sur deux chiffres et sur 12 heures (de 00 à 12)
				--	%H	Heure sur deux chiffres et sur 24 heures (de 00 à 23)
				--	%l	Heure sur un ou deux chiffres et sur 12 heures (de 0 à 12)
				--	%k	Heure sur un ou deux chiffres et sur 24 heures (de 0 à 23)
				--	%i	Minutes (de 00 à 59)
				--	%s ou %S	Secondes (de 00 à 59)
				--	%p	AM/PM

-- Sur une DATETIME
SELECT TIME_FORMAT(NOW(), '%r') AS sur_datetime, 
       TIME_FORMAT(CURTIME(), '%r') AS sur_time, 
       TIME_FORMAT(NOW(), '%M %r') AS mauvais_specificateur, 
       TIME_FORMAT(CURDATE(), '%r') AS sur_date;


-- Format standars
SELECT DATE_FORMAT(NOW(), GET_FORMAT(DATE, 'EUR')) AS date_eur,
       DATE_FORMAT(NOW(), GET_FORMAT(TIME, 'JIS')) AS heure_jis,
       DATE_FORMAT(NOW(), GET_FORMAT(DATETIME, 'USA')) AS date_heure_usa;

-- Date à partir d'une chaine
SELECT STR_TO_DATE('03/04/2011 à 09h17', '%d/%m/%Y à %Hh%i') AS StrDate,
       STR_TO_DATE('15blabla', '%Hblabla') StrTime;

--- Diff sur date
	DATEDIFF : résultat en nombre de jours
		SELECT DATEDIFF('2011-12-25','2011-11-10') AS nb_jours;    --45
		SELECT DATEDIFF('2011-12-25 22:12:18','2011-11-10 12:15:41') AS nb_jours;  --45
		SELECT DATEDIFF('2011-12-25 22:12:18','2011-11-10') AS nb_jours; --4
	TIMEDIFF
		Les deux arguments doivent être du meme type (TIME or DATETIME)
		-- Avec des DATETIME
		SELECT '2011-10-08 12:35:45' AS datetime1, '2011-10-07 16:00:25' AS datetime2, TIMEDIFF('2011-10-08 12:35:45', '2011-10-07 16:00:25') as difference;
		
		-- Avec des TIME
		SELECT '12:35:45' AS time1, '00:00:25' AS time2, TIMEDIFF('12:35:45', '00:00:25') as difference;
	TIMESTAMPDIFF (unite, date1, date2)
		SELECT TIMESTAMPDIFF(DAY, '2011-11-10', '2011-12-25') AS nb_jours,
		       TIMESTAMPDIFF(HOUR,'2011-11-10', '2011-12-25 22:00:00') AS nb_heures_def, 
		       TIMESTAMPDIFF(HOUR,'2011-11-10 14:00:00', '2011-12-25 22:00:00') AS nb_heures,
		       TIMESTAMPDIFF(QUARTER,'2011-11-10 14:00:00', '2012-08-25 22:00:00') AS nb_trimestres;
	
-- Ajoute de dates
	Adddate (date,nombre de jours)
	Adddate (date, interval qtté unité)
	SELECT ADDDATE('2011-05-21', INTERVAL 3 MONTH) AS date_interval,  
	        -- Avec DATE et INTERVAL
	       ADDDATE('2011-05-21 12:15:56', INTERVAL '3 02:10:32' DAY_SECOND) AS datetime_interval, 
	        -- Avec DATETIME et INTERVAL
	       ADDDATE('2011-05-21', 12) AS date_nombre_jours,                                        
	        -- Avec DATE et nombre de jours
	       ADDDATE('2011-05-21 12:15:56', 42) AS datetime_nombre_jours;                           
	        -- Avec DATETIME et nombre de jours
	
	DATE_ADD(date, INTERVAL qtté unité)
	SELECT DATE_ADD('2011-05-21', INTERVAL 3 MONTH) AS avec_date,       
	        -- Avec DATE
	       DATE_ADD('2011-05-21 12:15:56', INTERVAL '3 02:10:32' DAY_SECOND) AS avec_datetime;  
	        -- Avec DATETIME
	
	--- Opérateur "+"
	SELECT '2011-05-21' + INTERVAL 5 DAY AS droite,                    
	        -- Avec DATE et intervalle à droite
	       INTERVAL '3 12' DAY_HOUR + '2011-05-21 12:15:56' AS gauche; 
	        -- Avec DATETIME et intervalle à gauche
	

	TIMESTAMPADD(unite, quantite, date)
		SELECT TIMESTAMPADD(DAY, 5, '2011-05-21') AS avec_date,            
		        -- Avec DATE
		       TIMESTAMPADD(MINUTE, 34, '2011-05-21 12:15:56') AS avec_datetime;  
		        -- Avec DATETIME
		
-- Ajoute time
	SELECT NOW() AS Maintenant, ADDTIME(NOW(), '01:00:00') AS DansUneHeure,  
	        -- Avec un DATETIME
	       CURRENT_TIME() AS HeureCourante, ADDTIME(CURRENT_TIME(), '03:20:02') AS PlusTard; 
	        -- Avec un TIME

-- Soustraction d'une intervalle de temps
	SELECT SUBDATE('2011-05-21 12:15:56', INTERVAL '3 02:10:32' DAY_SECOND) AS SUBDATE1, 
	       SUBDATE('2011-05-21', 12) AS SUBDATE2,
	       DATE_SUB('2011-05-21', INTERVAL 3 MONTH) AS DATE_SUB;
	
	SELECT SUBTIME('2011-05-21 12:15:56', '18:35:15') AS SUBTIME1,
	       SUBTIME('12:15:56', '8:35:15') AS SUBTIME2;

-- Operateur "-"
	SELECT '2011-05-21' - INTERVAL 5 DAY;
	
	INTERVAL peut être définit avec une qtté négative
	SELECT ADDDATE(NOW(), INTERVAL -3 MONTH) AS ajout_negatif, SUBDATE(NOW(), INTERVAL 3 MONTH) AS retrait_positif;
	SELECT DATE_ADD(NOW(), INTERVAL 4 HOUR) AS ajout_positif, DATE_SUB(NOW(), INTERVAL - 4 HOUR) AS retrait_negatif;
	SELECT NOW() + INTERVAL -15 MINUTE AS ajout_negatif, NOW() - INTERVAL 15 MINUTE AS retrait_positif;
	
	SELECT FROM_UNIXTIME(1325595287);
	SELECT UNIX_TIMESTAMP('2012-01-03 13:54:47');
	
	
	SELECT MAKEDATE(2012, 60) AS 60eJour2012, MAKETIME(3, 45, 34) AS heureCree;
	
	SELECT SEC_TO_TIME(102569), TIME_TO_SEC('01:00:30');
	
	SELECT LAST_DAY('2012-02-03') AS fevrier2012, LAST_DAY('2100-02-03') AS fevrier2100; 29/02/2012 & 28/12/2100 -- denier jour du mois
