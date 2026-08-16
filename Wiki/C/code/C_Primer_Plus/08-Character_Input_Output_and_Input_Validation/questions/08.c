// Purpose: What potential  problem do you  face when intermixing  numeric input
// with character input on a buffered system?
//
// Answer: Numeric input  skips over  spaces and  newlines, but  character input
// does not.  Suppose you have code like this:
//
//     int score;
//     char grade;
//     printf("Enter the score.\n");
//     scanf("%s", &score);
//     printf("Enter the letter grade.\n");
//     grade = getchar();
//
// If you enter 98 for the score and  then press the Enter key to send the score
// to the  program, you also  sent a newline  character, which becomes  the next
// input character and is read into `grade`  as the grade value.  If you precede
// character input  with numeric input,  you should add  code to dispose  of the
// newline character before the character input takes place.
//
// Reference: page 332 (paper) / 361 (ebook)
