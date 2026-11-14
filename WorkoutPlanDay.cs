namespace FitnessHub.Api.Models
{
    public class WorkoutPlanDay
    {
        public int Id { get; set; }
        public int WorkoutPlanId { get; set; }
        public int DayNumber { get; set; }
        public string DayName { get; set; } = string.Empty;
    }
}