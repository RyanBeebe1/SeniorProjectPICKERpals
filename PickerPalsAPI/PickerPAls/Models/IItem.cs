using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PickerPAls.Models
{
	public interface IItem
	{
		int id { get; set; }
		string name { get; set; }
		string description { get; set; }

	}
}
