// Purpose: What is the value of `*ptr` and of `*(ptr + 2)` in each case?
//
//     a.
//     int *ptr;
//     int torf[2][2] = {12, 14, 16};
//     ptr = torf[0];
//
// Answer:
//
//     *ptr = *(torf[0])
//          = *(&torf[0][0])
//          = torf[0][0]
//          = 12
//
//     *(ptr + 2) = *(torf[0] + 2)
//                = *(&torf[0][0] + 2)
//                = *(&torf[1][0])
//                = 16
//
// ---
//
//     b.
//     int * ptr;
//     int fort[2][2] = {{12}, {14, 16}}
//     ptr = fort[0];
//
// Answer:
//
//     *ptr = *(fort[0])
//          = *(&fort[0][0])
//          = fort[0][0]
//          = 12
//
//     *(ptr + 2) = *(fort[0] + 2)
//                = *(&fort[0][0] + 2)
//                = fort[1][0]
//                = 14
//
// Reference: page 436 (paper) / 465 (ebook)
