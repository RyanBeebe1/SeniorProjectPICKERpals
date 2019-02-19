using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PickerPAls.Models
{
	public class ItemContext : DbContext
	{
		public ItemContext(DbContextOptions<ItemContext> options)
			: base(options)
		{
		}

		public DbSet<Item> Items { get; set; }

	}
}
