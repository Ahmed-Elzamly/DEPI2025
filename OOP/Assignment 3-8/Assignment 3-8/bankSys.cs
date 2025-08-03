using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assignment_3_8
{
    internal class bankSys
    {
        public const string bankCode = "BNK001";
        public readonly DateTime createdDate;
        private int accountNumber;
        private string fullName;
        private string nationalID;
        private string phoneNumber;
        private decimal balance;
        public string FullName
        {
            get { return fullName; }
            set
            {
                    if (string.IsNullOrWhiteSpace(value)) 
                    Console.WriteLine("Nulls and empty values rejected");
                    else fullName = value;
            }
        }
        public string NationalID
        {
            get { return nationalID; }
            set
            {
                    if (value.Length != 14) 
                    Console.WriteLine("ID must contain 14 digits exactly");
                    else nationalID = value;
            }
        }
        public string PhoneNumber
        {
            get { return phoneNumber; }
            set
            {
                    if (value.Length != 11 || !value.StartsWith("01")) 
                    Console.WriteLine("phone number must contain 11 digits exactly and start with 01");
                    else phoneNumber = value;
            }
        }
        public decimal Balance
        {
            get { return balance; }
            set
            {
                    if (value < 0) 
                    Console.WriteLine("Balance must be greater than or equal to 0");
                    else balance = value;
            }
        }
        public string Address { get; set; }
        public bankSys()
        {
            FullName = "Ahmed";
            NationalID = "30405101702019";
            PhoneNumber = "01557788150";
            Address = "Quesna";
            Balance = 15000;
            createdDate = DateTime.Now;
        }
        public bankSys(string fullName, string nationalID, string phoneNumber, string address, decimal balance)
        {
            FullName = fullName;
            NationalID = nationalID;
            PhoneNumber = phoneNumber;
            Address = address;
            Balance = balance;
            createdDate = DateTime.Now;
        }
        public bankSys(string fullName, string nationalID, string phoneNumber, string address)
        {
            FullName = fullName;
            NationalID = nationalID;
            PhoneNumber = phoneNumber;
            Address = address;
            Balance = 0;
            createdDate = DateTime.Now;
        }
        public void showAccountDetails()
        {
            Console.WriteLine("=== Account Details ===");
            Console.WriteLine($"Full Name: {FullName}");
            Console.WriteLine($"National ID: {NationalID}");
            Console.WriteLine($"Phone Number: {PhoneNumber}");
            Console.WriteLine($"Address: {Address}");
            Console.WriteLine($"Balance: {Balance}");
            Console.WriteLine($"Bank Code: {bankCode}");
            Console.WriteLine($"Created Date: {createdDate}");
        }
        public bool ssValidNationalID()
        {
            return nationalID.Length == 14;
        }
        public bool isValidPhoneNumber()
        {
            return phoneNumber.Length == 11 && phoneNumber.StartsWith("01");
        }
    }
}
