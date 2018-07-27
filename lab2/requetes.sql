SELECT DATE_FORMAT(date_publication, '%d/%m/%Y') AS DATE, pseudo,titre, count(commentaire.id) as nombre_commentaire
    FROM article 
    INNER JOIN utilisateur ON utilisateur.id = auteur_id 
    RIGHT JOIN commentaire ON article.id = article_id
    GROUP BY article.id
    ORDER BY date_publication ASC;
