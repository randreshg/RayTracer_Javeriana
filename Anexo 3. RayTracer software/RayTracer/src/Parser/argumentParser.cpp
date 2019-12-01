
int parseArguments(int argc, char *argv[])
{
    if(argc > 1)
    {
        
        if(argc>2)
        {
            if(strcmp(argv[2], "1") == 0)       //Trace-color
                return 1;
            else if(strcmp(argv[2], "2") == 0)  //Trace-gray scale
                return 2;
            else if(strcmp(argv[2], "3") == 0)  //Generate image for comparation
                return 3;
            else if(strcmp(argv[2], "4") == 0)  //FPGA preparation info
                return 4;
            else                                    
                return 0;
        }
        else                                    
            return 0;
    }
    else                                    
        return -1;  
}
