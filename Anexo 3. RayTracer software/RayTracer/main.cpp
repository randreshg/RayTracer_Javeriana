#include "src/dependencies.h"
int parseArguments(int, char **);

int main(int argc, char *argv[])
{
    /*----------------------------------Variable declaration----------------------------------*/
    int option = parseArguments(argc,argv);

    //Program option
    if(option != -1)
    {
        RayTracer RT;
        string folder("Scenes/");
        string extension(".nff");
        string name = folder+ argv[1] + extension;
        char file[name.size()+1];
        strcpy(file,name.c_str());
        cout<<"FILE: "<<file<<endl;
        if (readFile(file,&RT) == 0)
            return 0;
        if(option == 4)
        {
            cout<<"Preparing FPGA file"<<endl;
            RT.toTextFile();
        }
        else
            RT.trace(option);
    }
    else
        cout<<"No scene was selected"<<endl;
    
} 