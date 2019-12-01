/*---------------------------------CLASS DEFINITION--------------------------------*/
class Sphere: public Primitive
{
    public:
	/*----------------------------------ATTRIBUTES---------------------------------*/
    Vector center;      //Center
    float r;            //Ratio

    /*----------------------------------FUNCTIONS----------------------------------*/
    //Find intersection betweern a ray and sphere
    void rayIntersection(Ray *ray,Primitive **object)
    {
        float a,b,c;
        Vector voc = (ray->origin) - (center);
        a = 1;
        b = 2*(ray->direction).dotPoint(voc);
        c = voc.dotPoint(voc) - r*r;
        quadraticSolution(a,b,c,&(ray->distance));
        if(ray->distance != SKY){ray->setP(); *object = this;}
        //cout<<"Sphere Distance: "<<ray->distance <<endl;
    }

    //Get normal given an intersection point
    Vector getNormal(Vector P)
    {
        Vector N(P,center); N.normalize();
        return N;
    }
    
    //Print info
    void print() { cout<<"Sphere ["; center.print(); cout<<", "<<r<<"]"<<endl;}
    
    //Sphere info
    string info(){return("S " + center.info()+ space + to_string(r)+ space + "0.000000"
                         + space + "0.000000" + space + "0.000000"
                         + space + "0.000000");}
	/*--------------------------------CONSTRUCTORS---------------------------------*/
    Sphere(){};
    Sphere(Vector c, float r, Properties properties)
        {this->center = c; this->r = r; this->properties = properties;}
    Sphere(const Sphere &sph) {*this = sph;}
};
