#include <iostream>
#include <iomanip>
#include <stdio.h>
#include <stdlib.h>
#include <algorithm>
#include <stdexcept>
#include "Mem.h"
#include "L1cache.h"

using namespace std;

#define max 200

void quicksort(L1cache *, int, int, int *);
void swap(L1cache *, int *, int *,int, int, int *);

int main(void) {
    int cal_numbers = 0;
    int error_counter = 0;
    int way_number = 8; //direct map: 1, 2-way: 2, 4-way: 4, fully associative: 8
    int orig_list[max] = {8,171,145,34,98,91,42,52,157,172,45,195,
                          77,143,104,122,183,155,81,141,196,162,71,
                          24,197,161,148,119,151,131,188,72,166,109,
                          35,48,60,189,90,138,73,50,74,125,105,88,
                          120,135,51,47,147,49,69,65,126,39,139,15,
                          142,22,64,54,114,179,169,94,154,156,137,93,
                          149,107,153,95,124,185,168,102,121,44,182,
                          89,115,68,144,59,103,150,116,96,129,13,37,
                          191,46,61,16,57,158,87,123,175,12,165,58,55,
                          111,190,40,181,100,1,134,66,76,18,33,31,4,
                          21,136,174,186,10,43,75,25,41,160,53,67,97,
                          26,106,23,173,128,200,180,56,3,112,177,79,
                          176,27,194,133,80,20,187,132,170,159,117,30,
                          163,184,178,86,198,193,14,5,118,167,99,38,19,
                          62,101,85,82,36,9,63,6,192,28,140,146,108,17,
                          164,127,130,32,2,78,83,92,199,70,29,84,110,
                          7,11,152,113};

    Mem mem;
    L1cache cache(&mem,way_number);

    int i;
    int n = max;
    int data[4];

    for (i = 0 ; i < n ; i++) {   
        data[i%4] = orig_list[i];
        if (i%4==3)
            mem.writetoMem(i/4,data);
    }
    int data_print;
    printf("\nBefore Sorting: \n");
    for (i = 0; i < n; i++) {
        data_print = cache.getfromCache(i);
        printf("%d ", data_print);
        if (data_print != orig_list[i]) {
            cout << "Error occurs at address " << i << " original data " << orig_list[i] << " your data " << data_print << " not equal" << endl;
            error_counter ++ ;
        }
    }

    printf("\n\n");
    quicksort(&cache, 0, n - 1, &cal_numbers);
    sort(orig_list,orig_list+max);

    printf("\nAfter Sorting: \n");
    for (i = 0 ; i < n ; i++) {
        data_print = cache.getfromCache(i);
        printf("%d ", data_print);
        if (data_print != orig_list[i]){
            cout << "Error occurs at address " << i << " original data " << orig_list[i] << " your data " << data_print <<" not equal" << endl;
            error_counter ++ ;
        }
    }

    cout << "\n\n";

    if (way_number == 1)
        cout << "way_number = 1 Direct map" << endl;
    else if (way_number == 2)
        cout << "way_number = 2 2-way" << endl;
    else if (way_number == 4)
        cout << "way_number = 4 4-way" << endl;
    else 
	    cout << "way_number = 8 Fully associative" << endl;

    double rate = double(cache.getHit())/double(cache.getHit()+cache.getMiss())*100;
    cout << endl << "Hit rate: " << setprecision(4) << rate << "%" << endl << endl;

    if (error_counter == 0)
        cout << "Well done!! You have passed test bench 2!" << endl;
    else
        cout << "Error!! You have " << error_counter << " errors, please check again!" << endl;

    cout << "Total hit: " << cache.getHit() << endl;
    cout << "Total miss: " << cache.getMiss() << endl;
}

void quicksort(L1cache *cache, int left, int right, int *cal_numbers) {
    int pivot, i, j;

    if (left >= right) { 
        *cal_numbers = *cal_numbers + 2;
        return; 
    }

    pivot = cache->getfromCache(left);

    i = left + 1;
    *cal_numbers = *cal_numbers + 2;
    j = right;
    *cal_numbers = *cal_numbers + 1;

    do {   
        *cal_numbers = *cal_numbers + 2;
        int temp3;
        int left_value, right_value;
        left_value = cache->getfromCache(i);
        *cal_numbers = *cal_numbers + 2;
        while (i <= right && left_value <= pivot) {
            *cal_numbers = *cal_numbers + 4;
            i = i + 1;
            *cal_numbers = *cal_numbers + 1;
            left_value = cache->getfromCache(i);
        }
        right_value = cache->getfromCache(j);
        *cal_numbers = *cal_numbers + 2;
        while (j > left && right_value > pivot) {
            *cal_numbers = *cal_numbers + 4;
            j = j - 1;
            *cal_numbers = *cal_numbers + 1;
            right_value = cache->getfromCache(j);
        }
        if (i < j) {
            *cal_numbers = *cal_numbers + 2;
            swap(cache, &i, &j, left_value, right_value, cal_numbers);
        }
    } while(i < j);

    swap(cache, &left, &j, pivot, cache->getfromCache(j), cal_numbers);

    quicksort(cache, left, j - 1,cal_numbers);
    quicksort(cache, j + 1, right,cal_numbers);
}

void swap(L1cache *cache, int *a, int *b, int left_value, int right_value, int *cal_numbers) {
    cache->writetoCache(*a,right_value);
    cache->writetoCache(*b,left_value);
    *cal_numbers = *cal_numbers + 1;
}
