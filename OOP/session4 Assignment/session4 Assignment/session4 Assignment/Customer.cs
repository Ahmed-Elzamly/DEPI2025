using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
namespace session4_Assignment
{
    public class Customer
    {
        static int customerID = 1;
        public int CustomerID { get; set; }
        public string FullName { get; set; }
        public string NationalID { get; set; }
        public DateOnly DOB { get; set; }

        public List<BankAccount> Accounts = new List<BankAccount>();
        public Customer(string fullName , string nationalID , DateOnly dob)
        {
            CustomerID = customerID;
            customerID++;
            FullName = fullName;
            NationalID = nationalID;
            DOB = dob;
        }
        public void UpdateCustomerDetails(string fullName , DateOnly dob)
        {
            FullName = fullName;
            DOB = dob;
        }
        public void ShowCustomerInfo()
        {
            Console.WriteLine($"Customer ID = {CustomerID}\n Customer Name = {FullName} \n Customer National ID = {NationalID} \n Customer Date Of Birth = {DOB} \n Customer Accounts Count = {Accounts.Count}\n");
        }
        public void ShowTotalBalance()
        {
            decimal totBalance = 0;
            foreach(var i in Accounts)
            {
                totBalance += i.CurrentBalance;
            }
            Console.WriteLine($"Your total balance is {totBalance}");
        }
    }
}
