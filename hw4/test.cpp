#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <stdexcept>
#include "Mem.h"
#include "L1cache.h"
using namespace std;
 
int main() {
    int error_counter = 0; // error counter
    int way_number = 8; // direct mapped: way_number = 1
                        // 2-way: way_number = 2
                        // 4-way: way_number = 4
                        // fully associative: way_number = 8

    Mem mem; // create memory
    L1cache cache(&mem, way_number); // create cache

    for (int i = 0 ; i < 1024 ; i++) {
        int ans = cache.getfromCache(i);
        if (ans != 0) {
            error_counter++;
            cout << "[error] cache address: "<< i << " data: " << ans << " is wrong!!" << endl;
        }
    }

    for (int i = 0 ; i < 1024 ; i++)
        cache.writetoCache(i,i);
	
    for (int i = 0 ; i < 1024 ; i++) {
        int ans = cache.getfromCache(i);
        if (ans != i) {
            error_counter++;
            cout << "[error] cache address: "<< i << " data: "<< ans << " is wrong!!" << endl;
        }
    }
   
    if (error_counter == 0)
        cout << "Well done!! You have passed test bench 1!" << endl;
    else
        cout << "Error!! You have " << error_counter << " errors, please check again!" << endl;
}
