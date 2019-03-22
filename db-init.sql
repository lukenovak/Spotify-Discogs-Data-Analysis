
CREATE TABLE albums(
  id SERIAL NOT NULL,
  title varchar(255),
  artist integer,
  upc integer,
  year integer,
  PRIMARY KEY(id)
);

CREATE TABLE artists(
  id SERIAL NOT NULL,
  name varchar(255),
  popularity integer,
  PRIMARY KEY(id)
);

CREATE TABLE releases(
  upc integer,
  format varchar(64),
  PRIMARY KEY(upc)
);

CREATE TABLE songs(
  id SERIAL NOT NULL,
  name varchar(255),
  popularity integer,
  PRIMARY KEY(id)
);

CREATE TABLE songs_albums(
  song_id integer,
  album_id integer
);
