// Purpose: How would you test the word count program?
// What kinds of input are most likely to uncover bugs if there are any?
// Reference: page 21 (paper) / 35 (ebook)

// To test  the word count  program first try no  input.  The output  should be:
// `0`, `0`, `0` (zero characters, zero words, zero lines).
// Then try  a one-character  word.  The  output should  be: `2`, `1`,  `1` (one
// character, one word, one line).
// Then try  a two-character word.   The output should  be `3`, `1`,  `1` (three
// characters, one word, one line).
// In addition, try 2 one-character words.  The output should be `4`, `2`, `2`.
//
// The kinds of input  most likely to uncover bugs are  those that test boundary
// conditions.  Some boundaries are:
//
//    - no input
//    - no words – just newlines
//    - no words – just blanks, tabs, and newlines
//    - one word per line – no blanks and tabs
//    - word starting at the beginning of the line
//    - word starting after some blanks
