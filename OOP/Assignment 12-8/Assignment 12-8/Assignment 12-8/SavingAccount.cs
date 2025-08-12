using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assignment_12_8
{
    public class SavingAccount : BankAccount
    {
        public decimal InterestRate { get; set; }
        public override decimal CalculateInterest()
        {
            return Balance * InterestRate / 100;
        }
        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Interest Rate: {InterestRate}%");
        }
    }
}
