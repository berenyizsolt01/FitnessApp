using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FitnessHub.Api.Data;
using FitnessHub.Api.Models;
using FitnessHub.Api.Helpers;

namespace FitnessHub.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WorkoutLogsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public WorkoutLogsController(AppDbContext context)
        {
            _context = context;
        }

        // POST: api/workoutlogs (Befejezett edzés elmentése)
        [HttpPost]
        public async Task<IActionResult> SaveWorkoutLog([FromBody] SaveWorkoutLogDto dto)
        {
            var log = new WorkoutLog
            {
                UserId = dto.UserId,
                WorkoutPlanDayId = dto.WorkoutPlanDayId,
                StartTime = dto.StartTime,
                EndTime = dto.EndTime ?? DateTime.Now,
                Notes = dto.Notes
            };

            _context.WorkoutLogs.Add(log);
            await _context.SaveChangesAsync();

            foreach (var setDto in dto.Sets)
            {
                _context.WorkoutLogSets.Add(new WorkoutLogSet
                {
                    WorkoutLogId = log.Id,
                    ExerciseId = setDto.ExerciseId,
                    SetNumber = setDto.SetNumber,
                    WeightKg = setDto.WeightKg,
                    RepsCompleted = setDto.RepsCompleted
                });
            }

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Edzés sikeresen elmentve!", LogId = log.Id });
        }

        // GET: api/workoutlogs/user/1 (Felhasználó edzéselőzményei)
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserLogs(int userId)
        {
            var rawLogs = await _context.WorkoutLogs
                .Where(l => l.UserId == userId)
                .OrderByDescending(l => l.StartTime)
                .Join(_context.WorkoutPlanDays,
                    l => l.WorkoutPlanDayId,
                    d => d.Id,
                    (l, d) => new { Log = l, Day = d })
                .Join(_context.WorkoutPlans,
                    ld => ld.Day.WorkoutPlanId,
                    p => p.Id,
                    (ld, p) => new { ld.Log, ld.Day, Plan = p })
                .ToListAsync();

            var logIds = rawLogs.Select(x => x.Log.Id).ToList();

            var allSets = await _context.WorkoutLogSets
                .Where(s => logIds.Contains(s.WorkoutLogId))
                .Join(_context.Exercises,
                    s => s.ExerciseId,
                    e => e.Id,
                    (s, e) => new
                    {
                        s.Id,
                        s.WorkoutLogId,
                        s.ExerciseId,
                        ExerciseName = e.NameHU,
                        TargetMuscle = e.TargetMuscle,
                        s.SetNumber,
                        s.WeightKg,
                        s.RepsCompleted
                    })
                .OrderBy(s => s.Id)
                .ToListAsync();

            var result = rawLogs.Select(x =>
            {
                var logSets = allSets.Where(s => s.WorkoutLogId == x.Log.Id).ToList();
                var totalVolume = logSets.Sum(s => s.WeightKg * s.RepsCompleted);
                var durationMinutes = x.Log.EndTime.HasValue
                    ? (int)Math.Max(1, Math.Round((x.Log.EndTime.Value - x.Log.StartTime).TotalMinutes))
                    : 0;

                return new
                {
                    x.Log.Id,
                    x.Log.StartTime,
                    x.Log.EndTime,
                    DurationMinutes = durationMinutes,
                    PlanName = x.Plan.Name,
                    DayName = x.Day.DayName,
                    TotalVolume = totalVolume,
                    TotalSets = logSets.Count,
                    Sets = logSets
                };
            });

            return Ok(result);
        }

        // GET: api/workoutlogs/user/1/muscle-recovery (Izom-regenerációs algoritmus)
        [HttpGet("user/{userId}/muscle-recovery")]
        public async Task<IActionResult> GetMuscleRecovery(int userId)
        {
            var rawLogs = await _context.WorkoutLogs
                .Where(l => l.UserId == userId && l.StartTime >= DateTime.Now.AddDays(-7))
                .ToListAsync();

            var logIds = rawLogs.Select(x => x.Id).ToList();

            var sets = await _context.WorkoutLogSets
                .Where(s => logIds.Contains(s.WorkoutLogId))
                .Join(_context.Exercises, s => s.ExerciseId, e => e.Id, (s, e) => new { s.WorkoutLogId, e.TargetMuscle })
                .ToListAsync();

            var recoveryMap = new Dictionary<string, double>();
            string[] allMuscles = { "Mell", "Hát", "Váll", "Bicepsz", "Tricepsz", "Láb", "Has" };

            foreach (var m in allMuscles) recoveryMap[m] = 100.0; // Alapból minden 100% kipihent

            foreach (var log in rawLogs)
            {
                var musclesInLog = sets
                    .Where(s => s.WorkoutLogId == log.Id)
                    .Select(s => MuscleNames.ToHungarian(s.TargetMuscle))
                    .Where(m => m != null)
                    .Select(m => m!)
                    .Distinct();
                var hoursPassed = (DateTime.Now - log.StartTime).TotalHours;

                // 48 óra a teljes regeneráció (0 óra = 0%, 24 óra = 50%, 48+ óra = 100%)
                double currentRecovery = Math.Min(100.0, Math.Max(0.0, (hoursPassed / 48.0) * 100.0));

                foreach (var muscle in musclesInLog)
                {
                    // VÉDELEM: Csak akkor vizsgáljuk, ha szerepel a magyar listánkban
                    if (recoveryMap.ContainsKey(muscle))
                    {
                        if (currentRecovery < recoveryMap[muscle])
                        {
                            recoveryMap[muscle] = currentRecovery;
                        }
                    }
                }
            }

            var result = recoveryMap.Select(kvp => new
            {
                Muscle = kvp.Key,
                RecoveryPercentage = (int)Math.Round(kvp.Value),
                Status = kvp.Value < 33 ? "Kimerült" : kvp.Value < 66 ? "Regenerálódik" : "Kipihent",
                ColorHex = kvp.Value < 33 ? "#F44336" : kvp.Value < 66 ? "#FFEB3B" : "#4CAF50"
            }).OrderBy(x => x.RecoveryPercentage).ToList();

            return Ok(result);
        }
    }

    public class SaveWorkoutLogDto
    {
        public int UserId { get; set; }
        public int WorkoutPlanDayId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string? Notes { get; set; }
        public List<SaveWorkoutSetDto> Sets { get; set; } = new();
    }

    public class SaveWorkoutSetDto
    {
        public int ExerciseId { get; set; }
        public int SetNumber { get; set; }
        public decimal WeightKg { get; set; }
        public int RepsCompleted { get; set; }
    }
}