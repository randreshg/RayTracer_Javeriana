/*---------------------------------CLASS DEFINITION--------------------------------*/
class Light
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    Color color;
    Vector position;

    /*----------------------------------FUNCTIONS----------------------------------*/
    //Print info
    void print(){ cout<<"["; position.print(); cout<<", "; color.print(); cout<<"]\n";}
    
    //Sphere info
    string info(){return(position.info());}

    /*--------------------------------CONSTRUCTORS---------------------------------*/
    Light(){};
    Light(const Light &light){ *this = light;}
    Light(Color c, Vector p){ color = c; position = p;}
};
