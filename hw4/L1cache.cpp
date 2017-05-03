#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "L1cache.h"
#include "Mem.h"

using namespace std;

L1cache::L1cache (Mem* memory,int way = 1) {
    L1readhit = 0;
    L1readmiss = 0;
    L1writehit = 0;
    L1writemiss = 0;
    mem = memory;
    way_number = way;
    for(int i=0; i < L1size; i++)
        for (int j=0; j < 4; j++)
            cache[i][j] = 0;
}

int L1cache::getfromCache(const int address) {
    int row = 0;
    int col = address % 4 + 4;
    int tag = address / 4;
    if (way_number == 1)
        row = (address / 4) % 8;
    else if (way_number == 2)
        row = 2*((address / 8) % 4);
    else if (way_number == 4)
        row = (address / 16) % 2;
    for (int i = 0 ; i < way_number ; i++) {
        if (cache[row+i][0] == 1 && cache[row+i][3] == tag) {
            L1readhit += 1; // a read hit happens
            cache[row+i][2] = way_number; // set release bit to way_number
            for (int j = 0 ; j < way_number ; j++)
                if (j != i)
                    if (cache[row+j][2] > 0)
                        cache[row+j][2] -= 1; // decrement release bit by 1
            return cache[row+i][col];
        }
    }
    L1readmiss += 1; // a read miss happens
    int _row = row;
    int index;
    for (int i = 0 ; i < way_number ; i++)
        if (cache[_row][2] >= cache[row+i][2]) {
            _row = row+i;
            index = i;
        }
    if (cache[_row][1] == 1) // dirty bit is 1, write back to memory
        mem->writetoMem(cache[_row][3], cache[_row]+4);
    int* pointer = mem->getfromMem(tag); // get from memory
    for (int i = 0 ; i < 4 ; i++)
        cache[_row][i+4] = pointer[i];
    cache[_row][0] = 1; // set valid bit to 1
    cache[_row][1] = 0; // set dirty bit to 0
    cache[_row][2] = way_number; // set release bit to way_number
    cache[_row][3] = tag; // update tag
    for (int i = 0 ; i < way_number ; i++)
        if (i != index)
            if (cache[row+i][2] > 0)
                cache[row+i][2] -= 1; // decrement release bit by 1
    return cache[_row][col];
}

void L1cache::writetoCache(const int address,const int indata) {
    int row = 0;
    int col = address % 4 + 4;
    int tag = address / 4;
    if (way_number == 1)
        row = (address / 4) % 8;
    else if (way_number == 2)
        row = 2*((address / 8) % 4);
    else if (way_number == 4)
        row = (address / 16) % 2;
    for (int i = 0 ; i < way_number ; i++) {
        if (cache[row+i][0] == 1 && cache[row+i][3] == tag) {
            L1writehit += 1; // a write hit happens
            cache[row+i][1] = 1; // set dirty bit to 1
            cache[row+i][2] = way_number; // set release bit to way_number
            cache[row+i][col] = indata; // write in the data
            for (int j = 0 ; j < way_number ; j++)
                if (j != i)
                    if (cache[row+j][2] > 0)
                        cache[row+j][2] -= 1; // decrement release bit by 1
            return;
        }
    }
    L1writemiss += 1; // a write miss happens
    int _row = row;
    int index;
    for (int i = 0 ; i < way_number ; i++)
        if (cache[_row][2] >= cache[row+i][2]) {
            _row = row+i;
            index = i;
        }
    if (cache[_row][1] == 1) // dirty bit is 1, write back to memory
        mem->writetoMem(cache[_row][3], cache[_row]+4);
    int* pointer = mem->getfromMem(tag); // get from memory
    for (int j = 0 ; j < 4 ; j++)
        cache[_row][j+4] = pointer[j];
    cache[_row][0] = 1; // set valid bit to 1
    cache[_row][1] = 1; // set dirty bit to 1
    cache[_row][2] = way_number; // set release bit to way_number
    cache[_row][3] = tag; // update tag
    cache[_row][col] = indata; // write in the data
    for (int i = 0 ; i < way_number ; i++)
        if (i != index)
            if (cache[row+i][2] > 0)
                cache[row+i][2] -= 1; // decrement release bit by 1
}

int L1cache::getReadHit() { return L1readhit; }
int L1cache::getReadMiss() { return L1readmiss; }
int L1cache::getWriteHit() { return L1writehit; }
int L1cache::getWriteMiss() { return L1writemiss; }
int L1cache::getHit() { return L1readhit + L1writehit; }
int L1cache::getMiss() { return L1readmiss + L1writemiss; }
