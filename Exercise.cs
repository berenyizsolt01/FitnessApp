namespace FitnessHub.Api.Models
{
    public class Exercise
    {
        public int Id { get; set; }
        public string? NameEN { get; set; }
        public string? NameHU { get; set; }
        public string? DescriptionEN { get; set; }
        public string? DescriptionHU { get; set; }
        public string? TargetMuscle { get; set; }
        public int? DifficultyLevel { get; set; }
        public string? VideoUrl { get; set; }
    }
}