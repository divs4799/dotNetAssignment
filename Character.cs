using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestProject
{
    public class Character
    {
        private String Name;

        private int health = 100;
        public int Health{
        set { health = value; }
            get { return health; }
                }

        private int energy = 100;
        public int Energy {  
            set { health = value; } 
            get{ return energy; }
        }

        public Character(String Name)
        {
            this.Name = Name;
            Console.WriteLine("paernt constructor");
        }

        public void Move()
        {

        }
        public void Interact()
        {

        }
    }
}
