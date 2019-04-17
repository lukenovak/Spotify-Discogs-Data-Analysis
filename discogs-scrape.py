import discogs_client
import psycopg2
import time

# create the db connection
dbconn = psycopg2.connect(host='', dbname='',
                          user='', password=''`)
cur = dbconn.cursor()
cur2 = dbconn.cursor()
print("connected to db\n")

d = discogs_client.Client('DiscogsFormatDataAnalyzer/0.1', user_token='insert token here')

#get the albums table
cur.execute("SELECT * FROM albums WHERE genre IS NULL;")
for album in cur:
  album_info=d.search(album[1], artist=album[2], type='master')
  print("getting album " + album[1], ", with id " + album[0])
  if len(album_info) > 0:
    album_format=album_info[0].main_release.formats[0]['name']
    album_genre=album_info[0].genres[0]
    cur2.execute("INSERT INTO releases (id, format) VALUES (%s, %s)", (album[0], album_format))
    dbconn.commit()
    cur2.execute("UPDATE albums SET genre = %s WHERE id = %s", (album_genre, album[0]))
    dbconn.commit()
  ## we need to sleep to avoid rate limits
  time.sleep(2)
  

cur.close()
dbconn.close()
