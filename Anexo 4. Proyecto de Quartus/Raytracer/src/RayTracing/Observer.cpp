/*---------------------------------CLASS DEFINITION--------------------------------*/
class Observer
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    Vector from;        //Eye location in XYZ.
    Vector up;          //A vector defining which direction is up
    Vector lookAt;      //A position to be at the center of the image
    float angle;        //In degrees

	/*----------------------------------FUNCTIONS----------------------------------*/
	//Info
    string info(){return(from.info());}
    //Print info
    void print()
    {
        cout<<"\n Observer"; 
        cout<<"\nFrom: "; from.print(); 
        cout<<"\nAt: "; lookAt.print();
        cout<<"\nUp: "; up.print();
        cout<<"\nAngle:"<<angle<<endl;
    }
    
    /*--------------------------------CONSTRUCTORS---------------------------------*/
    Observer(){};
    Observer(const Observer &obs) {*this = obs;}
    Observer(Vector from, Vector lookAt, Vector up, float angle)
            {this->from = from; this->lookAt = lookAt;
			 this->up = up; this->angle = angle;}

};
