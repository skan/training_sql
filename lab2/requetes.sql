SELECT DATE_FORMAT(date_publication, '%d/%m/%Y') AS DATE, pseudo,titre, resume, count(commentaire.id) as nombre_commentaire
    FROM article 
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    RIGHT JOIN commentaire ON article.id = article_id
    GROUP BY article.id
    ORDER BY date_publication ASC;

SELECT DATE_FORMAT(date_publication, '%d %M \'%y') AS DATE, pseudo,titre,resume
    FROM article 
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    WHERE auteur_id = 2
    ORDER BY date_publication ASC;
 
SELECT DATE_FORMAT(date_publication, '%d/%m/%Y - %H:%i') AS DATE, pseudo,titre, resume
    FROM article
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    RIGHT JOIN categorie_article ON article.id = categorie_article.article_id
    WHERE categorie_id = 3
    ORDER BY date_publication ASC;

SELECT DATE_FORMAT(date_publication, '%d %M %Y a %H heures %i') AS DATE, titre,contenu, GROUP_CONCAT(categorie.nom) as categorie, pseudo
    FROM article
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    RIGHT JOIN categorie_article ON article.id = categorie_article.article_id
    RIGHT JOIN categorie ON categorie.id = categorie_article.categorie_id
    WHERE article.id = 4
    ORDER BY date_publication ASC;

