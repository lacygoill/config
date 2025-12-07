// Purpose: Would   the   `upc.c`  program   still   work   if  the   expression
// `9 - ((total - 1) % 10)` were replaced by `(10 - (total % 10)) % 10`?
// Reference: page 69 (paper) / 94 (ebook)

// Yes.  Both expressions are equivalent.
//
// Proof: Let's call `r` the remainder of `total % 10`.
//
// It means there exists an integer `k` such as:
//
//     total = 10k + r
//
// ---
//
// Now, let's consider the case where `r = 0`:
//
//     9 - ((total - 1) % 10) = 9 - ((10k - 1) % 10)
//                            = 9 - ((10k - 1 + 10) % 10)
//                            = 9 - ((10k + 9) % 10))
//                            = 9 - 9
//                            = 0
//                              ^
//
//     (10 - (total % 10)) % 10 = (10 - (10k % 10)) % 10
//                              = (10 - 0) % 10
//                              = 0
//                                ^
//
// Both expressions are equal.
//
// ---
//
// Next, let's consider the case where `r >= 1`:
//
//     9 - ((total - 1) % 10) = 9 - ((10k + r - 1) % 10)
//                            = 9 - (r - 1)
//                            = 10 - r
//                              ^----^
//
//     (10 - (total % 10)) % 10 = (10 - ((10k + r) % 10)) % 10
//                              = (10 - r) % 10
//                              = 10 - r
//                                ^----^
//
// Again, both expressions are equal.
