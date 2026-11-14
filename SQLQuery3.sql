DECLARE @AktualisFelhasznalo INT = 1; -- Később a C# backend dinamikusan adja át ezt az ID-t

SELECT 
    ex.NameHU AS [Gyakorlat Neve],
    ex.TargetMuscle AS [Célizom],
    ex.DifficultyLevel AS [Szint]
FROM Exercises ex
WHERE NOT EXISTS (
    -- 1. Keresünk olyan eszközt, ami SZÜKSÉGES ehhez a gyakorlathoz...
    SELECT EquipmentId 
    FROM ExerciseEquipment ee 
    WHERE ee.ExerciseId = ex.Id
    
    -- 2. ...de NINCS BENNE a felhasználó saját, otthoni eszközei között.
    AND ee.EquipmentId NOT IN (
        SELECT EquipmentId 
        FROM UserEquipment ue 
        WHERE ue.UserId = @AktualisFelhasznalo
    )
);