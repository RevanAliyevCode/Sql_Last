CREATE DATABASE MoviesApp;


USE MoviesApp;


CREATE TABLE Directors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50),
    Surname NVARCHAR(50)
);

CREATE TABLE Languages (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50)
);

CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Description NVARCHAR(MAX),
    CoverPhoto NVARCHAR(MAX),
    DirectorId INT,
    LanguageId INT,
    FOREIGN KEY (DirectorId) REFERENCES Directors(Id),
    FOREIGN KEY (LanguageId) REFERENCES Languages(Id)
);


CREATE TABLE Actors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50),
    Surname NVARCHAR(50)
);


CREATE TABLE Genres (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50)
);




CREATE TABLE MoviesActors (
    MovieId INT,
    ActorId INT,
    PRIMARY KEY (MovieId, ActorId),
    FOREIGN KEY (MovieId) REFERENCES Movies(Id),
    FOREIGN KEY (ActorId) REFERENCES Actors(Id)
);


CREATE TABLE MoviesGenres (
    MovieId INT,
    GenreId INT,
    PRIMARY KEY (MovieId, GenreId),
    FOREIGN KEY (MovieId) REFERENCES Movies(Id),
    FOREIGN KEY (GenreId) REFERENCES Genres(Id)
);


INSERT INTO Directors (Name, Surname) VALUES ('Quentin', 'Tarantino');
INSERT INTO Directors (Name, Surname) VALUES ('Christopher', 'Nolan');
INSERT INTO Directors (Name, Surname) VALUES ('Steven', 'Spielberg');


INSERT INTO Languages (Name) VALUES ('English');
INSERT INTO Languages (Name) VALUES ('French');
INSERT INTO Languages (Name) VALUES ('Spanish');


INSERT INTO Movies (Name, Description, CoverPhoto, DirectorId, LanguageId) VALUES ('Inception', 'A mind-bending thriller', 'cover1.jpg', 2, 1);
INSERT INTO Movies (Name, Description, CoverPhoto, DirectorId, LanguageId) VALUES ('Pulp Fiction', 'Crime drama', 'cover2.jpg', 1, 1);
INSERT INTO Movies (Name, Description, CoverPhoto, DirectorId, LanguageId) VALUES ('Jaws', 'A horror movie about a shark', 'cover3.jpg', 3, 1);


INSERT INTO Actors (Name, Surname) VALUES ('Leonardo', 'DiCaprio');
INSERT INTO Actors (Name, Surname) VALUES ('Samuel', 'Jackson');
INSERT INTO Actors (Name, Surname) VALUES ('Tom', 'Hanks');


INSERT INTO Genres (Name) VALUES ('Thriller');
INSERT INTO Genres (Name) VALUES ('Crime');
INSERT INTO Genres (Name) VALUES ('Horror');


INSERT INTO MoviesActors (MovieId, ActorId) VALUES (1, 1); -- Leonardo DiCaprio in Inception
INSERT INTO MoviesActors (MovieId, ActorId) VALUES (2, 2); -- Samuel Jackson in Pulp Fiction
INSERT INTO MoviesActors (MovieId, ActorId) VALUES (3, 3); -- Tom Hanks in Jaws


INSERT INTO MoviesGenres (MovieId, GenreId) VALUES (1, 1); -- Inception as Thriller
INSERT INTO MoviesGenres (MovieId, GenreId) VALUES (2, 2); -- Pulp Fiction as Crime
INSERT INTO MoviesGenres (MovieId, GenreId) VALUES (3, 3); -- Jaws as Horror


CREATE PROCEDURE GetMoviesByDirector
    @directorId INT
AS
BEGIN
    SELECT 
        M.Name AS MovieName,
        L.Name AS LanguageName
    FROM 
        Movies M
    JOIN 
        Languages L ON M.LanguageId = L.Id
    WHERE 
        M.DirectorId = @directorId;
END;

EXEC GetMoviesByDirector @directorId = 3;


CREATE FUNCTION GetMovieCountByLanguage
    (@languageId INT)
RETURNS INT
AS
BEGIN
    DECLARE @movieCount INT;
    SELECT @movieCount = COUNT(*) FROM Movies WHERE LanguageId = @languageId;
    RETURN @movieCount;
END;

SELECT dbo.GetMovieCountByLanguage(1) as MovieCount;


CREATE PROCEDURE GetMoviesByGenre
    @genreId INT
AS
BEGIN
    SELECT 
        M.Name AS MovieName,
        D.Name AS DirectorName,
        D.Surname AS DirectorSurname
    FROM 
        Movies M
    JOIN 
        MoviesGenres MG ON M.Id = MG.MovieId
    JOIN 
        Directors D ON M.DirectorId = D.Id
    WHERE 
        MG.GenreId = @genreId;
END;

EXEC GetMoviesByGenre @genreId = 2;


CREATE FUNCTION HasActorParticipatedInMoreThanThreeMovies
    (@actorId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @movieCount INT;
    SELECT @movieCount = COUNT(*) FROM MoviesActors WHERE ActorId = @actorId;
    
    RETURN CASE 
               WHEN @movieCount > 3 THEN 1
               ELSE 0
           END;
END;

SELECT dbo.HasActorParticipatedInMoreThanThreeMovies(1) AS MovieCount;


CREATE TRIGGER ShowAllMoviesAfterInsert
ON Movies
AFTER INSERT
AS
BEGIN
    SELECT 
        M.Name AS MovieName,
        D.Name AS DirectorName,
        D.Surname AS DirectorSurname,
        L.Name AS LanguageName
    FROM 
        Movies M
    JOIN 
        Directors D ON M.DirectorId = D.Id
    JOIN 
        Languages L ON M.LanguageId = L.Id;
END;

