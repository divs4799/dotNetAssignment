using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestProject
{
    abstract class Entity
    {
        public abstract void Update(int x , int y);
        public abstract void Render();

    }
}
