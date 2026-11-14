namespace FitnessHub.Api.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public int? Height { get; set; }
        public decimal? Weight { get; set; }
        public decimal? BodyFat { get; set; }
        public string? Goal { get; set; }
        public int? FitnessLevel { get; set; }
        public string? WorkoutLocation { get; set; }
        public string LanguagePref { get; set; } = "hu";
    }
}