/*---------------------------------CLASS DEFINITION--------------------------------*/
class Primitive
{
    public:
    Properties properties;
    /*----------------------------------FUNCTIONS----------------------------------*/
    //Find intersection between a ray and primitive
    virtual void rayIntersection(Ray *ray,Primitive **object)=0;
    //Get normal given an intersection point
    virtual Vector getNormal(Vector P)=0;
    //Print primitive info
    virtual void print()=0;
    //Primitive info
    virtual string info()=0;
    /*--------------------------------CONSTRUCTORS---------------------------------*/
    Primitive(){};
    ~Primitive(){};
};
