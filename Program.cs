using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestProject
{

    interface IInteractive
    {
        void IInteractive();
        void Update();
    }

    internal class Program
    {
        static void Main(string[] args)
        {
            //Initialize environment
            Environment environment1 = new Environment();
            environment1.initiateBoard();
            environment1.AddCharacter("Player 1","he");
            Console.WriteLine("The aim of this game is to move to the top right corner");
            environment1.placeCharacter(3,0);
            environment1.displayBoard();
            Console.ReadLine();
            environment1.askNewMove();
            Console.ReadLine();
        }
    }
}
