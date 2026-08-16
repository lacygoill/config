// Purpose: Given the following output:
//
//     Please choose one of the following:
//     1) copy files            2) move files
//     3) remove files          4) quit
//     Enter the number of your choice:
//
//     a. Write a function that displays a menu of four numbered choices and
//     asks you to choose one. (The output should look like the preceding.)
//
//     b. Write a function  that has two int  arguments: a lower limit  and an upper
//     limit.  The  function should read an  integer from input.  If  the integer is
//     outside  the limits,  the  function  should print  a  menu  again (using  the
//     function from  part “a” of this  question) to reprompt the  user and then
//     get  a new  value.  When  an integer  in the  proper limits  is entered,  the
//     function  should return  that  value  to the  calling  function.  Entering  a
//     noninteger should cause the function to return the quit value of 4.
//
//     c. Write a minimal program using the functions from parts “a” and “b”
//     of this question. By  minimal, we mean it need not  actually perform the actions
//     promised by the menu; it should just show the choices and get a valid response.
//
// Reference: page 379 (paper) / 408 (ebook)

#include <stdio.h>
#define QUIT 4
#define LOWER 1
#define UPPER 4

void showmenu(void);
int getchoice(int lower, int upper);

    int
main(void)
{
    int res;

    showmenu();
    while ((res = getchoice(LOWER, UPPER)) != QUIT)
    {
        printf("\nI like choice %d.\n\n", res);
        showmenu();
    }
    printf("Bye!\n");
    return 0;
}

    void
showmenu(void)
{
    printf("%s", "Please choose one of the following:\n");
    printf("%s", "1) copy files            2) move files\n");
    printf("%s", "3) remove files          4) quit\n");
    printf("%s", "Enter the number of your choice: ");
}

    int
getchoice(int lower, int upper)
{
    int choice;
    int status;
    status = scanf("%d", &choice);
    while (status == 1 && (choice > upper || choice < lower))
    {
        printf("\nPlease enter a number between %d and %d.\n\n", lower, upper);
        showmenu();
        status = scanf("%d", &choice);
    }
    if (status != 1)
    {
        printf("Non numeric input.\n");
        choice = QUIT;
    }
    return choice;
}
