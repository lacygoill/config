// Purpose: The   following  program   has   unnecessarily  complex   relational
// expressions as well as some outright errors. Simplify and correct it.
//
//     #include <stdio.h>
//     int main(void)
//     {
//       int weight, height;  // weight in lbs, height in inches
//
//       scanf("%d, weight, height);
//       if (weight < 100 && height > 64)
//          if (height >= 72)
//             printf("You are very tall for your weight.\n");
//          else if (height < 72 &&  > 64)
//             printf("You are tall for your weight.");
//       else if (weight > 300 && ! (weight <= 300)
//                && height < 48)
//          if (!(height >= 48) )
//              printf(" You are quite short for your weight.\n");
//       else
//          printf("Your weight is ideal.\n");
//
//       return 0;
//     }
//
// Reference: page 292 (paper) / 321 (ebook)

#include <stdio.h>
int main(void)
{
    int weight, height;  // weight in lbs, height in inches

    printf("Enter your weight in pounds and your height in inches: ");
    scanf("%d %d", &weight, &height);
    if (64 < weight && weight < 100)
        if (height >= 72)
            printf("You are very tall for your weight.\n");
        else
            printf("You are tall for your weight.");
    else if (weight > 300 && height < 48)
        printf(" You are quite short for your weight.\n");
    else
        printf("Your weight is ideal.\n");

    return 0;
}
