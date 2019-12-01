#ifndef DEPENDENCIES
#define DEPENDENCIES
    //-------------------------------------------CONSTANTS-------------------------------------------//
    #define Array vector
    #define PI 3.14159265
    #define MAXCHAR 100
    #define SKY 100000
    //------------------------------------------LIBRARIES-------------------------------------------//
    #include <bits/stdc++.h>
    #include <iostream>
    #include <fstream>
    #include <string>
    #include <stdlib.h>
    #include <stdio.h>
    #include <math.h>
    #include <time.h>
    #include <vector>
    #include<algorithm>
    using namespace std;
    string space = " ";
    //------------------------------------------FUNCTIONS-------------------------------------------//

    #define quadraticSolution(a,b,c,d){                 \
    float disc, t1, t2, dst;                            \
    disc = b*b - 4*a*c;                                 \
    if(disc<0.0)                                        \
        *d = SKY;                                       \
    else{                                               \
        dst = sqrt(disc);                               \
        t1=(-b+(dst))/(2*a), t2=(-b-(dst))/(2*a);       \
        *d = (t1<0.0 ? SKY : (t2>0.0 ? t2 : t1));}}     \
    //------------------------------------------CLASSES--------------------------------------------//
    #include "Vector.cpp"
    #include "Ray.cpp"
    struct ScreenItr{ Vector scanLine,pixelWidth,pixelHeight;};
    //Primitives
    #include "Primitives/Material/Color.cpp"
    #include "Primitives/Material/Properties.cpp"
    #include "Primitives/Primitive.cpp"
    #include "Primitives/Objects/Sphere.cpp"
    #include "Primitives/Objects/Plane.cpp"
    #include "Primitives/Objects/Cylinder.cpp"
    #include "Primitives/Objects/Polygon.cpp"
    //RayTracing
    #include "RayTracing/Screen.cpp"
    #include "RayTracing/Observer.cpp"
    #include "RayTracing/Light.cpp"
    #include "RayTracing/Scene.cpp"
    #include "RayTracing/RayTracer.cpp"
    //Parser
    #include "Parser/argumentParser.cpp"
    #include "Parser/sceneParser.cpp"

#endif
