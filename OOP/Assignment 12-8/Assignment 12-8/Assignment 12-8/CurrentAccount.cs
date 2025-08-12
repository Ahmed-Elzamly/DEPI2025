using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assignment_12_8
{
    public class CurrentAccount : BankAccount
    {
        public decimal OverdraftLimit { get; set; }
        public override decimal CalculateInterest()
        {
            return 0;
        }
        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Overdraft Limit: {OverdraftLimit:C}");
        }
    }
}
