/*---------------------------------CLASS DEFINITION--------------------------------*/
class Plane: public Primitive
{
    public:
	/*----------------------------------ATTRIBUTES---------------------------------*/
    Vector c;           //Point
    Vector v;           //Normal plane

    /*----------------------------------FUNCTIONS----------------------------------*/
    //Find intersection between a ray and Plane
    void rayIntersection(Ray *ray,Primitive **object)
    {
        Vector voc = (ray->origin) - (c);
        float dv = (ray->direction).dotPoint(v);
        float vocv = voc.dotPoint(v); 
        if(dv != 0)
        {
            ray->distance = -(vocv)/dv;
            if(ray->distance < 0)
                ray->distance = SKY;
            else
            {
                *object = this;
                ray->setP();
            }
            
        }            
    }

    //Get normal given an intersection point
    Vector getNormal(Vector P){return v;}
    //Print info
    void print(){ cout<<"Plane ct[";c.print(); cout<<"], v["; 
                  v.print(); cout<<"]"<<endl;}
    //Info
    string info(){return("P "+c.info()+ space + v.info());}
	/*--------------------------------CONSTRUCTORS---------------------------------*/
    Plane(){};
    Plane(Vector c,Vector v, Properties properties)
        {this->c = c; this->v = v;this->properties= properties;}
    Plane(Vector c,Vector v)
        {this->c = c; this->v = v;}
    Plane(const Plane &cln) {*this = cln;}
};
