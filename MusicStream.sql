USE MusicStream;
SELECT * FROM MusicStream.Spotify;
SELECT * FROM MusicStream.Last_fm;

# Modificación de la tabla Spotify usando ALTER:
ALTER TABLE Spotify
MODIFY COLUMN Artist VARCHAR(50) PRIMARY KEY NOT NULL;
ALTER TABLE Spotify
MODIFY COLUMN Genre VARCHAR(50);
ALTER TABLE Spotify
MODIFY COLUMN Type VARCHAR(50);
ALTER TABLE Spotify
MODIFY COLUMN Year YEAR;
ALTER TABLE Spotify
MODIFY COLUMN Id_spotify VARCHAR(50);

# Modificación de la tabla Last_fm usando ALTER:
ALTER TABLE Last_fm
MODIFY COLUMN Artist VARCHAR(50) PRIMARY KEY NOT NULL,
ADD CONSTRAINT fk_Last_fm_Spotify FOREIGN KEY (Artist) REFERENCES Spotify(Artist);
ALTER TABLE Last_fm
MODIFY COLUMN Playcount INT;
ALTER TABLE Last_fm
MODIFY COLUMN Listeners INT;

-- -----------------------------------------------------------------

-- PREGUNTA 1 --
-- AÑO CON MÁS ÁLBUMES PUBLICADOS EN LOS ÚLTIMOS 5 AÑOS: --
-- (Número de álbumes lanzados por año) --
-- Pregunta de Almu: ¿En qué año se lanzaron más álbumes? --
SELECT
s.Year AS 'Año',
COUNT(s.Type) AS 'Número de Álbumes'
FROM Spotify AS s
WHERE s.Type = 'album'
GROUP BY s.Year
ORDER BY COUNT(s.Type) DESC;
-- Resultados:
-- 2024 - 7 álbumes
-- 2020 - 3 álbumes
-- 2021 - 1 álbumes
-- 2022 - 1 álbumes
-- 2023 - 0 álbumes

-- PREGUNTA 2 --
-- LOS GÉNEROS MÁS VALORADOS LOS ÚLTIMOS 5 AÑOS: --
-- (Número de oyentes por género) --
-- Pregunta de Almu: ¿Qué género es el mejor valorado? --
SELECT
s.Genre AS 'Género',
MAX(l.Listeners) AS 'Popularidad'
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Genre;
-- Resultado:
-- pop - 6.364.712
-- rock - 5.746.091
-- electronic - 2.342.451
-- flamenco - 275.616  

-- PREGUNTA 3 --
-- ARTISTAS MÁS VALORADOS LOS ÚLTIMOS 5 AÑOS Y SU SINGLES/ÁLBUM: --
-- (Los 5 artistas con más oyentes y el título de su single o álbum) --
-- Pregunta de Almu: ¿Cuál es el artista con más valoración? --
SELECT
s.Artist AS 'Artista',
s.Title AS 'Título',
MAX(l.Listeners)
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Artist
ORDER BY MAX(l.Listeners) DESC
LIMIT 5;
-- Resultados: 
-- Lady Gaga - 6.364.712 - Die With A Smile
-- Linkin Park - 5.746.091 - The Emptiness Machine
-- Elton John - 4.421.245 - Cold Heart - PNAU Remix
-- The Weeknd - 4.308.766 - Blinding Lights
-- Shakira - 4.055.801 - Soltera

-- PREGUNTA 4 --
-- SINGLES MÁS VALORADOS EN LOS AÑOS PARES: --
-- Pregunta de Almu: ¿Cuál es el álbum más valorado de los años pares de mi selección? --
SELECT
x.Year AS 'Año',
x.Artist AS 'Artista',
x.Title AS 'Título',
x.Listeners AS 'Oyentes'
FROM (
    SELECT
	s.Year,
	s.Artist,
	s.Title,
	l.Listeners,
	ROW_NUMBER() OVER (PARTITION BY s.Year ORDER BY l.Listeners DESC) AS rn
    FROM Spotify AS s
    LEFT JOIN Last_fm AS l 
    ON s.Artist = l.Artist
    WHERE s.Year % 2 = 0
) AS x
WHERE rn <= 1;
-- Resultado:
-- 2020 - The Weeknd - Blinding Lights - 4.308.766 oyentes.
-- 2022 - OneRepublic - I Ain't Worried - 3.814.842 oyentes.
-- 2024 - Lady Gaga - Die With A Smile - 6.364.712 oyentes.

-- PEGUNTA 5 --
-- ARTISTAS MÁS ESCUCHADOS LOS ÚLTIMOS 5 AÑOS Y SU SINGLES/ÁLBUM: --
-- (Los 5 artistas con más reproducciones y el título de su single o álbum) --
SELECT
s.Artist AS 'Artista',
s.Title AS 'Título',
MAX(l.Playcount)
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Artist
ORDER BY MAX(l.Playcount) DESC
LIMIT 5;
-- The Weeknd - 756.432.486
-- Lady Gaga - 626.892.868
-- Billie Eilish - 555.209.448
-- Linkin Park - 498.349.706
-- Imagine Dragons - 202.120.883

-- PREGUNTA 6 - BIS 1 --
-- SINGLES PUBLICADOS LOS ÚLTIMOS 5 AÑOS: --
-- (Número de singles en los últimos 5 años) --
SELECT
s.Year AS Año,
COUNT(s.Title) AS NumCanciones
FROM Spotify AS s
GROUP BY Año
ORDER BY NumCanciones DESC;
-- Resultado:
-- 2020 - 30 singles.
-- 2021 - 23 singles.
-- 2024 - 20 singles.
-- 2022 - 19 singles.
-- 2023 - 14 singles.

-- PREGUNTA 6 - BIS 2 --
-- MEDIA DE SINGLES PUBLICADOS EN LOS ÚLTIMOS 5 AÑOS: --
-- (Promedio de singles en los últimos 5 años) --
SELECT
AVG(NumCanciones) AS PromedioCancionesAÑO
FROM (
    SELECT
	s.Year AS Año,
	COUNT(s.Title) AS NumCanciones
    FROM Spotify AS s
    GROUP BY Año
) AS NumCancionesAÑO;
-- Resultado:
-- 21,20 singles al año.

-- PREGUNTA 7 --
-- GÉNEROS MÁS ESCUCHADOS LOS ÚLTIMOS 5 AÑOS: --
-- (Número de reproducciones por género) --
SELECT
s.Genre AS 'Género',
MAX(l.Playcount)
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Genre
ORDER BY MAX(l.Playcount) DESC;
-- Resultado:
-- pop - 756.432.486
-- rock - 498.349.706
-- electronic - 79.660.860
-- flamenco - 6.879.229  

-- PREGUNTA 8 --
-- ARTISTA MÁS ESCUCHADO POR CADA GÉNERO Y POR CADA AÑO: --
SELECT
x.Artist AS 'Artista',
x.Playcount AS 'Reproducciones',
x.Genre AS 'Género',
x.Year AS 'Año'
FROM (
	SELECT
	s.Artist,
	l.Playcount,
	s.Genre,
	s.Year,
	ROW_NUMBER() OVER (PARTITION BY s.Genre, s.Year ORDER BY l.Playcount DESC) AS rn
	FROM Spotify AS s
	LEFT JOIN Last_fm AS l 
	ON s.Artist = l.Artist
	WHERE s.Genre IN ('pop', 'rock', 'flamenco', 'electronic')
		AND s.Year BETWEEN 2020 AND 2024
	ORDER BY l.Playcount DESC
    ) AS x
WHERE rn = 1;
POP:
2020 - "The Weeknd",756432486
2021 - "Manuel Turizo",7278637
2022 - Feid,38617480
2023 - Marshmello,52660757
2024 - "Lady Gaga",626892868
ROCK:
2020 - "Glass Animals",101612780
2021 - "Elton John",124904427
2022 - "Imagine Dragons",202120883
2023 - "Mikel Izal",98248
2024 - "Linkin Park",498349706
FLAMENCO:
2020 - DELLAFUENTE,3759365
2021 - Cano,406227
2022 - Estopa,6879229
2023 - "Omar Montes",1471948
2024 - "Demarco Flamenco",109746
ELECTRONIC:
2020 - "Dean Blunt",3495976
2021 - "DJ Snake",35316175
2022 - Izzamuzzic,3089877
2023 - "Fatboy Slim",41136316
2024 - Justice,79660860

-- PREGUNTA 9 --
-- ARTISTA MÁS ESCUCHADOS DE 'POP' EN 2024 --
-- (Los 3 artistas más reproducidos en 2024 del género 'pop') --
SELECT
s.Artist AS 'Artista',
MAX(l.Playcount) AS 'NumReprod',
s.Genre AS 'Género',
s.Year AS 'Año'
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Artist
HAVING s.Genre = 'pop' AND s.Year = 2024
ORDER BY MAX(l.Playcount) DESC
LIMIT 3;
-- Resultado:
-- Lady Gaga - 626.892.868 - pop - 2024
-- Billie Eilish - 555.209.448 - pop - 2024
-- Shakira - 132.378.851 - pop - 2024

-- PREGUNTA 10 --
-- ARTISTA MÁS ESCUCHADOS DE 'ROCK' EN 2024 --
-- (Los 3 artistas más reproducidos en 2024 del género 'rock') --
SELECT
s.Artist AS 'Artista',
MAX(l.Playcount) AS 'NumReprod',
s.Genre AS 'Género',
s.Year AS 'Año'
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Artist
HAVING s.Genre = 'rock' AND s.Year = 2024
ORDER BY MAX(l.Playcount) DESC
LIMIT 3;
-- Resultado:
-- Linkin Park - 498.349.706 - rock - 2024
-- Hozier - 188.375.723 - rock - 2024
-- Disturbed - 137.467.446 - rock - 2024

-- PREGUNTA 11 --
-- ARTISTA MÁS ESCUCHADOS DE 'FLAMENCO' EN 2024 --
-- (Los 3 artistas más reproducidos en 2024 del género 'flamenco') --
SELECT
s.Artist AS 'Artista',
MAX(l.Playcount) AS 'NumReprod',
s.Genre AS 'Género',
s.Year AS 'Año'
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Artist
HAVING s.Genre = 'flamenco' AND s.Year = 2024
ORDER BY MAX(l.Playcount) DESC
LIMIT 3;
-- Resultado:
-- Demarco Flamenco - 109.746 - flamenco - 2024

-- PREGUNTA 12 --
-- ARTISTA MÁS ESCUCHADOS DE 'ELECTRONIC' EN 2024 --
-- (Los 3 artistas más reproducidos en 2024 del género 'electronic') --
SELECT
s.Artist AS 'Artista',
MAX(l.Playcount) AS 'NumReprod',
s.Genre AS 'Género',
s.Year AS 'Año'
FROM Spotify AS s
LEFT JOIN Last_fm AS l
ON s.Artist = l.Artist
GROUP BY s.Artist
HAVING s.Genre = 'electronic' AND s.Year = 2024
ORDER BY MAX(l.Playcount) DESC
LIMIT 3;
-- Resultado:
-- Justice - 79.660.860 - electronic - 2024
-- MORTEN - 1.955.571 - electronic - 2024
-- Space Motion - 205.162 - electronic - 2024


----------
ROW_NUMBER() OVER (PARTITION BY año, genero ORDER BY escuchas DESC) AS fila
ROW_NUMBER() OVER (PARTITION BY Year, Genre ORDER BY Playcount DESC) AS fila
WHERE fila = 1
