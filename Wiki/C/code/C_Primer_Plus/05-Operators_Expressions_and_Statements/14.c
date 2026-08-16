// Purpose: automatic type conversions
// GCC Options: -w
// Reference: page 175 (paper) / 204 (ebook)

#include <stdio.h>

    int
main(void)
{
    char ch;
    int i;
    float fl;

    // The character 'C' is stored as a 1-byte ASCII value in `ch`.  The integer
    // variable `i` receives  the integer conversion of 'C', which  is 67 stored
    // as 4 bytes.  Finally, `fl` receives  the floating conversion of 67, which
    // is 67.00.
    fl = i = ch = 'C';
    printf("ch = %c, i = %d, fl = %2.2f\n", ch, i, fl);

    // The character variable 'C' is converted  to the integer 67, which is then
    // added to the 1.   The resulting 4-byte integer 68 is  truncated to 1 byte
    // and  stored in  `ch`.   When  printed using  the  `%c`  specifier, 68  is
    // interpreted as the ASCII code for 'D'.
    ch = ch + 1;

    // The  value  of  `ch` is  converted  to  a  4-byte  integer (68)  for  the
    // multiplication  by  2.   The  resulting integer  (136)  is  converted  to
    // floating point  in order to  be added to  `fl`.  The result  (203.00f) is
    // converted to `int` and stored in `i`.
    i = fl + 2 * ch;

    // The  value of  `ch`  ('D', or  68)  is converted  to  floating point  for
    // multiplication by 2.0.   The value of `i` (203) is  converted to floating
    // point for the addition, and the result (339.00) is stored in `fl`.
    fl = 2.0 * ch + i;

    printf("ch = %c, i = %d, fl = %2.2f\n", ch, i, fl);

    // Here  the example  tries a  case of  demotion, setting  `ch` equal  to an
    // out-of-range number.   After the  extra bits are  ignored, `ch`  winds up
    // with  the ASCII  code  for  the 'S'  character.   Or, more  specifically,
    // `1107 % 256` is 83, the code for 'S'.
    ch = 1107;

    printf("Now ch = %c\n", ch);

    // Here the example tries another case  of demotion, setting `ch` equal to a
    // floating point number.  After truncation  takes place, `ch` winds up with
    // the ASCII code for the 'P' character
    ch = 80.89;

    printf("Now ch = %c\n", ch);

    //     ch = C, i = 67, fl = 67.00
    //     ch = D, i = 203, fl = 339.00
    //     Now ch = S
    //     Now ch = P

    return 0;
}
