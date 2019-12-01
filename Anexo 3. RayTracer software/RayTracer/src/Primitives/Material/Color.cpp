/*---------------------------------CLASS DEFINITION--------------------------------*/
class Color
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    float R, G, B;

    /*----------------------------------FUNCTIONS----------------------------------*/
    //Print info
    void print(){ cout<<"["<<R<<" "<<G<<" "<<B<<"]";}
    //Vector info
    string info(){return(to_string(R) + space + to_string(G) + space + to_string(B));}
     //Add
    Color operator+ (const Color &c) const
            { return Color((R+c.R),(G+c.G),(B+c.B));}
    //Substract
    Color operator- (const Color &c) const
            { return Color((R-c.R),(G-c.G),(B-c.B));}
    //Scale
    Color operator* (const float &v) const
            { return Color((R*v),(G*v),(B*v));}

    /*--------------------------------CONSTRUCTORS---------------------------------*/
    Color(){R = 0; G = 0; B = 0;}
    Color(float R, float G, float B){this->R = R; this->G = G; this->B = B;}
    Color(const Color &color) { *this = color;}

};
