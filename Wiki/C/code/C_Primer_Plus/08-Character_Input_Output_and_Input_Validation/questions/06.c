// Purpose: What  is the  output  of each  of the  following  fragments for  the
// indicated  input (assume  that  `ch` is  type  `int` and  that  the input  is
// buffered)?
//
//     a. The input is as follows:
//     If you quit, I will.[enter]
//
//     The fragment is as follows:
//     while ((ch = getchar()) != 'i')
//         putchar(ch);
//
//     The output is:
//     If you qu
//
//     b. The input is as follows:
//     Harhar[enter]
//     The fragment is as follows:
//     while ((ch = getchar() != '\n')
//     {
//         putchar(ch++);
//         putchar(++ch);
//     }
//
//     The output is: HJacrthjacrt
//
// Reference: page 332 (paper) / 361 (ebook)
