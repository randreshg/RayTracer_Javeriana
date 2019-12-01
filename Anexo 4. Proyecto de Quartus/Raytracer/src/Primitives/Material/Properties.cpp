/*---------------------------------CLASS DEFINITION--------------------------------*/
class Properties
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    Color objectColor;      //Object color
    float shine;            //Phong cosine power for highlights
    float kd;               //Diffuse component
    float ks;               //Specular component
    float t;                //Transmittance (fraction of the transmitting ray)
    float iof;              //Index of refraction

    /*----------------------------------FUNCTIONS----------------------------------*/
    void print()
    {
        cout<<"\nObject color: ";  objectColor.print();
        cout<<"\nKd: "<<kd;
        cout<<"\nKs: "<<ks;
        cout<<"\nShine: "<<shine;
        cout<<"\nTransmitance: "<<t<<endl;
    }

	/*--------------------------------CONSTRUCTORS---------------------------------*/
    Properties(){}
    Properties(const Properties &prop){ *this = prop;}
    Properties(Color objectColor,float kd, float ks, float shine, float t,float iof)
    {
        this->objectColor = objectColor;
        this->kd = kd; this->ks = ks;
        this->t = t; this->shine = shine; this->iof = iof;
    }
};
