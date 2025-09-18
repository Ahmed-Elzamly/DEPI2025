using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace session4_Assignment
{
    class CurrentAccount : BankAccount
    {
        public decimal OverdraftLimit { get; set; }
        public CurrentAccount(decimal amount , decimal overdraftLimit) : base(amount)
        {
            OverdraftLimit = overdraftLimit;
        }
    }
}
