// Purpose: Write a  program that reads  input as  a stream of  characters until
// encountering EOF.   Have it report  the average  number of letters  per word.
// Don't count  whitespace as  being letters in  a word.   Actually, punctuation
// shouldn't be counted either, but don't worry about that now.  (If you do want
// to worry about it, consider using the `ispunct()` function from the `ctype.h`
// family.)
//
// Reference: page 333 (paper) / 362 (ebook)

#include <stdio.h>
#include <stdbool.h>
#include <ctype.h>

bool is_word(char ch);

    int
main(void)
{
    int ch;
    bool in_word = false;
    int n_words = 0;
    int n_chars = 0;

    while ((ch = getchar()) != EOF)
    {
        if (in_word == false && is_word((char)ch))
        {
            in_word = true;
            n_words++;
            n_chars++;
        }
        else if (in_word == true && !is_word((char)ch))
            in_word = false;
        else if (in_word == true)
            n_chars++;
    }
    printf("There are %.2f letters per word on average.\n", (float)n_chars / (float)n_words);
}

    bool
is_word(char ch)
{
    return !isspace(ch) && !ispunct(ch);
}
