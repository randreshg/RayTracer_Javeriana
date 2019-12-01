/*---------------------------------CLASS DEFINITION--------------------------------*/
class Ray
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    Vector origin;     
    Vector direction;  
    float distance;    
    Vector P;          //P = o + d(distance)

    /*----------------------------------FUNCTIONS----------------------------------*/
    //Print info
    void print(){ cout<<"["; origin.print(); cout<<" "; direction.print(); cout<<"]"<<endl;}
    void setP(){ P = origin + direction*(distance);}
    /*--------------------------------CONSTRUCTORS---------------------------------*/
    Ray(){ distance = SKY;}
    Ray(const Ray &ray){ *this = ray;}
    Ray(Vector o, Vector d, float distance)
            { this->origin = o; this->direction = d; this->distance = distance; setP();}
    Ray(Vector o, Vector d)
            {  distance = SKY; this->origin = o; Vector v(d,o);
               v.normalize(); this->direction = v; 
            }
};
