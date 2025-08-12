namespace Assignment_12_8
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var savingAcc = new SavingAccount
            {
                AccountNumber = "RK01",
                AccountHolder = "Ahmed Elzamly",
                Balance = 10000,
                InterestRate = 5
            };
            var currentAcc = new CurrentAccount
            {
                AccountNumber = "RK02",
                AccountHolder = "Omar Hassan",
                Balance = 5000,
                OverdraftLimit = 2000
            };

            List<BankAccount> accs = new List<BankAccount> { savingAcc, currentAcc };

            foreach (var acc in accs)
            {
                acc.ShowAccountDetails();
                Console.WriteLine($"Calculated Interest: {acc.CalculateInterest():C}");
                Console.WriteLine("-----------------------------------------");
            }
        }
    }
}
