using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestProject
{
     public class PlayerCharacter:Character
    {
        private int X = 3;
        public int x
        {
            get { return X; } 
            set { X = value; }
        }

        private int Y =0;
        public int y
        {
            get { return Y; }
            set { Y = value; }
        }
        public PlayerCharacter(String name):base(name) {
            
        }
        public void Attack() { }
        public void Heal() {
            
        
        }


    }
}
