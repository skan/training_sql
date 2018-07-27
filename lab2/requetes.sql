SELECT DATE_FORMAT(date_publication, '%d/%m/%Y') AS DATE, pseudo,titre, resume, count(commentaire.id) as nombre_commentaire
    FROM article 
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    RIGHT JOIN commentaire ON article.id = article_id
    GROUP BY article.id
    ORDER BY date_publication ASC;

/*Il faut la date de publication (format “12 octobre ‘14” - attention à l’apostrophe devant l’année à deux chiffres), 
pseudo de l’auteur, titre et résumé de chaque article (triés du plus récent au plus vieux) écrits par l’auteur 2.*/

SELECT DATE_FORMAT(date_publication, '%d %M \'%y') AS DATE, pseudo,titre,resume
    FROM article 
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    WHERE auteur_id = 2
    ORDER BY date_publication ASC;
 
 /* Categorie - id de la catégorie = 3
Il faut la date de publication (format “12/10/2014 - 17:47”), pseudo de l’auteur, titre et résumé de chaque article (triés du plus récent au plus vieux) de la catégorie 3.'*/

SELECT DATE_FORMAT(date_publication, '%d/%m/%Y - %H:%i') AS DATE, pseudo,titre, resume
    FROM article
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    RIGHT JOIN categorie_article ON article.id = categorie_article.article_id
    WHERE categorie_id = 3
    ORDER BY date_publication ASC;

/*Article - id de l’article = 4
On a déjà les commentaires. Il manque donc la requête pour récupérer 
la date de publication (format “12 octobre 2014 à 17 heures 47”), le titre, le contenu, les noms des catégories de l’article 4, ainsi que le pseudo de son auteur.*/

SELECT DATE_FORMAT(date_publication, '%d %M %Y a %H heures %i') AS DATE, titre, pseudo, GROUP_CONCAT(categorie.nom) as categorie
    FROM article
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    RIGHT JOIN categorie_article ON article.id = categorie_article.article_id
    RIGHT JOIN categorie ON categorie.id = categorie_article.categorie_id
    WHERE article.id = 4
    ORDER BY date_publication ASC;

