using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace session4_Assignment
{
    public class Transaction
    {
        public string Type { get; set; }
        public decimal Amount { get; set; }
        public DateTime TransactionDateTime { get; set; }

        public Transaction(string type, decimal amount, DateTime transactionDateTime)
        {
            Type = type;
            Amount = amount;
            TransactionDateTime = transactionDateTime;
        }
    }
}
