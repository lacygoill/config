// Purpose: Here are three array declarations:
//
//     double trots[20];
//     short clops[10][30];
//     long shots[5][10][15];
//
// a. Show a  function prototype and  a function  call for a  traditional `void`
// function that processes `trots` and also for a C function using a VLA.
//
//     void process(double ar[], int n);
//     process(trots, 20);
//
//     void processvla(int n, double ar[n]);
//     processvla(20, trots);
//
// b. Show a  function prototype and  a function  call for a  traditional `void`
// function that processes `clops` and also for a C function using a VLA.
//
//     void process(short ar[][30], int n);
//     process(clops, 10);
//
//     void processvla(int n, int m, short ar[n][m]);
//     processvla(10, 30, clops);
//
// c. Show a  function prototype and  a function  call for a  traditional `void`
// function that processes `shots` and also for a C function using a VLA.
//
//     void process(long ar[][10][15], int n);
//     process(shots, 5);
//
//     void processvla(int n, int m, int p, long ar[n][m][p]);
//     processvla(5, 10, 15, shots);
//
// Reference: page 438 (paper) / 467 (ebook)
