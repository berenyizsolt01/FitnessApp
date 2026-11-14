using Microsoft.EntityFrameworkCore;
using FitnessHub.Api.Models;

namespace FitnessHub.Api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Exercise> Exercises { get; set; }
        public DbSet<Equipment> Equipment { get; set; }
        public DbSet<ExerciseEquipment> ExerciseEquipment { get; set; }
        public DbSet<UserEquipment> UserEquipment { get; set; }
        public DbSet<WorkoutPlan> WorkoutPlans { get; set; }
        public DbSet<WorkoutPlanDay> WorkoutPlanDays { get; set; }
        public DbSet<WorkoutPlanExercise> WorkoutPlanExercises { get; set; }
        public DbSet<WorkoutLog> WorkoutLogs { get; set; }
        public DbSet<WorkoutLogSet> WorkoutLogSets { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Kapcsolótáblák összetett primary key beállítása
            modelBuilder.Entity<ExerciseEquipment>()
                .HasKey(ee => new { ee.ExerciseId, ee.EquipmentId });

            modelBuilder.Entity<UserEquipment>()
                .HasKey(ue => new { ue.UserId, ue.EquipmentId });
        }
    }
}