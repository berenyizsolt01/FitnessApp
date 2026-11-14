using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FitnessHub.Api.Data;
using FitnessHub.Api.Models;
using FitnessHub.Api.Helpers;

namespace FitnessHub.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EquipmentController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EquipmentController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/equipment
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Equipment>>> GetAllEquipment()
        {
            // A "Saját testsúly" automatikusan mindenkié, ezért nem listázzuk a kiválasztható eszközök között
            return Ok(await _context.Equipment
                .Where(e => e.NameEN != EquipmentNames.Bodyweight)
                .ToListAsync());
        }

        // GET: api/equipment/user/1
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<int>>> GetUserEquipmentIds(int userId)
        {
            var userEquipmentIds = await _context.UserEquipment
                .Where(ue => ue.UserId == userId)
                .Select(ue => ue.EquipmentId)
                .ToListAsync();

            return Ok(userEquipmentIds);
        }

        // POST: api/equipment/user/1
        [HttpPost("user/{userId}")]
        public async Task<IActionResult> UpdateUserEquipment(int userId, [FromBody] List<int> selectedEquipmentIds)
        {
            // 1. Töröljük a felhasználó jelenlegi eszközeit
            var existingUserEquipment = _context.UserEquipment.Where(ue => ue.UserId == userId);
            _context.UserEquipment.RemoveRange(existingUserEquipment);

            // 2. Beszúrjuk az újonnan kiválasztott eszközöket
            foreach (var eqId in selectedEquipmentIds)
            {
                _context.UserEquipment.Add(new UserEquipment
                {
                    UserId = userId,
                    EquipmentId = eqId
                });
            }

            await _context.SaveChangesAsync();
            return Ok();
        }
    }
}