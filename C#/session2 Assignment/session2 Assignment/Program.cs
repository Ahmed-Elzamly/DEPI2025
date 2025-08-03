using System.Diagnostics;
using System.Runtime.InteropServices;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace session2_Assignment
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello!");
            Console.WriteLine("Input the first number:");
            int num1 = int.Parse(Console.ReadLine());
            Console.WriteLine("Input the second number:");
            int num2 = int.Parse(Console.ReadLine());
            Console.WriteLine("What do you want to do with those numbers?\r\n[A]dd\r\n[S]ubtract\r\n[M]ultiply");
            char op = char.Parse(Console.ReadLine());
            if(op == 'A' || op == 'a')
            {
                Console.WriteLine($"{num1} + {num2} = {num1 + num2}");
            }
            else if (op == 'S' || op == 's')
            {
                Console.WriteLine($"{num1} - {num2} = {num1 - num2}");
            }
            else if(op == 'M' || op == 'm')
            {
                Console.WriteLine($"{num1} * {num2} = {num1 * num2}");
            }
            else
            {
                Console.WriteLine("Invalid option");
            }
            Console.WriteLine("Press any key to close");
            Console.ReadKey();
        }
    }
}
