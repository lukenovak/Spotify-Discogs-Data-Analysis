SELECT * INTO album_samples_unique 
FROM album_samples AS a
WHERE NOT EXISTS (
    SELECT 1 FROM album_samples AS b 
    WHERE b.title = a.title AND 
          b.artist = a.artist AND 
          b.id > a.id);
