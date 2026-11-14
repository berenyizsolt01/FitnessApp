USE FitnessHubDB;
GO

-- Létrehozunk egy gyári (rendszer) tömegelő tervet
INSERT INTO WorkoutPlans (Name, Goal, DifficultyLevel, IsSystemPlan)
VALUES (N'Alap 4 napos otthoni tömegelő', 'Bulking', 1, 1);

-- Hozzáadjuk a tervhez az 1. napot (Felsőtest)
-- (Az imént létrehozott terv ID-ja 1 lett)
INSERT INTO WorkoutDays (PlanId, DayNumber, Name)
VALUES (1, 1, N'Felsőtest fókusz');

-- Beletesszük a gyakorlatokat az 1. napba (DayId = 1)
-- ExerciseId 1 = Fekvenyomás rúddal, ExerciseId 3 = Döntött törzsű evezés
INSERT INTO WorkoutExercises (DayId, ExerciseId, SetCount, RepCount, OrderIndex)
VALUES 
(1, 1, 4, '8-10', 1), -- Fekvenyomás, 4 sorozat, 8-10 ismétlés, 1. feladat
(1, 3, 4, '10-12', 2); -- Evezés, 4 sorozat, 10-12 ismétlés, 2. feladat