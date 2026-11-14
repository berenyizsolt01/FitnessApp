namespace FitnessHub.Api.Models
{
    public class WorkoutPlanExercise
    {
        public int Id { get; set; }
        public int WorkoutPlanDayId { get; set; }
        public int ExerciseId { get; set; }
        public int Sets { get; set; }
        public int Reps { get; set; }
    }
}