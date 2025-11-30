// Purpose: Write a program to "fold" long  input lines into two or more shorter
// lines after the last nonblank character  that occurs before the `n`-th column
// of input.  Make  sure your program does something intelligent  with very long
// lines, and if there are no blanks or tabs before the specified column.
//
// GCC Options: -Wno-strict-overflow
//
// Reference: page 34 (paper) / 48 (ebook)

#include <stdio.h>

#define MAXCOL 40
#define TABINC 8

char line[MAXCOL];

int expand_tab(int pos);
int find_space(int pos);
int start_new_line(int pos);
void putline(int pos);

// fold long input lines into two or more shorter lines
    int
main(void)
{
    int c, pos;

    pos = 0;  // position in the line
    while ((c = getchar()) != EOF)
    {
        line[pos] = (char)c;  // store current character
        if (c == '\t')  // expand tab character
            pos = expand_tab(pos);
        else if (c == '\n')
        {
            putline(pos);  // print current input line
            pos = 0;
        }
        else if (++pos >= MAXCOL)
        {
            pos = find_space(pos);
            putline(pos);
            pos = start_new_line(pos);
        }
    }
    return 0;
}

    void
putline(int pos)
{
    int i;
    for (i = 0; i < pos; ++i)
        putchar(line[i]);
    putchar('\n');
}

// expand tab into spaces
    int
expand_tab(int pos)
{
    line[pos] = ' ';  // tab is at least one space
    for (++pos; pos < MAXCOL && pos % TABINC != 0; ++pos)
        line[pos] = ' ';

    if (pos < MAXCOL)  // room left in current line
        return pos;

    // current line is full
    putline(pos);
    return 0;  // reset current position
}

    int
find_space(int pos)
{
    while (pos > 0 && (line[pos] != ' ' || pos == MAXCOL))
        --pos;

    if (pos == 0)  // no spaces in the line?
        return MAXCOL;

    // at least one space
    return pos + 1;  // position after the space
}

    int
start_new_line(int pos)
{
    int i, j;

    if (pos <= 0 || pos >= MAXCOL)
        return 0;  // nothing to rearrange
    i = 0;
    for (j = pos; j < MAXCOL; ++j)
    {
        line[i] = line[j];
        ++i;
    }
    return i;  // new position in line
}
