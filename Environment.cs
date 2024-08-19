using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestProject
{
    internal class Environment : Entity
    {
        private String location;
        private char[,] board = new char[4,4];
        public String Location
        {
            get { return location; }
            set { location = value; }
        }
        private PlayerCharacter player;
        private List<NonPlayerCharacter> nonPlayerCharaterList =new List<NonPlayerCharacter>();
        public Environment() {
                       
        }
        public void AddCharacter(string name, string type) {
            if(type == "npc")
            {
                NonPlayerCharacter NpcObj = new NonPlayerCharacter(name);
                nonPlayerCharaterList.Add(NpcObj);

            }
            else
            {
                player = new PlayerCharacter(name);
                
            }
        }

        public void initiateBoard()
        {
            for (int i = 0; i < 4; i++)
            {
                for (int j = 0; j < 4; j++)
                {
                    board[i, j] = '-';
                }
            }

            Console.WriteLine("Board Initiated");
        }
        public override void Render()
        {
            for (int i = 0; i < 4; i++)
            {
                for (int j = 0; j < 4; j++)
                {
                    Console.Write(board[i, j] + " ");
                }
                Console.WriteLine(); // Move to the next line after each row
            }
        }
           public override void Update(int newX, int newY)
        {
            
            if(player == null)
            {
                Console.WriteLine("No Player initiated");
                return;
            }
            int x = player.x;
            int y = player.y;
            board[x, y] = '-';
            player.x = newX;
            player.y= newY;
            board[newX, newY] = 'P'; 

        }
        public void askNewMove()
        {
            Console.WriteLine("What will be the next move ?");
            Console.WriteLine("w to Move up");
            Console.WriteLine("a to Move left");
            Console.WriteLine("d to Move right");
            Console.WriteLine("s to Move down");
            char move = Convert.ToChar(  Console.ReadLine());
            switch (move)
            {
                case 'w':
                    break;
                case 'a':
                    break;
                case 's':
                    break;
                case 'd':
                    break;
                default:
                    break;
            }
        }
    }
}
