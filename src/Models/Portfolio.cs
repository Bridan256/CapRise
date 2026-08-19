using System.Collections.Generic;

namespace CapRise.Models
{
    public class Portfolio
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public List<Investment> Investments { get; set; }

        public Portfolio()
        {
            Investments = new List<Investment>();
        }
    }
}