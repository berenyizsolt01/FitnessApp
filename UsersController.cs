using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FitnessHub.Api.Data;
using FitnessHub.Api.Models;

namespace FitnessHub.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        // A konstruktorban megkapjuk az adatbázis kapcsolatot
        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetUsers()
        {
            // Lekérdezzük az összes felhasználót a Users táblából
            var users = await _context.Users.ToListAsync();
            return Ok(users);
        }
    }
}