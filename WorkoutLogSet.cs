namespace FitnessHub.Api.Models
{
    public class WorkoutLogSet
    {
        public int Id { get; set; }
        public int WorkoutLogId { get; set; }
        public int ExerciseId { get; set; }
        public int SetNumber { get; set; }
        public decimal WeightKg { get; set; }
        public int RepsCompleted { get; set; }
    }
}