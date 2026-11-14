using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FitnessHub.Api.Data;
using FitnessHub.Api.Models;

namespace FitnessHub.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WorkoutPlansController : ControllerBase
    {
        private readonly AppDbContext _context;

        public WorkoutPlansController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/workoutplans/user/1
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserPlans(int userId)
        {
            var plans = await _context.WorkoutPlans
                .Where(p => p.UserId == userId)
                .ToListAsync();

            return Ok(plans);
        }

        // GET: api/workoutplans/1/days
        [HttpGet("{planId}/days")]
        public async Task<IActionResult> GetPlanDays(int planId)
        {
            var days = await _context.WorkoutPlanDays
                .Where(d => d.WorkoutPlanId == planId)
                .OrderBy(d => d.DayNumber)
                .ToListAsync();

            return Ok(days);
        }

        // GET: api/workoutplans/days/1/exercises
        [HttpGet("days/{dayId}/exercises")]
        public async Task<IActionResult> GetDayExercises(int dayId)
        {
            var exercises = await _context.WorkoutPlanExercises
                .Where(wpe => wpe.WorkoutPlanDayId == dayId)
                .Join(_context.Exercises,
                    wpe => wpe.ExerciseId,
                    e => e.Id,
                    (wpe, e) => new
                    {
                        wpe.Id,
                        wpe.WorkoutPlanDayId,
                        wpe.ExerciseId,
                        ExerciseName = e.NameHU,
                        TargetMuscle = e.TargetMuscle,
                        wpe.Sets,
                        wpe.Reps
                    })
                .ToListAsync();

            return Ok(exercises);
        }

        // POST: api/workoutplans
        [HttpPost]
        public async Task<IActionResult> CreatePlan([FromBody] CreateWorkoutPlanDto dto)
        {
            var plan = new WorkoutPlan
            {
                UserId = dto.UserId,
                Name = dto.Name,
                Description = dto.Description
            };

            _context.WorkoutPlans.Add(plan);
            await _context.SaveChangesAsync();

            foreach (var dayDto in dto.Days)
            {
                var day = new WorkoutPlanDay
                {
                    WorkoutPlanId = plan.Id,
                    DayNumber = dayDto.DayNumber,
                    DayName = dayDto.DayName
                };

                _context.WorkoutPlanDays.Add(day);
                await _context.SaveChangesAsync();

                foreach (var exDto in dayDto.Exercises)
                {
                    _context.WorkoutPlanExercises.Add(new WorkoutPlanExercise
                    {
                        WorkoutPlanDayId = day.Id,
                        ExerciseId = exDto.ExerciseId,
                        Sets = exDto.Sets,
                        Reps = exDto.Reps
                    });
                }
            }

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Edzésterv sikeresen létrehozva!", PlanId = plan.Id });
        }
    }

    // DTO Osztályok a kérések fogadásához
    public class CreateWorkoutPlanDto
    {
        public int UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<CreatePlanDayDto> Days { get; set; } = new();
    }

    public class CreatePlanDayDto
    {
        public int DayNumber { get; set; }
        public string DayName { get; set; } = string.Empty;
        public List<CreateDayExerciseDto> Exercises { get; set; } = new();
    }

    public class CreateDayExerciseDto
    {
        public int ExerciseId { get; set; }
        public int Sets { get; set; }
        public int Reps { get; set; }
    }
}