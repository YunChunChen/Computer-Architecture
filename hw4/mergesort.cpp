#include <stdio.h>
#include <iomanip>
#include <iostream>
#include <stdlib.h>
#include <algorithm>
#include <stdexcept>
#include "Mem.h"
#include "L1cache.h"

using namespace std;

#define max 200

void merge(L1cache*, int, int, int*); //merge two lists
void mergeSort(L1cache*, int, int, int*);

int main() {
    int error_counter = 0; // error counter
    int cal_numbers = 0; // CPU calculate cycles
    int way_number = 8; // direct map: way_number = 1 
                        // 2-way: way_number = 2 
                        // 4-way: way_number = 44 
                        // fully associative: way_number = 8
    
    int orig_list[max] = {8,171,145,34,98,91,42,52,157,172,45,195,77,143,104,122,
                          183,155,81,141,196,162,71,24,197,161,148,119,151,131,188,
                          72,166,109,35,48,60,189,90,138,73,50,74,125,105,88,120,
                          135,51,47,147,49,69,65,126,39,139,15,142,22,64,54,114,179,
                          169,94,154,156,137,93,149,107,153,95,124,185,168,102,121,
                          44,182,89,115,68,144,59,103,150,116,96,129,13,37,191,46,
                          61,16,57,158,87,123,175,12,165,58,55,111,190,40,181,100,
                          1,134,66,76,18,33,31,4,21,136,174,186,10,43,75,25,41,160,
                          53,67,97,26,106,23,173,128,200,180,56,3,112,177,79,176,27,
                          194,133,80,20,187,132,170,159,117,30,163,184,178,86,198,
                          193,14,5,118,167,99,38,19,62,101,85,82,36,9,63,6,192,28,
                          140,146,108,17,164,127,130,32,2,78,83,92,199,70,29,84,110,
                          7,11,152,113};
    Mem mem;
    L1cache cache(&mem,way_number);

    int i;
    int n = max;
    int data[4];

    for (i = 0 ; i < n ; i++) {   
        data[i%4] = orig_list[i];
        if (i % 4 == 3)
            mem.writetoMem(i/4,data);
    }
    int data_print; // print data
    printf("\nBefore Sorting: \n");
    for (i = 0 ; i < n ; i++) {
        data_print = cache.getfromCache(i);
        printf("%d ", data_print);
        if (data_print != orig_list[i]) {
            cout << "Error occurs at address " << i << " original data " << orig_list[i];
            cout << " your data " << data_print <<" not equal" << endl;
            error_counter ++ ;
        }
    }

    mergeSort(&cache, 0, n-1, &cal_numbers);
    sort(orig_list, orig_list+max);

    printf("\nAfter Sorting:\n");
    for (i = 0 ; i < n ; i++) {
        data_print = cache.getfromCache(i);
        printf("%d ", data_print);
        if (data_print != orig_list[i]) {
            cout << "Error occurs at address " << i << " original data " << orig_list[i];
            cout << " your data " << data_print <<" not equal" << endl;
            error_counter++ ;
         }
    }

    if (way_number == 1)
        cout << endl << "way_number = 1, direct-mapped" << endl;
    else if (way_number == 2)
        cout << endl << "way_number = 2, 2-way" << endl;
    else if (way_number == 4)
        cout << endl << "way_number = 4, 4-way" << endl;
    else 
        cout << endl << "way_number = 8, fully associative" << endl;

    double rate = double(cache.getHit()) / double(cache.getHit() + cache.getMiss()) * 100;
    cout << endl << "Hit rate: " << setprecision(4) << rate << "%" << endl;

    if (error_counter == 0)
        cout << "Well done!! You have passed test bench 3!" << endl;
    else
        cout << "Error!! You have " << error_counter << " errors, please check again!" << endl;

    cout << "Total hit: " << cache.getHit() << endl;
    cout << "Total miss: " << cache.getMiss() << endl;
}

void merge(L1cache* cache, int left, int right, int* cal_numbers) {  
    int i, j, k;
    int mid = (left + right) / 2;
    (*cal_numbers)++;
    i = left;
    k = left + max;
    j = mid + 1;
    *cal_numbers = *cal_numbers + 3;

    while (i <= mid && j <= right) {
        *cal_numbers = *cal_numbers + 4;
        int temp1, temp2;
        temp1 = cache->getfromCache(i);
        temp2 = cache->getfromCache(j);
        if (temp1 < temp2) {
            *cal_numbers = *cal_numbers + 2;
            int temp;
            temp = temp1;
            cache->writetoCache(k,temp);
            k++;
            i++;
            *cal_numbers = *cal_numbers + 2;
        }
        else {
            *cal_numbers = *cal_numbers + 2;
            int temp;
            temp = temp2;
            cache->writetoCache(k,temp);
            k++;
            j++;
            *cal_numbers = *cal_numbers + 2;
        }
    }
    while (i <= mid) {  
        *cal_numbers = *cal_numbers + 2;
        int temp;
        temp = cache->getfromCache(i);
        cache->writetoCache(k,temp);
        k++;
        i++;
        *cal_numbers = *cal_numbers + 2;
    }
    while (j <= right) {
        *cal_numbers = *cal_numbers + 2;
        int temp;
        temp = cache->getfromCache(j);
        cache->writetoCache(k,temp);
        k++;
        j++;
        *cal_numbers = *cal_numbers + 2;
    }
    *cal_numbers = *cal_numbers + 2;
    for (i = left, k = left + max ; i <= right ; i++, k++) {
        *cal_numbers = *cal_numbers + 4;
        int temp;
        temp = cache->getfromCache(k);
        cache->writetoCache(i,temp);
    }
}

void mergeSort(L1cache* cache, int left, int right, int* cal_numbers) {
    int mid;
    if (left >= right)
        return;
    *cal_numbers = *cal_numbers + 2;
    mid = (left + right) / 2;
    *cal_numbers = *cal_numbers + 2;
    mergeSort(cache, left, mid, cal_numbers);
    mergeSort(cache, mid+1, right, cal_numbers);
    merge(cache, left, right,cal_numbers);
}
