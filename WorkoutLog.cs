namespace FitnessHub.Api.Models
{
    public class WorkoutLog
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int WorkoutPlanDayId { get; set; }
        public DateTime StartTime { get; set; } = DateTime.Now;
        public DateTime? EndTime { get; set; }
        public string? Notes { get; set; }
    }
}