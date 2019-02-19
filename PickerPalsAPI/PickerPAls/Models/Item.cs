using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PickerPAls.Models
{
	public class Item : IItem
	{
		public int id { get; set; }
		public string name { get; set; }
		public string description { get; set; }
	}
}
