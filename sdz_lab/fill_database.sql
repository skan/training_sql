INSERT INTO utilisateur (pseudo, mail, mdp) VALUES
    ('skander', 'skander@gmail.com', '123456'),
    ('Olivier', 'oliver@gmail.com', '987654'),
    ('David', 'david@gmail.com', '456789');
INSERT INTO categorie (nom, description) VALUES
    ('humour', "description d'humour"),
    ('information', "description d'information"),
    ('actualite', "description d'actualite");

INSERT INTO Article (titre, texte, utilisateur,date_insertion) VALUES
    ('titre1','texte du titre 1',2,DATE '2018-07-10');
INSERT INTO Article (titre, texte, utilisateur,date_insertion) VALUES
    ('titre2','texte du titre 2',3,DATE '2018-07-12');
INSERT INTO Categorie_article VALUES 
    (1,1),(1,2),(2,2),(2,3);
INSERT INTO Article (titre, texte, utilisateur,date_insertion) VALUES
    ('titre3','texte du titre 3',1,DATE '2018-05-12');
INSERT INTO Categorie_article VALUES 
    (3,1),(3,3);

INSERT INTO commentaires (article_id, utilisateur, commentaire, date_commentaire) VALUES
    (1,NULL,"bien", DATE '2018-07-13'),
    (1,2,"interessant", DATE '2018-06-12'),
    (3,1,"continue", DATE '2018-06-10'),
    (2,3,"a verifier", DATE '2018-05-20'),
    (3,NULL,"faut !", DATE '2018-04-09');

select titre, date_insertion as date_de_publication, utilisateur.pseudo AS auteur, texte as Resume
FROM Article
INNER JOIN utilisateur ON utilisateur = utilisateur.id
ORDER BY date_de_publication;

SELECT utilisateur.pseudo as Auteur, Article.titre, Article.date_insertion as date_de_publication
FROM utilisateur
INNER JOIN article on id = Article.utilisateur
ORDER BY date_de_publication DESC;

select categorie.nom as categorie, article.titre as article, article.date_insertion as date_de_publication
from Categorie_article
INNER JOIN article on article_id = article.numero
INNER JOIN categorie on categorie_id = categorie.id
ORDER BY categorie,date_de_publication DESC;

select article.titre, article.texte, commentaire, date_commentaire
from commentaires
LEFT join article on article_id = article.numero
WHERE article.numero = 1
ORDER BY date_commentaire;
