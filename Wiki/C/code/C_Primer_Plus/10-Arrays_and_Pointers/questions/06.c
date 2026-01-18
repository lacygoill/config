// Purpose: Suppose you have the following declaration:
//
//     int grid[30][100];
//
//     a. express the address of grid[22][56] one way.
//     &grid[22][56]
//
//     b. express the address of grid[22][0] two ways.
//     &grid[22][0]
//     grid[22]
//
//     c. express the address of grid[0][0] three ways.
//     &grid[0][0]
//     grid[0]
//     (int *)grid
//
// Reference: page 437 (paper) / 466 (ebook)

#include <stdio.h>

    int
main(void)
{
    int grid[30][100];
    printf("%p\n", (void *)grid);
}
