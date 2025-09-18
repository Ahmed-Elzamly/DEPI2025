using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace session4_Assignment
{
    public class SavingAccount : BankAccount
    {
        public decimal InterestRate { get; set; }
        public SavingAccount(decimal amount , decimal interestRate) : base(amount)
        {
            InterestRate = interestRate;
        }
        public void MonthlyInterestCalc()
        {
            decimal mic = CurrentBalance * InterestRate / 100;
            Console.WriteLine($"Your monthly interest is {mic}");
        }
    }
}
