namespace Assignment_3_8
{
    internal class Program
    {
        static void Main(string[] args)
        {
            bankSys b1 = new bankSys();
            bankSys b2 = new bankSys("Mohammed", "30210121701599", "01279151626", "Cairo", 20000);
            b1.showAccountDetails();
            b2.showAccountDetails();
        }
    }
}
