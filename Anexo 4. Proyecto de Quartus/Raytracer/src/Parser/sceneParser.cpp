
/*----------------------------------FUNCTIONS----------------------------------*/
void readBackground(Scene *scene)
{
    Color color;
    color.R = atof(strtok(NULL, " "));
    color.G = atof(strtok(NULL, " "));
    color.B = atof(strtok(NULL, " "));
    scene->background = color;
}

void readLight(Scene *scene)
{
    Vector point; Color color;
    point.x = atof(strtok(NULL, " "));
    point.y = atof(strtok(NULL, " "));
    point.z = atof(strtok(NULL, " "));
    color.R = atof(strtok(NULL, " "));
    color.G = atof(strtok(NULL, " "));
    color.B = atof(strtok(NULL, " "));
    Light l(color,point);
    scene->addLight(l);
}

void readCylinder(Scene *scene, Properties p)
{
    Vector ct,cb; float r;
    ct.x = atof(strtok(NULL, " "));
    ct.y = atof(strtok(NULL, " "));
    ct.z = atof(strtok(NULL, " "));
    r    = atof(strtok(NULL, " "));
    cb.x = atof(strtok(NULL, " "));
    cb.y = atof(strtok(NULL, " "));
    cb.z = atof(strtok(NULL, " "));
    r    = atof(strtok(NULL, " "));
    scene->addPrimitive(new Cylinder(ct,cb,r,p));
}
void readPolygon(Scene *scene, Properties p, char *str, FILE *fp)
{
    int nVertices; Vector *vertices;
    nVertices = atof(strtok(NULL, " "));
    vertices = new Vector[nVertices];
    
    for(int i=0; i<nVertices; i++)
    {
        fgets(str, MAXCHAR, fp);
        vertices[i].x   = atof(strtok(str, " "));
        vertices[i].y   = atof(strtok(NULL, " "));
        vertices[i].z   = atof(strtok(NULL, " "));
    }
    scene->addPrimitive(new Polygon(nVertices,vertices,p));
}
void readSphere(Scene *scene, Properties p)
{
    Vector point; float r;
    point.x = atof(strtok(NULL, " "));
    point.y = atof(strtok(NULL, " "));
    point.z = atof(strtok(NULL, " "));
    r       = atof(strtok(NULL, " "));
    scene->addPrimitive(new Sphere(point,r,p));
}
/*Fill color and shading parameters.  Description:
"f" red green blue Kd Ks Shine T index_of_refraction*/
Properties readProperties()
{
    Color color; float kd,ks,shine,t,iof;
    color.R = atof(strtok(NULL, " "));
    color.G = atof(strtok(NULL, " "));
    color.B = atof(strtok(NULL, " "));
    kd      = atof(strtok(NULL, " "));
    ks      = atof(strtok(NULL, " "));
    shine   = atof(strtok(NULL, " "));
    t       = atof(strtok(NULL, " "));
    iof     = atof(strtok(NULL, " "));
    Properties p(color,kd,ks,shine,t,iof);
    return p;
}

void readObserver(Observer *observer, char *str, FILE *fp)
{
    Vector from, lookAt; Vector up; float angle ;
    //Read from
    fgets(str, MAXCHAR, fp); strtok(str, " ");
    from.x   = atof(strtok(NULL, " "));
    from.y   = atof(strtok(NULL, " "));
    from.z   = atof(strtok(NULL, " "));
    observer->from = from;
    //Read at
    fgets(str, MAXCHAR, fp); strtok(str, " ");
    lookAt.x = atof(strtok(NULL, " "));
    lookAt.y = atof(strtok(NULL, " "));
    lookAt.z = atof(strtok(NULL, " "));
    observer->lookAt = lookAt;
    //Read up
    fgets(str, MAXCHAR, fp); strtok(str, " ");
    up.x    = atof(strtok(NULL, " "));
    up.y    = atof(strtok(NULL, " "));
    up.z    = atof(strtok(NULL, " "));
    observer->up = up;
    //Read angle
    fgets(str, MAXCHAR, fp); strtok(str, " ");
    angle   = atof(strtok(NULL, " "));
    observer->angle = angle;
}

void readScreen(Screen *s)
{
    s->width  = atof(strtok(NULL, " "));
    s->height = atof(strtok(NULL, " "));
}

int readFile(char *name,RayTracer *RT)
{
    try
    {
        FILE *fp = fopen(name, "r");
        if (fp == NULL)
            throw 0;//Char array to save the data read
        //Go through file
        Scene scene; Screen screen; Observer observer;
        Properties p;
        char str[MAXCHAR];         
        while (fgets(str, MAXCHAR, fp) != NULL)
        {
            char *ptr = strtok(str, " ");
            while(ptr != NULL)
            {
                if(strcmp(ptr, "b") == 0)
                    readBackground(&scene);
                else if(strcmp(ptr, "resolution") == 0)
                    readScreen(&screen);
                else if(strcmp(ptr, "l") == 0)
                    readLight(&scene);
                else if(strcmp(ptr, "s") == 0)
                    readSphere(&scene,p);
                else if(strcmp(ptr, "c") == 0)
                    readCylinder(&scene,p);
                else if(strcmp(ptr, "p") == 0)
                    readPolygon(&scene,p,str,fp);
                else if(strcmp(ptr, "f") == 0)
                    p = readProperties();
                else if(strcmp(ptr, "v") >= 1)
                    readObserver(&observer,str,fp);
                ptr = strtok(NULL, " ");
            }
        }
        fclose(fp);
        //Save data in RayTracer object
        RT->observer = observer;
        RT->screen = screen;
        RT->scene = scene;
        RT->ScreenItrInfo(); //Set Screen iterator info
        return 1;
    } catch(int i){
        cout<<"There was an error reading the scene file. Be sure the file exists"<<endl;
        return 0;
    }
}
