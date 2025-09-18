using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace session4_Assignment
{
   public class BankAccount
    {
        public static int accountID = 1 ;
        public int AccountNumber { get; set; }
        public DateOnly DateOpened { get; set; }
        public decimal CurrentBalance { get; set; }

        public List<Transaction> Transactions = new List<Transaction>();

        public BankAccount(decimal balance)
        {
            AccountNumber = accountID;
            accountID++;
            DateOpened = DateOnly.FromDateTime(DateTime.Now);
            CurrentBalance = balance;
        }
       public void Deposit(decimal amount)
        {
            CurrentBalance += amount;
            Transactions.Add(new Transaction("Deposit", amount, DateTime.Now));
        }
        public bool Withdraw(decimal amount)
        {
            if (CurrentBalance < amount) return false;
            CurrentBalance -= amount;
            Transactions.Add(new Transaction("Withdraw", amount, DateTime.Now));
            return true;
        }
        public void ShowTransactionHistory()
        {
            Console.WriteLine($"Transaction History for Account {AccountNumber}");
            Console.WriteLine("----------------------------------------");

            if (Transactions.Count == 0)
            {
                Console.WriteLine("No transactions found.");
            }
            else
            {
                foreach (var t in Transactions)
                {
                    Console.WriteLine($"{t.TransactionDateTime} | {t.Type} | Amount: {t.Amount:C}");
                }
            }

            Console.WriteLine("----------------------------------------");
        }
    }
}
