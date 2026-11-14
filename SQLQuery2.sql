USE FitnessHubDB;
GO

-- 1. Eszközök szótárának feltöltése
INSERT INTO Equipment (NameEN, NameHU)
VALUES 
('Bodyweight', N'Saját testsúly'),
('Flat Bench', N'Egyenes pad'),
('Barbell', N'Rúd'),
('Dumbbell', N'Kézisúlyzó');

-- 2. Teszt felhasználó felvitele (Otthoni edzés, tömegelés)
INSERT INTO Users (Email, Height, Weight, BodyFat, Goal, FitnessLevel, WorkoutLocation, LanguagePref)
VALUES ('junior.dev@teszt.hu', 194, 68.0, 14.0, 'Bulking', 1, 'Home', 'hu');

-- 3. Mik vannak otthon a felhasználónak? (Egyenes pad, rúd, kézisúlyzók - 2, 3, 4-es ID)
INSERT INTO UserEquipment (UserId, EquipmentId)
VALUES 
(1, 2), -- Egyenes pad
(1, 3), -- Rúd
(1, 4); -- Kézisúlyzó

-- 4. Gyakorlatok feltöltése
INSERT INTO Exercises (NameEN, NameHU, DescriptionEN, DescriptionHU, TargetMuscle, DifficultyLevel, VideoUrl)
VALUES 
('Barbell Bench Press', N'Fekvenyomás rúddal', N'Lie on the bench and press the bar.', N'Feküdj a padra és nyomd ki a rudat.', 'Chest', 1, 'link_ide'),
('Push-up', N'Fekvőtámasz', N'Standard push-up.', N'Szabályos fekvőtámasz.', 'Chest', 1, 'link_ide'),
('Dumbbell Row', N'Döntött törzsű evezés', N'Row the dumbbell to your hip.', N'Húzd a súlyzót a csípődhöz.', 'Back', 1, 'link_ide');

-- 5. Melyik gyakorlathoz milyen eszközök kellenek?
-- Fekvenyomás (ExerciseId 1) -> Kell hozzá Pad (2) és Rúd (3)
INSERT INTO ExerciseEquipment (ExerciseId, EquipmentId) VALUES (1, 2), (1, 3);
-- Fekvőtámasz (ExerciseId 2) -> Kell hozzá Saját testsúly (1)
INSERT INTO ExerciseEquipment (ExerciseId, EquipmentId) VALUES (2, 1);
-- Evezés kézisúlyzóval (ExerciseId 3) -> Kell hozzá Kézisúlyzó (4) és Pad (2) a támaszkodáshoz
INSERT INTO ExerciseEquipment (ExerciseId, EquipmentId) VALUES (3, 4), (3, 2);