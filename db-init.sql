
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
  PRIMARY KEY(id)
);

CREATE TABLE releases(
  upc char(13),
  format varchar(64),
  PRIMARY KEY(upc)
);

CREATE TABLE songs(
  id varchar(22)  NOT NULL,
  album_id varchar(22),
  name varchar(255),
  popularity integer,
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
)
