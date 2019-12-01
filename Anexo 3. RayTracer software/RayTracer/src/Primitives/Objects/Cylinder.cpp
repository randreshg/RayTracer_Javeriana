/*---------------------------------CLASS DEFINITION--------------------------------*/
class Cylinder: public Primitive
{
    public:
	/*----------------------------------ATTRIBUTES---------------------------------*/
    Vector ct;          //Top cap
    Vector cb;          //Botton cap
    float r;            //Radio
    Vector v;           //Axys direction
    float maxm;         // Cilynder 
    float m;            //Closest point to intersection point over axys direction

    /*----------------------------------FUNCTIONS----------------------------------*/
    //Find intersection between a ray and Cilynder
    void rayIntersection(Ray *ray, Primitive **object)
    {
        //|Vector voc = (this->center) - (r->o);
        float a,b,c,RV;
        RV = (ray->direction).dotPoint(v);
        Vector Vocb = (ray->origin) - cb;
        float VocbDotv = Vocb.dotPoint(v);
        a = 1 - RV*RV;
        b = 2*((ray->direction).dotPoint(Vocb) - RV*VocbDotv);
        c = Vocb.dotPoint(Vocb) - VocbDotv*VocbDotv- r*r;
        quadraticSolution(a,b,c,&(ray->distance));


        if(ray->distance != SKY)
        {
            m = ((ray->direction)*(ray->distance)).dotPoint(v) + VocbDotv;
            /**object = this;
                ray->setP();*/           
            if(m>0 && m<maxm)
            {           
                *object = this;
                ray->setP();
            }
            else
                ray->distance = SKY;
            
        }
        //cout<<"Cylinder Distance: "<<ray->distance <<endl;
        //cout<<"m: "<<m<<endl;
        /*else if (m<0)
            {
                cout<<"ENTRA"<<endl;
                float d1;
                Plane *p1 = new Plane(cb,v*(-1)); 
                p1->rayIntersection(ray,d,object);

                //Plane *p2 = new Plane(ct,v)
                //p2->rayIntersection(ray,&d2,&obj);
                /*if((d1 != SKY) || (d2 != SKY))
                {
                    *object = ((d1<d2)? p1:p2);
                    *d = ((d1<d2)? d1:d2);
                }              
        }*/
    }
            
    //Get normal given an intersection point
    Vector getNormal(Vector P)
    {
        Vector cp = cb+ v*m;
        Vector N(P,cp); N.normalize();
        return N;
    }
    //Print info
    void print(){ cout<<"Cylinder ct[";ct.print(); cout<<"], cb["; 
                  cb.print(); cout<<"], r "<<r<<endl;}
    //Iinfo
    string info(){return("C "+cb.info()+ space + to_string(r) + space 
                         + v.info() + space + to_string(maxm) );}
	/*--------------------------------CONSTRUCTORS---------------------------------*/
    Cylinder(){};
    Cylinder(Vector ct,Vector cb, float r, Properties p)
       {this->ct = ct; this->cb = cb; this->r = r; 
        Vector v = (ct-cb); maxm = v.lenght();
        v.normalize(); this->v = v; m = 0; this->properties = p; } 
    Cylinder(const Cylinder &cln) {*this = cln;}
};
