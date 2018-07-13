USE master;
DROP DATABASE p2p_blog;
CREATE DATABASE p2p_blog CHARACTER SET 'utf8';
USE p2p_blog;

CREATE TABLE Categorie (
	id INT UNSIGNED AUTO_INCREMENT,
	nom VARCHAR(150) NOT NULL,
	description TEXT NOT NULL,
	PRIMARY KEY(id)
);
ALTER TABLE categorie ADD CONSTRAINT UNIQUE (nom);

CREATE TABLE Categorie_article (
	categorie_id INT UNSIGNED,
	article_id INT UNSIGNED,
	PRIMARY KEY (categorie_id, article_id)
);

CREATE TABLE Utilisateur (
	id INT UNSIGNED PRIMARY	KEY AUTO_INCREMENT,
	pseudo VARCHAR (40),
	mail VARCHAR (30),
	mdp VARCHAR (15)
	)
	ENGINE=InnoDB;

CREATE TABLE Article (
	numero INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	titre TEXT NOT NULL,
	texte TEXT NOT NULL,
	utilisateur INT UNSIGNED NOT NULL,
	date_insertion DATE NOT NULL,
	CONSTRAINT fk_user_numero
		FOREIGN KEY (utilisateur)
		REFERENCES Utilisateur(id)
	)
	ENGINE=InnoDB;
	ALTER TABLE Article DROP FOREIGN KEY fk_user_numero;
	/*
	ALTER TABLE Article
		 ADD CONSTRAINT fk_user_numero
		 	FOREIGN KEY (utilisateur)
			REFERENCES Utilisateur(id)
			ON DELETE SET NULL;*/
CREATE TABLE Commentaires (
	id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	article_id INT UNSIGNED,
	utilisateur INT UNSIGNED,
	commentaire TEXT NOT NULL,
	date_commentaire DATE NOT NULL,
	CONSTRAINT fk_commentaire_article
		FOREIGN KEY (article_id)
		REFERENCES Article(numero)
		ON DELETE CASCADE,
	CONSTRAINT fk_commentaire_utilisateur
		FOREIGN KEY (utilisateur)
		REFERENCES Utilisateur(id)
		ON DELETE CASCADE
	)
	ENGINE=InnoDB;
