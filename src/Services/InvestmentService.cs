using System;
using System.Collections.Generic;
using System.Linq;
using CapRise.Models;

namespace CapRise.Services
{
    public class InvestmentService
    {
        private List<Investment> investments;

        public InvestmentService()
        {
            investments = new List<Investment>();
        }

        public void AddInvestment(Investment investment)
        {
            investments.Add(investment);
        }

        public void RemoveInvestment(Guid investmentId)
        {
            var investment = investments.FirstOrDefault(i => i.Id == investmentId);
            if (investment != null)
            {
                investments.Remove(investment);
            }
        }

        public List<Investment> GetInvestments()
        {
            return investments;
        }

        public Investment GetInvestment(Guid investmentId)
        {
            return investments.FirstOrDefault(i => i.Id == investmentId);
        }
    }
}