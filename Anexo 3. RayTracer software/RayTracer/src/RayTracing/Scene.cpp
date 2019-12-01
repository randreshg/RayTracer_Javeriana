/*---------------------------------CLASS DEFINITION--------------------------------*/
class Scene
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    Color background;
    Array<Primitive*> primitives;
    Array<Light> lights;
	
    /*----------------------------------FUNCTIONS----------------------------------*/
    void addPrimitive(Primitive *p){primitives.push_back(p);}
    void addLight(Light l){lights.push_back(l);}
    void print()
    {
        cout<<"SCENE INFO:"<<endl;
        cout<<"\n-Background color [R G B]: "; background.print(); cout<<endl;
        cout<<"\n-Objects info:"<<endl;
        for(unsigned int i= 0; i< primitives.size(); i++)
            primitives[i]->print();
        cout<<"\n-Lights sources info: "<<endl;
        for(unsigned int i= 0; i< lights.size(); i++)
            lights[i].print();
    }
    /*--------------------------------CONSTRUCTORS---------------------------------*/
    Scene(){};
    Scene(Color bkg, Array<Primitive*> primitives, Array<Light> lights)
    {
        this->background = bkg;
        this->primitives = primitives;
        this->lights = lights;
    }
    Scene(const Scene &s)
    {
        background = s.background;
        primitives = s.primitives;
        lights = s.lights;
    }
};
