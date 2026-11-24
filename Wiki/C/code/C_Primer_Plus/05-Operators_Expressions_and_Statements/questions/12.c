// Purpose: Construct statements that do the following (or, in other terms, have
// the following side effects):
//
//     a. Increase the variable x by 10.
//     x = x + 10; or x += 10
//
//     b. Increase the variable x by 1.
//     x++; or ++x; or x = x + 1;
//
//     b. Assign twice the sum of a and b to c.
//     c = 2 * (a + b);
//
//     d. Assign a plus twice b to c.
//     c = a + 2 * b;
//
// Reference: page 186 (paper) / 215 (ebook)
