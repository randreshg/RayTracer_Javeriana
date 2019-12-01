/*---------------------------------CLASS DEFINITION--------------------------------*/
class Vector
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    float x,y,z;

    /*----------------------------------FUNCTIONS----------------------------------*/
    //Print info
    void print(){cout<<"["<<x<<","<<y<<","<<z<<"]";}
    
	//Vector info
    string info(){return(to_string(x) + space + to_string(y) + space + to_string(z));}

	//Vector lenght
    float lenght(){return sqrt(x*x + y*y + z*z);}
	
	//Normalize info
    void normalize() {*this = *this/lenght();}

    //Dot
    float dotPoint(Vector v) const
            { return ((x*v.x)+(y*v.y)+(z*v.z));}
    //Scale
    Vector operator* (const float &v) const
            { return Vector((x*v),(y*v),(z*v));}
    //Divide
    Vector operator/ (const float &v) const
            { return Vector((x/v),(y/v),(z/v));}
    //Add
    Vector operator+ (const Vector &v) const
            { return Vector((x+v.x),(y+v.y),(z+v.z));}
    //Substract
    Vector operator- (const Vector &v) const
            { return Vector((x-v.x),(y-v.y),(z-v.z));}
    //Cross
    Vector cross(Vector v) const
            { return Vector(((y*v.z)-(z*v.y)),((z*v.x)-(x*v.z)),((x*v.y)-(y*v.x)));}
    //Equal than
    int operator== (const Vector &v) const
    		{ if((x==v.x) && (y==v.y) && (z==v.z)){return 1;} else {return 0;}}
	//Less than
    int operator< (const Vector &v) const
    		{ if((x<v.x) && (y<v.y) && (z<v.z)){return 1;} else {return 0;}}
	//Less or equal
    int operator<= (const Vector &v) const
    		{ if((x<=v.x) && (y<=v.y) && (z<=v.z)){return 1;} else {return 0;}}
	//greater than
    int operator> (const Vector &v) const
    		{ if((x>v.x) && (y>v.y) && (z>v.z)){return 1;} else {return 0;}}
	//greater or equal
    int operator>= (const Vector &v) const
    		{ if((x>=v.x) && (y>=v.y) && (z>=v.z)){return 1;} else {return 0;}}
    /*--------------------------------CONSTRUCTORS---------------------------------*/
    Vector(){x = 0; y = 0; z = 0;}
    Vector(float x, float y, float z){ this->x = x; this->y = y; this->z = z;}
    Vector(const Vector &v) { *this = v;}
    Vector(Vector a, Vector b){ *this = a - b;}
};
