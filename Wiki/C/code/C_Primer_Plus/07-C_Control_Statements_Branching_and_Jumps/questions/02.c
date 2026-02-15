// Purpose: Construct an expression to express the following conditions:
//
//     a. `number` is equal to or greater than 90 but smaller than 100.
//     number >= 90 && number < 100
//
//     b. `ch` is not a `q` or `k` character.
//     ch != 'q' && ch != 'k'
//
//     c. `number` is between 1 and 9 (including the end values) but is not a 5.
//     1 <= number && number <=9 && number != 5
//
//     d. `number` is not between 1 and 9.
//     !(1 <= number && number <= 9)
//
// Reference: page 292 (paper) / 321 (ebook)
