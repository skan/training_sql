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