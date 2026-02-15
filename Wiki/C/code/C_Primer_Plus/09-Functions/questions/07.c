// Purpose: Is anything wrong with this function definition?
//
//     void salami(num)
//     {
//        int num, count;
//
//        for (count = 1; count <= num; num++)
//            printf("O salami mio!\n");
//     }
//
// Answer:
//    - `num` is used both in the function's header and in its body
//    - the type of `num` is not given in the function's header
//    - `num` is uninitialized
//    - `num++` should be replaced with `count++`
//
// Reference: page 379 (paper) / 408 (ebook)
