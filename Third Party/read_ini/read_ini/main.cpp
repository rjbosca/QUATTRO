//
//  main.cpp
//  read_ini

#include <iostream>
#include <map>
#include "../cpp/INIReader.h"
#include "../cpp/INIReader.cpp"
#include "../ini.h"
#include "../ini.c"

using namespace std;

int main(int argc, const char * argv[]) {
    
    string fName = argv[0];
    
    //Creates an INIReader object, passing it the INI file
    INIReader reader(fName);
    
    //Checks to ensure the INI file can be opened
    if (reader.ParseError() < 0) {
        cout << "Can't load the requested file.\n";
        return 1;
    }
    
    //Creates a map<string, string> to hold the property-value pairs, with image properties as kays and property values as values
    map<string, string> the_map = reader.Disp();
    
    //Print contents of map
    for(auto elem : the_map){
        cout << elem.first << " = " << elem.second << "\n\n";
    }
    
    return 0;
}