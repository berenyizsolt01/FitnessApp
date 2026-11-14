-- Adatbázis létrehozása
CREATE DATABASE FitnessHubDB;
GO
USE FitnessHubDB;
GO

-- 1. Felhasználók tábla (Cél, Szint, Nyelv)
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(255) NOT NULL,
    Height INT, -- cm
    Weight DECIMAL(5,2), -- kg
    BodyFat DECIMAL(5,2), -- %
    Goal VARCHAR(50), -- 'Bulking', 'Cutting' stb.
    FitnessLevel INT, -- 1: Kezdő, 2: Középhaladó, 3: Profi
    WorkoutLocation VARCHAR(50), -- 'Home', 'Gym'
    LanguagePref VARCHAR(5) DEFAULT 'hu' -- 'en' vagy 'hu'
);

-- 2. Elérhető Eszközök tábla (Szótár)
CREATE TABLE Equipment (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    NameEN VARCHAR(100),
    NameHU NVARCHAR(100) -- NVARCHAR a magyar ékezetek miatt
);

-- 3. Felhasználó otthoni eszközei (Kapcsolótábla a Users és Equipment között)
CREATE TABLE UserEquipment (
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    EquipmentId INT FOREIGN KEY REFERENCES Equipment(Id),
    PRIMARY KEY (UserId, EquipmentId)
);

-- 4. Gyakorlatok tábla (Többnyelvű, szinthez kötött)
CREATE TABLE Exercises (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    NameEN VARCHAR(100),
    NameHU NVARCHAR(100),
    DescriptionEN NVARCHAR(MAX),
    DescriptionHU NVARCHAR(MAX),
    TargetMuscle VARCHAR(50), -- pl. 'Chest', 'Back'
    DifficultyLevel INT, -- 1-3, passzolnia kell a Users.FitnessLevel-hez
    VideoUrl VARCHAR(255)
);

-- 5. Gyakorlathoz szükséges eszközök (Kapcsolótábla az Exercises és Equipment között)
CREATE TABLE ExerciseEquipment (
    ExerciseId INT FOREIGN KEY REFERENCES Exercises(Id),
    EquipmentId INT FOREIGN KEY REFERENCES Equipment(Id),
    PRIMARY KEY (ExerciseId, EquipmentId)
);