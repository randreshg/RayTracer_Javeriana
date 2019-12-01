/*---------------------------------CLASS DEFINITION--------------------------------*/
class RayTracer
{
    public:
    /*----------------------------------ATTRIBUTES---------------------------------*/
    Scene scene;
    Screen screen;
    Observer observer;
    ScreenItr sItr;

    /*----------------------------------FUNCTIONS----------------------------------*/
    int trace(int option)
    {
        Primitive *object;
        int xResolution = screen.width;
        int yResolution = screen.height;
        Vector xPixel, yPixel;
        //PPM file
        FILE * fp = fopen ("Output/Pictures/file.ppm", "w+");
        fprintf (fp, "P3\n%d %d\n255\n",xResolution,yResolution);  
        //Calculate the time taken by the program
        clock_t t = clock();
        for(int i=0; i<yResolution; i++)
        {             
            yPixel = sItr.pixelHeight*i;
            for(int j=0; j<xResolution; j++)
            {         
                xPixel =  sItr.pixelWidth*j; 
                Ray primaryRay(observer.from,(sItr.scanLine-yPixel)+xPixel); 
                intersectionTest(&primaryRay,&object);
                Color pixelColor = shading(primaryRay,object,option,0);
                pixelColor = pixelColor*(255);
                
                fprintf (fp, "%d %d %d ",(int)pixelColor.R ,(int)pixelColor.G,(int)pixelColor.B);
            }
        }
        t = clock() - t;
        double timeTaken = ((double)t)/CLOCKS_PER_SEC;
        printf("The process took %f seconds to execute \n", timeTaken);
        return 0;
    } 

    void intersectionTest(Ray *primaryRay, Primitive **object)
    {
        Primitive *obj;
        Ray ray = *primaryRay;
        for(unsigned int i=0; i<scene.primitives.size();i++)
        {
            (scene.primitives[i])->rayIntersection(&ray,&obj);
            if((ray.distance) < (primaryRay->distance))
            {      
                *primaryRay = ray;
                *object = obj;
            }
        }
    } 
    
    Color shading(Ray ray, Primitive *object, int option,int depth)
    {
        Color b = scene.background;
        if(ray.distance == SKY)
            return b;
        else
            return colorContribution(object,ray,option,depth);           
    }

    Color colorContribution(Primitive *object, Ray ray, int option,int depth)
    {
        //Auxiliar variables
        Color color;
        Vector P = ray.P;
        Vector N = object->getNormal(P);        

        if(option == 0 || option ==1)
        {
            Vector V = ray.direction*(-1);
            color = fullScale(P,N,V,object,depth);   
        }
        else if(option == 2)
            color = grayScale(P,N);
        else if(option == 3)
            color = FPGAScale(P,N);        
        return color;
    }
    
    Color fullScale(Vector P,Vector N,Vector V, Primitive *object,int depth)
    {
        //Primitive properties
        Color objectColor = (object->properties).objectColor;
        float shine = (object->properties).shine;
        float kd = (object->properties).kd;
        float ks = (object->properties).ks;
        //Aux variables
        Color color;
        Array<Light> lights = scene.lights;
        Primitive *shadowObject;
        Vector offsetPoint;
        float diffuse, specular;
        float intensity = 1/sqrt(lights.size());
        /*-----------------------Light contribution-------------------------*/
        for(unsigned int i=0; i<lights.size(); i++)
        {
            Vector L(lights[i].position,P); L.normalize();
            offsetPoint = P + L*(10e-4);
            /*------------------------Shadow ray----------------------------*/
            //Add a little offset to avoid the ray hits the same sphere
            Ray shadowRay(offsetPoint,L,SKY);
            intersectionTest(&shadowRay,&shadowObject);
            /*-----------------------------Shade----------------------------*/
            if(shadowRay.distance == SKY)
            {
                /*-------------------Diffuse component----------------------*/
                diffuse = kd*fmax(0,L.dotPoint(N));
                /*-------------------Specular component---------------------*/
                Vector R = L*(-1) + N*(2*(N.dotPoint(L)));
                R.normalize();
                specular = ks*pow(fmax(0,R.dotPoint(V)),shine);
                /*-------------------Light contribution---------------------*/
                color.R += ((diffuse*objectColor.R) + specular)*(intensity);
                color.G += ((diffuse*objectColor.G) + specular)*(intensity);
                color.B += ((diffuse*objectColor.B) + specular)*(intensity);                                      
            }
        }
        if(depth < 5 && ks>0)
        {
            Primitive *hitObject;
            Vector R = V*(-1) + N*(2*(N.dotPoint(V)));
            R.normalize();
            offsetPoint = P + R*(10e-4);
            Ray reflectedRay(offsetPoint,R);
            intersectionTest(&reflectedRay,&hitObject);
            Color reflectedColor = shading(reflectedRay,hitObject,0,depth + 1);
            color.R += (reflectedColor.R)*(ks);
            color.G += (reflectedColor.G)*(ks);
            color.B += (reflectedColor.B)*(ks);
        }
        return color;
    }

    Color grayScale(Vector P, Vector N)
    {
        Array<Light> lights = scene.lights;
        Primitive *shadowObject;
        Color color;
        float i_diff;
        for(unsigned int i=0; i<lights.size(); i++)
        {
            Vector L(lights[i].position,P); 
            L.normalize();
            /*------------------------Shadow ray---------------------------*/
            //Add a little offset to avoid the ray hits the same sphere
            P = P + L*(10e-4);
            Ray shadowRay(P,L,SKY);
            intersectionTest(&shadowRay,&shadowObject);
            /*-----------------------------Shade----------------------------*/
            if(shadowRay.distance == SKY)
            {
                Vector L(lights[i].position,P); 
                L.normalize();
                i_diff = L.dotPoint(N);            
                if(i_diff>0)
                {
                    color.R += i_diff; 
                    color.G += i_diff; 
                    color.B += i_diff;
                }
            }
        }
        return color;
    }

    Color FPGAScale(Vector P, Vector N)
    {
        Array<Light> lights = scene.lights;
        Color color;
        float i_diff;
        for(unsigned int i=0; i<lights.size(); i++)
        {
            /*-----------------------------Shade----------------------------*/
            Vector L(lights[i].position,P); 
            L.normalize();
            i_diff = L.dotPoint(N);            
            if(i_diff>0)
            {
                color.R += i_diff; 
                color.G += i_diff; 
                color.B += i_diff;
            }
        }
        return color;
    }

    void ScreenItrInfo()
    {
        Vector w(observer.lookAt,observer.from); w.normalize();
        Vector u = w.cross(observer.up); u.normalize();
        Vector v = u.cross(w);
        float tanFOV = tan((observer.angle/2)*PI/180.0);
        float aspectRatio = screen.width/screen.height;
        float cameraheight = tanFOV*2;  
        float camerawidth  = aspectRatio*cameraheight;
        float pixelH = cameraheight/screen.height; sItr.pixelHeight = v*pixelH;
        float pixelW = camerawidth/screen.width;   sItr.pixelWidth = u*pixelW;         
        Vector xComponent = u; xComponent = xComponent*((screen.width*pixelW)/2);
        Vector yComponent = v; yComponent = yComponent*((screen.height*pixelH)/2);
        Vector corner = observer.from + w - xComponent + yComponent;
        sItr.scanLine =  corner - (sItr.pixelHeight)*(1/2) + (sItr.pixelWidth)*(1/2);
    }

    void print()
    {
        cout<<"OBSERVER COORDINATES: "<<endl; observer.print();
        cout<<"SCREEN SIZE: "; screen.print();
        cout<<"SCENE: \n"; scene.print();
    }

    void toTextFile()
    {
        ofstream salida;
        salida.open("Output/FPGA.txt");
        if(salida.is_open())
        {
            salida<<"O"<<endl;
            salida<<observer.info()<<endl;
            salida<<sItr.scanLine.info()<<endl;
            salida<<sItr.pixelWidth.info()<<endl;
            salida<<sItr.pixelHeight.info()<<endl;
            salida<<"L "<<endl;
            salida<<scene.lights[0].info()<<endl;
            salida<<"P "<<scene.primitives.size()<<endl;
            for(unsigned int i=0; i<scene.primitives.size();i++)
            	salida<<(scene.primitives[i])->info()<<endl;
	    salida<<"E";
        }
        else
            cout<<"Error: File couldn't be created!"<<endl;
        salida.close();
    }

    /*--------------------------------CONSTRUCTORS---------------------------------*/
    RayTracer(){};
    RayTracer(const RayTracer &s){ *this = s;}
    RayTracer(Scene scene, Observer observer, Screen screen)
    {
        this->scene = scene;
        this->observer = observer;
        this->screen = screen;
    }
};
