using System;
using System.Collections.Generic;
using System.Linq;

namespace session4_Assignment
{
    class Program
    {
        private static Bank bank;

        static void Main(string[] args)
        {
            Console.WriteLine("=== Welcome to Bank Management System ===");
            InitializeBank();

            while (true)
            {
                ShowMainMenu();
                var choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        AddNewCustomer();
                        break;
                    case "2":
                        UpdateCustomerDetails();
                        break;
                    case "3":
                        RemoveCustomer();
                        break;
                    case "4":
                        SearchCustomer();
                        break;
                    case "5":
                        AddAccountToCustomer();
                        break;
                    case "6":
                        DepositMoney();
                        break;
                    case "7":
                        WithdrawMoney();
                        break;
                    case "8":
                        TransferMoney();
                        break;
                    case "9":
                        ShowCustomerBalance();
                        break;
                    case "10":
                        CalculateMonthlyInterest();
                        break;
                    case "11":
                        ShowTransactionHistory();
                        break;
                    case "12":
                        ShowBankReport();
                        break;
                    case "0":
                        Console.WriteLine("Thank you for using Bank Management System!");
                        Environment.Exit(0);
                        break;
                    default:
                        Console.WriteLine("Invalid choice! Please try again.");
                        break;
                }

                Console.WriteLine("\nPress any key to continue...");
                Console.ReadKey();
            }
        }

        static void InitializeBank()
        {
            Console.Write("Enter Bank Name: ");
            string name = Console.ReadLine();
            Console.Write("Enter Branch Code: ");
            string branchCode = Console.ReadLine();

            bank = new Bank(name, branchCode);
            Console.WriteLine($"\nBank '{name}' with branch code '{branchCode}' has been created successfully!\n");
        }

        static void ShowMainMenu()
        {
            Console.Clear();
            Console.WriteLine($"=== {bank.Name} - Branch: {bank.BranchCode} ===");
            Console.WriteLine("1. Add New Customer");
            Console.WriteLine("2. Update Customer Details");
            Console.WriteLine("3. Remove Customer");
            Console.WriteLine("4. Search Customer");
            Console.WriteLine("5. Add Account to Customer");
            Console.WriteLine("6. Deposit Money");
            Console.WriteLine("7. Withdraw Money");
            Console.WriteLine("8. Transfer Money");
            Console.WriteLine("9. Show Customer Total Balance");
            Console.WriteLine("10. Calculate Monthly Interest (Savings)");
            Console.WriteLine("11. Show Transaction History");
            Console.WriteLine("12. Show Bank Report");
            Console.WriteLine("0. Exit");
            Console.Write("Enter your choice: ");
        }

        static void AddNewCustomer()
        {
            Console.Clear();
            Console.WriteLine("=== Add New Customer ===");

            Console.Write("Enter Full Name: ");
            string fullName = Console.ReadLine();

            Console.Write("Enter National ID: ");
            string nationalId = Console.ReadLine();
            if(bank.Customers.Find(c => c.NationalID == nationalId) != null)
            {
                Console.WriteLine("This national ID is used for another customer !! \n Can't Add Customer");
                return;
            }

            Console.Write("Enter Date of Birth (yyyy-mm-dd): ");
            if (DateOnly.TryParse(Console.ReadLine(), out DateOnly dob))
            {
                var customer = new Customer(fullName, nationalId, dob);
                bank.Customers.Add(customer);
                Console.WriteLine($"Customer added successfully with ID: {customer.CustomerID}");
            }
            else
            {
                Console.WriteLine("Invalid date format!");
            }
        }

        static void UpdateCustomerDetails()
        {
            Console.Clear();
            Console.WriteLine("=== Update Customer Details ===");

            var customer = FindCustomer();
            if (customer == null) return;

            Console.Write($"Current Name: {customer.FullName}. Enter new name (or press Enter to keep current): ");
            string newName = Console.ReadLine();
            if (string.IsNullOrWhiteSpace(newName))
                newName = customer.FullName;

            Console.Write($"Current DOB: {customer.DOB}. Enter new DOB (yyyy-mm-dd) or press Enter to keep current: ");
            string dobInput = Console.ReadLine();
            DateOnly newDob = customer.DOB;

            if (!string.IsNullOrWhiteSpace(dobInput))
            {
                if (!DateOnly.TryParse(dobInput, out newDob))
                {
                    Console.WriteLine("Invalid date format! Keeping current DOB.");
                    newDob = customer.DOB;
                }
            }

            customer.UpdateCustomerDetails(newName, newDob);
            Console.WriteLine("Customer details updated successfully!");
        }

        static void RemoveCustomer()
        {
            Console.Clear();
            Console.WriteLine("=== Remove Customer ===");

            Console.Write("Enter National ID of customer to remove: ");
            string nationalId = Console.ReadLine();

            bank.RemoveCustomer(nationalId);
        }

        static void SearchCustomer()
        {
            Console.Clear();
            Console.WriteLine("=== Search Customer ===");
            Console.WriteLine("1. Search by Name");
            Console.WriteLine("2. Search by National ID");
            Console.Write("Enter choice: ");

            var choice = Console.ReadLine();
            switch (choice)
            {
                case "1":
                    Console.Write("Enter customer name: ");
                    string name = Console.ReadLine();
                    bank.SearchCustomersByName(name);
                    break;
                case "2":
                    Console.Write("Enter National ID: ");
                    string nationalId = Console.ReadLine();
                    bank.SearchCustomersByNationalID(nationalId);
                    break;
                default:
                    Console.WriteLine("Invalid choice!");
                    break;
            }
        }

        static void AddAccountToCustomer()
        {
            Console.Clear();
            Console.WriteLine("=== Add Account to Customer ===");

            var customer = FindCustomer();
            if (customer == null) return;

            Console.WriteLine("Select Account Type:");
            Console.WriteLine("1. Savings Account");
            Console.WriteLine("2. Current Account");
            Console.Write("Enter choice: ");

            var accountType = Console.ReadLine();
            Console.Write("Enter initial balance: ");

            if (decimal.TryParse(Console.ReadLine(), out decimal balance))
            {
                BankAccount account = null;

                switch (accountType)
                {
                    case "1":
                        Console.Write("Enter interest rate (%): ");
                        if (decimal.TryParse(Console.ReadLine(), out decimal interestRate))
                        {
                            account = new SavingAccount(balance, interestRate);
                        }
                        break;
                    case "2":
                        Console.Write("Enter overdraft limit: ");
                        if (decimal.TryParse(Console.ReadLine(), out decimal overdraftLimit))
                        {
                            account = new CurrentAccount(balance, overdraftLimit);
                        }
                        break;
                    default:
                        Console.WriteLine("Invalid account type!");
                        return;
                }

                if (account != null)
                {
                    customer.Accounts.Add(account);
                    Console.WriteLine($"Account created successfully!");
                }
            }
            else
            {
                Console.WriteLine("Invalid balance amount!");
            }
        }

        static void DepositMoney()
        {
            Console.Clear();
            Console.WriteLine("=== Deposit Money ===");

            var account = FindAccount();
            if (account == null) return;

            Console.Write("Enter amount to deposit: ");
            if (decimal.TryParse(Console.ReadLine(), out decimal amount) && amount > 0)
            {
                account.Deposit(amount);
                Console.WriteLine($"Successfully deposited {amount:C}. New balance: {account.CurrentBalance:C}");
            }
            else
            {
                Console.WriteLine("Invalid amount!");
            }
        }

        static void WithdrawMoney()
        {
            Console.Clear();
            Console.WriteLine("=== Withdraw Money ===");

            var account = FindAccount();
            if (account == null) return;

            Console.Write("Enter amount to withdraw: ");
            if (decimal.TryParse(Console.ReadLine(), out decimal amount) && amount > 0)
            {
                if (account.Withdraw(amount))
                {
                    Console.WriteLine($"Successfully withdrew {amount:C}. New balance: {account.CurrentBalance:C}");
                }
                else
                {
                    Console.WriteLine("Insufficient balance!");
                }
            }
            else
            {
                Console.WriteLine("Invalid amount!");
            }
        }

        static void TransferMoney()
        {
            Console.Clear();
            Console.WriteLine("=== Transfer Money ===");

            Console.WriteLine("--- FROM Account ---");
            var fromCustomer = FindCustomer();
            if (fromCustomer == null) return;

            var fromAccount = SelectAccountFromCustomer(fromCustomer);
            if (fromAccount == null) return;

            Console.WriteLine("\n--- TO Account ---");
            var toCustomer = FindCustomer();
            if (toCustomer == null) return;

            var toAccount = SelectAccountFromCustomer(toCustomer);
            if (toAccount == null) return;

            Console.Write("Enter amount to transfer: ");
            if (decimal.TryParse(Console.ReadLine(), out decimal amount) && amount > 0)
            {
                bank.TransferMoney(fromCustomer, fromAccount, toCustomer, toAccount, amount);
                Console.WriteLine("Transfer completed successfully!");
            }
            else
            {
                Console.WriteLine("Invalid amount!");
            }
        }

        static void ShowCustomerBalance()
        {
            Console.Clear();
            Console.WriteLine("=== Customer Total Balance ===");

            var customer = FindCustomer();
            if (customer == null) return;

            customer.ShowTotalBalance();
        }

        static void CalculateMonthlyInterest()
        {
            Console.Clear();
            Console.WriteLine("=== Calculate Monthly Interest ===");

            var customer = FindCustomer();
            if (customer == null) return;

            var savingsAccounts = customer.Accounts.OfType<SavingAccount>().ToList();

            if (savingsAccounts.Count == 0)
            {
                Console.WriteLine("Customer has no savings accounts!");
                return;
            }

            Console.WriteLine("Savings Accounts:");
            for (int i = 0; i < savingsAccounts.Count; i++)
            {
                Console.WriteLine($"{i + 1}. Account {savingsAccounts[i].AccountNumber} - Balance: {savingsAccounts[i].CurrentBalance:C}");
            }

            Console.Write("Select account (enter number): ");
            if (int.TryParse(Console.ReadLine(), out int choice) && choice > 0 && choice <= savingsAccounts.Count)
            {
                savingsAccounts[choice - 1].MonthlyInterestCalc();
            }
            else
            {
                Console.WriteLine("Invalid selection!");
            }
        }

        static void ShowTransactionHistory()
        {
            Console.Clear();
            Console.WriteLine("=== Transaction History ===");

            var account = FindAccount();
            if (account == null) return;

            account.ShowTransactionHistory();
        }

        static void ShowBankReport()
        {
            Console.Clear();
            bank.ShowBankReport();
        }

        // Helper Methods
        static Customer FindCustomer()
        {
            Console.Write("Enter Customer National ID: ");
            string nationalId = Console.ReadLine();

            var customer = bank.Customers.FirstOrDefault(c => c.NationalID == nationalId);
            if (customer == null)
            {
                Console.WriteLine("Customer not found!");
            }
            return customer;
        }

        static BankAccount FindAccount()
        {
            var customer = FindCustomer();
            if (customer == null) return null;

            return SelectAccountFromCustomer(customer);
        }

        static BankAccount SelectAccountFromCustomer(Customer customer)
        {
            if (customer.Accounts.Count == 0)
            {
                Console.WriteLine("Customer has no accounts!");
                return null;
            }

            Console.WriteLine("Customer Accounts:");
            for (int i = 0; i < customer.Accounts.Count; i++)
            {
                var acc = customer.Accounts[i];
                string accountType = acc is SavingAccount ? "Savings" : "Current";
                Console.WriteLine($"{i + 1}. Account {acc.AccountNumber} ({accountType}) - Balance: {acc.CurrentBalance:C}");
            }

            Console.Write("Select account (enter number): ");
            if (int.TryParse(Console.ReadLine(), out int choice) && choice > 0 && choice <= customer.Accounts.Count)
            {
                return customer.Accounts[choice - 1];
            }

            Console.WriteLine("Invalid selection!");
            return null;
        }
    }
}