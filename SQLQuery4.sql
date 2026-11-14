USE FitnessHubDB;
GO

-- 6. Edzéstervek tábla
CREATE TABLE WorkoutPlans (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Goal VARCHAR(50), -- pl. 'Bulking', 'Cutting'
    DifficultyLevel INT,
    CreatorUserId INT NULL FOREIGN KEY REFERENCES Users(Id), -- NULL, ha beépített/alap terv
    IsSystemPlan BIT DEFAULT 0 -- 1: a rendszer gyári terve, 0: a user saját terve
);

-- 7. Edzésnapok tábla (Egy tervhez több nap tartozik)
CREATE TABLE WorkoutDays (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PlanId INT FOREIGN KEY REFERENCES WorkoutPlans(Id),
    DayNumber INT, -- 1, 2, 3... (pl. 1. nap)
    Name NVARCHAR(100) -- pl. 'Felsőtest' vagy 'Push'
);

-- 8. Napi gyakorlatok (Melyik napon, milyen gyakorlat, hány sorozat)
CREATE TABLE WorkoutExercises (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DayId INT FOREIGN KEY REFERENCES WorkoutDays(Id),
    ExerciseId INT FOREIGN KEY REFERENCES Exercises(Id),
    SetCount INT,
    RepCount VARCHAR(50), -- pl. '8-12' vagy 'bukásig'
    OrderIndex INT -- Hányadik gyakorlat az adott napon belül
);