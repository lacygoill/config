// Purpose: reads in strings and sorts them
// GCC Options: -Wno-strict-overflow
// Reference: page 491 (paper) / 520 (ebook)

#include <stdio.h>
#include <string.h>
#define SIZE 81    // string length limit, including `\0`
#define LIM 20     // maximum number of lines to be read
void sort_strings(char *strings[], int num);    // string-sort function
char * s_gets(char * st, int n);

    int
main(void)
{
    // `input` is NOT an array of pointers — it's a 2D array of characters (an
    // array of arrays).   When you use `input[ct]` in an  expression, it decays
    // to a pointer to its `ct`-th character, but `input` itself is not an array
    // of pointers.
    char input[LIM][SIZE];    // array to store input
    char *ptstr[LIM];         // array of pointer variables
    int ct = 0;               // input count
    int k;                    // output count

    printf("Input up to %d lines, and I will sort them.\n", LIM);
    printf("To stop, press the Enter key at a line's start.\n");
    while (ct < LIM
            && s_gets(input[ct], SIZE) != NULL
            && input[ct][0] != '\0')
    {
        ptstr[ct] = input[ct];    // set pointers to strings
        ct++;
    }
    sort_strings(ptstr, ct);    // string sorter
    puts("\nHere's the sorted list:\n");
    for (k = 0; k < ct; k++)
        puts(ptstr[k]);    // sorted pointers

    return 0;
}

    void
sort_strings(char *strings[], int num)
{
    char *temp;
    int top, seek;

    // This is a selection sort.{{{
    //
    // The goal of the first iteration of  the outer loop is to find the correct
    // first  element.   The  second  iteration must  find  the  correct  second
    // element, and so on.  Each of these  tasks is performed by the inner loop,
    // by comparing  the current element (the  one we want to  correctly set) to
    // all the subsequent elements.
    //
    // ---
    //
    // Let's say you input these 4 strings:
    //
    //     ptstr[0] → "dog"
    //     ptstr[1] → "cat"
    //     ptstr[2] → "apple"
    //     ptstr[3] → "zebra"
    //
    // First pass (`top` = 0):
    //
    //    - seek = 1: Compare "dog" with "cat"
    //       * `strcmp("dog", "cat")` returns positive (d > c alphabetically)
    //       * Swap! Now: `ptstr[0]` → "cat", `ptstr[1]` → "dog"
    //
    //    - seek = 2: Compare "cat" with "apple"
    //       * `strcmp("cat", "apple")` returns positive (c > a)
    //       * Swap! Now: `ptstr[0]` → "apple", `ptstr[2]` → "cat"
    //
    //    - seek = 3: Compare "apple" with "zebra"
    //       * `strcmp("apple", "zebra")` returns negative (a < z)
    //       * No swap
    //
    // After first pass: "apple", "dog", "cat", "zebra"
    //
    // Second pass (`top` = 1):
    //
    //    - seek = 2: Compare "dog" with "cat"
    //       * `strcmp("dog", "cat")` returns positive
    //       * Swap! Now: `ptstr[1]` → "cat", `ptstr[2]` → "dog"
    //
    //    - seek = 3: Compare "cat" with "zebra"
    //       * No swap
    //
    // After second pass: "apple", "cat", "dog", "zebra".
    //
    // Third pass (`top` = 2):
    //
    //    - seek = 3: Compare "dog" with "zebra"
    //       * No swap
    //
    // Final result: "apple", "cat", "dog", "zebra" ✓
    //}}}
    for (top = 0; top < num - 1; top++)
        for (seek = top + 1; seek < num; seek++)
            if (strcmp(strings[top], strings[seek]) > 0)
            {
                temp = strings[top];
                strings[top] = strings[seek];
                strings[seek] = temp;
            }
}

    char *
s_gets(char * st, int n)
{
    char * ret_val;
    int i = 0;
    ret_val = fgets(st, n, stdin);
    if (ret_val)
    {
        while (st[i] != '\n' && st[i] != '\0')
            i++;
        if (st[i] == '\n')
            st[i] = '\0';
        else
            while (getchar())
                continue;
    }
    return ret_val;
}

//     Input up to 20 lines, and I will sort them.
//     To stop, press the Enter key at a line's start.
//     O that I was where I would be,
//     Then would I be where I am not,
//     But where I am I must be,
//     And where I would be I can not.
//
//     Here's the sorted list:
//
//     And where I would be I can not.
//     But where I am I must be,
//     O that I was where I would be,
//     Then would I be where I am not,
