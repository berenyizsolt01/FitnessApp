namespace FitnessHub.Api.Helpers
{
    /// <summary>
    /// Az adatbázisban lévő izomnevek (angol vagy magyar) egységesítése magyarra.
    /// Így az izom-regenerációs térkép akkor is működik, ha a Exercises.TargetMuscle angol értékeket tartalmaz.
    /// </summary>
    public static class MuscleNames
    {
        private static readonly Dictionary<string, string> Map = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Chest"] = "Mell",
            ["Mell"] = "Mell",
            ["Back"] = "Hát",
            ["Lats"] = "Hát",
            ["Hát"] = "Hát",
            ["Shoulders"] = "Váll",
            ["Shoulder"] = "Váll",
            ["Váll"] = "Váll",
            ["Biceps"] = "Bicepsz",
            ["Bicepsz"] = "Bicepsz",
            ["Triceps"] = "Tricepsz",
            ["Tricepsz"] = "Tricepsz",
            ["Legs"] = "Láb",
            ["Quads"] = "Láb",
            ["Hamstrings"] = "Láb",
            ["Glutes"] = "Láb",
            ["Calves"] = "Láb",
            ["Láb"] = "Láb",
            ["Abs"] = "Has",
            ["Core"] = "Has",
            ["Has"] = "Has",
        };

        public static string? ToHungarian(string? muscle)
        {
            if (string.IsNullOrWhiteSpace(muscle)) return null;
            return Map.TryGetValue(muscle.Trim(), out var hu) ? hu : null;
        }
    }
}