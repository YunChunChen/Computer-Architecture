#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <stdexcept>
#include "Mem.h"

using namespace std;

Mem::Mem () {
	for (int i=0; i < MEMsize; i++ ) {
		for (int j=0; j < 4; j++ ) {
			mem[i][j] = 0;
		}
	}
}

int* Mem::getfromMem(const int address) { return mem[address]; }

void Mem::writetoMem(const int address,int* data) {
	if (address<256&&address>=0)
		for(int k = 0; k < 4; k++)
			mem[address][k] = data[k];
	else
		throw invalid_argument("Invalid address! Address shall be 0-255.");
}

void Mem::printMem() {
	for (int i = 0 ; i < 256 ; i++) {
		for (int j = 0 ; j < 4 ; j++) {
			cout << mem[i][j] << " ";
		}
		cout << endl;
	}
}