// Purpose: Given that `value` is an `int`, what output would the following loop produce?
//
//     for ( value = 36; value > 0; value /= 2)
//         printf("%3d", value);
//
// Output: 36 18  9  4  2  1
//
// What problems would there be if `value` were `double` instead of `int`?
//
// Answer: If  `value` were  `double`,  the  test would  remain  true even  when
// `value` became  less than  1.  The loop  would continue  until floating-point
// underflow yielded a value of 0.  Also, the `%3d` specifier would be the wrong
// choice.
//
// Reference: page 236 (paper) / 265 (ebook)
