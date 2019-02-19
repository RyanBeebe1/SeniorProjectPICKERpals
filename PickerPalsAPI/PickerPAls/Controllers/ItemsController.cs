using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PickerPAls.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace PickerPAls.Controllers
{
	[Route("api/items")]
	public class ItemsController : Controller
	{
		private readonly ItemContext _context;

		public ItemsController(ItemContext context)
		{
			_context = context;

			if (_context.Items.Count() == 0)
			{
				_context.Items.Add(new Item { name = "Ryan's Dignity", description = "get it while it's hot" });
				_context.SaveChanges();
			}
		}

		//GET: api/items
		[HttpGet]
		public async Task<ActionResult<IEnumerable<Item>>> GetItems()
		{
			return await _context.Items.ToListAsync();
		}

		// GET: api/items/7
		[HttpGet("{id}")]
		public async Task<ActionResult<Item>> GetItem(int id)
		{
			var item = await _context.Items.FindAsync(id);
			
			if (item == null)
			{
				return NotFound();
			}

			return item;
		}


		// GET: api/<controller>
		[HttpGet]
		public IEnumerable<string> Get()
		{
			return new string[] { "value1", "value2" };
		}

		// GET api/<controller>/5
		[HttpGet("{id}")]
		public string Get(int id)
		{
			return "value";
		}

		// POST api/<controller>
		[HttpPost]
		public void Post([FromBody]string value)
		{
		}

		// PUT api/<controller>/5
		[HttpPut("{id}")]
		public void Put(int id, [FromBody]string value)
		{
		}

		// DELETE api/<controller>/5
		[HttpDelete("{id}")]
		public void Delete(int id)
		{
		}
	}
}
