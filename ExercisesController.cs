using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FitnessHub.Api.Data;
using FitnessHub.Api.Models;
using FitnessHub.Api.Helpers;

namespace FitnessHub.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ExercisesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ExercisesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/exercises/available/1  <-- Az 1-es a felhasználó ID-ja
        [HttpGet("available/{userId}")]
        public async Task<ActionResult<IEnumerable<Exercise>>> GetAvailableExercises(int userId)
        {
            // 1. Lekérjük, milyen eszközei vannak otthon a felhasználónak
            var userEquipmentIds = await _context.UserEquipment
                .Where(ue => ue.UserId == userId)
                .Select(ue => ue.EquipmentId)
                .ToListAsync();

            // A "Saját testsúly" mindenkinek mindig elérhető, nem kell külön kiválasztani
            var bodyweightIds = await _context.Equipment
                .Where(e => e.NameEN == EquipmentNames.Bodyweight)
                .Select(e => e.Id)
                .ToListAsync();
            userEquipmentIds = userEquipmentIds.Union(bodyweightIds).ToList();

            // 2. A MÁGIA: Kiszűrjük azokat a gyakorlatokat, amikhez a usernek megvan MINDEN eszköze,
            // VAGY egyáltalán nem igényelnek semmilyen eszközt (saját testsúlyos gyakorlatok)
            var availableExercises = await _context.Exercises
                .Where(ex =>
                    // Feltétel 1: Nincs hozzárendelt eszköz (saját testsúlyos)
                    !_context.ExerciseEquipment.Any(ee => ee.ExerciseId == ex.Id)
                    ||
                    // Feltétel 2: A gyakorlat összes szükséges eszköze benne van a user listájában
                    !_context.ExerciseEquipment
                        .Where(ee => ee.ExerciseId == ex.Id)
                        .Any(ee => !userEquipmentIds.Contains(ee.EquipmentId))
                )
                .ToListAsync();

            return Ok(availableExercises);
        }
    }
}