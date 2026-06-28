// Purpose: What is the value of `**ptr` and of `**(ptr + 1)` in each case?
//
//     a.
//     int (*ptr)[2];
//     int torf[2][2] = {12, 14, 16};
//     ptr = torf;
//
// Answer:
//
//     **ptr = **torf
//           = torf[0][0]
//           = 12
//
//     **(ptr + 1) = **(torf + 1)
//                 = **(&torf[0] + 1)
//                 = **(&torf[1])
//                 = *(torf[1])
//                 = *(&torf[1][0])
//                 = 16
//
// ---
//
//     b.
//     int (*ptr)[2];
//     int fort[2][2] = { {12}, {14,16} };
//     ptr = fort;
//
// Answer:
//
//     **ptr = **fort
//           = fort[0][0]
//           = 12
//
//     **(ptr + 1) = **(fort + 1)
//                 = **(&fort[0] + 1)
//                 = **(&fort[1])
//                 = *fort[1]
//                 = *(&fort[1][0])
//                 = fort[1][0]
//                 = 14
//
// Reference: page 437 (paper) / 466 (ebook)
