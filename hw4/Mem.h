#ifndef MEM_H
#define MEM_H

#define MEMsize  256

class Mem {

private:
	int mem[MEMsize][4];

public:
	Mem ();
	int* getfromMem(const int);
	void writetoMem(const int,int*);
	void printMem();
};

#endif