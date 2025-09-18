
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace session4_Assignment
{
    class Bank
    {
        public string Name { get; set; }
        public string BranchCode { get; set; }
        public Bank(string name , string branchCode)
        {
            Name = name;
            BranchCode = branchCode;
        }
        public List<Customer> Customers = new List<Customer>();
        public void RemoveCustomer(string nationalID)
        {
            foreach (var customer in Customers) {
                if (customer.NationalID == nationalID)
                {
                    foreach (var Account in customer.Accounts)
                    {
                        if (Account.CurrentBalance != 0)
                        {
                            Console.WriteLine("Can't remove customer while account have balance");
                            return;
                        }
                    }
                    Customers.Remove(customer);
                    return;
                }
            }
        }
        public void SearchCustomersByName(string name)
        {
            foreach(var customer in Customers)
            {
                if(name == customer.FullName)
                {
                    customer.ShowCustomerInfo();
                    return;
                }
            }
        }
        public void SearchCustomersByNationalID(string nationalID)
        {
            foreach(var customer in Customers)
            {
                if(nationalID == customer.NationalID)
                {
                    customer.ShowCustomerInfo();
                    return;
                }
            }
        }
        public void TransferMoney(Customer fromc , BankAccount froma , Customer toc , BankAccount toa , decimal amount)
        {
            int indexOfFromc = Customers.IndexOf(fromc);
            int indexOfFroma = Customers[indexOfFromc].Accounts.IndexOf(froma);
            int indexOfToc = Customers.IndexOf(toc);
            int indexOfToa = Customers[indexOfToc].Accounts.IndexOf(toa);
            bool possible = Customers[indexOfFromc].Accounts[indexOfFroma].Withdraw(amount);
            if (!possible)
            {
                Console.WriteLine("The account w you try to transfer from doesn't have the needed amount");
                return;
            }

            Customers[indexOfToc].Accounts[indexOfToa].Deposit(amount);
        }
        public void ShowBankReport()
        {
            Console.WriteLine("===== Bank Report =====");
            Console.WriteLine($"Bank: {Name} - Branch: {BranchCode}");
            Console.WriteLine();

            foreach (var customer in Customers)
            {
                Console.WriteLine($"Customer ID: {customer.CustomerID}");
                Console.WriteLine($"Name       : {customer.FullName}");
                Console.WriteLine($"NationalID : {customer.NationalID}");
                Console.WriteLine($"DateOfBirth: {customer.DOB.ToShortDateString()}");
                Console.WriteLine("Accounts:");

                if (customer.Accounts.Count == 0)
                {
                    Console.WriteLine("   No accounts found.");
                }
                else
                {
                    foreach (var account in customer.Accounts)
                    {
                        Console.WriteLine($"   Account No: {account.AccountNumber}");
                        Console.WriteLine($"   Balance   : {account.CurrentBalance:C}");
                        Console.WriteLine($"   Opened On : {account.DateOpened}");
                        Console.WriteLine("------------------------------");
                    }
                }

                Console.WriteLine("=======================================");
            }
        }
    }
}
