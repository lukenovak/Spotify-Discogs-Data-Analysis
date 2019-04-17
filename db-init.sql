
CREATE TABLE albums(
  id varchar(22)  NOT NULL,
  title varchar(255),
  artist varchar(255),
  upc char(13),
  year integer,
  genre varchar(255),
  PRIMARY KEY(id)
);

CREATE TABLE artists(
  id varchar(255)  NOT NULL,
  name varchar(255),
  popularity integer,
  primary_genre varchar(100),
  PRIMARY KEY(id)
);

CREATE TABLE releases(
  id varchar(255) NOT NULL, 
  format varchar(64),
  PRIMARY KEY(id)
);

CREATE TABLE songs(
  id varchar(22)  NOT NULL,
  album_id varchar(22),
  name varchar(255),
  popularity integer,
  key integer,
  danceability decimal(10,5),
  valence decimal(10,5),
  tempo integer,
  duration BIGINT,
  PRIMARY KEY(id)
);

CREATE TABLE songs_albums(
  song_id integer,
  album_id integer
);

CREATE TABLE album_samples(
  title varchar(255),
  artist varchar(255),
  id SERIAL NOT NULL,
  PRIMARY KEY(id)

