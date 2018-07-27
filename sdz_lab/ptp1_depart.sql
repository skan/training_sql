CREATE DATABASE p2p_blog CHARACTER SET 'utf8';
USE p2p_blog;

DROP TABLE IF EXISTS Categorie ;
CREATE TABLE Categorie (
	id INT UNSIGNED AUTO_INCREMENT,
	nom VARCHAR(150) NOT NULL,
	description TEXT NOT NULL,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS Categorie_article;
CREATE TABLE Categorie_article (
	categorie_id INT UNSIGNED,
	article_id INT UNSIGNED,
	PRIMARY KEY (categorie_id, article_id)
);

DROP TABLE IF EXISTS Utilisateur ;
CREATE TABLE Utilisateur (
	id INT UNSIGNED PRIMARY	KEY AUTO_INCREMENT,
	pseudo VARCHAR (40) NOT NULL,
	mail VARCHAR (30) NOT NULL,
	mdp VARCHAR (15) NOT NULL
	)
	ENGINE=InnoDB;

DROP TABLE IF EXISTS Article;
CREATE TABLE Article (
	numero INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	titre TEXT NOT NULL,
	texte TEXT NOT NULL,
	utilisateur INT UNSIGNED NOT NULL,
	date_insertion DATE NOT NULL
	)
	ENGINE=InnoDB;

DROP TABLE IF EXISTS Commentaires;
CREATE TABLE Commentaires (
	id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	article_id INT UNSIGNED NOT NULL,
	utilisateur INT UNSIGNED,
	commentaire TEXT NOT NULL,
	date_commentaire DATE NOT NULL
	)
	ENGINE=InnoDB;

--- FOREIGN KEYS
ALTER TABLE Article 
	ADD CONSTRAINT fk_user_numero  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id);
ALTER TABLE Commentaires 
	ADD CONSTRAINT fk_commentaire_article FOREIGN KEY (article_id) REFERENCES Article(numero),
	ADD CONSTRAINT fk_commentaire_utilisateur FOREIGN KEY (utilisateur) REFERENCES Utilisateur(id);
ALTER TABLE Categorie_article 
	ADD CONSTRAINT fk_article_cat FOREIGN KEY (article_id) REFERENCES Article(numero),
	ADD CONSTRAINT fk_categorie_cat FOREIGN KEY (categorie_id) REFERENCES Categorie(id);

--- INDEX
CREATE UNIQUE INDEX unique_email ON Utilisateur(email);
CREATE UNIQUE INDEX unique_pseudo ON Utilisateur(pseudo);
CREATE UNIQUE INDEX unique_categorie ON categorie(nom);