select date_format(date_publication, '%d/%m/%Y') as date, pseudo,titre, resume 
    from article 
    inner join utilisateur on utilisateur.id = auteur_id 
    order by date_publication asc;