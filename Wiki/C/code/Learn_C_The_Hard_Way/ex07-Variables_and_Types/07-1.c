// Purpose: Variables and Types
// Reference: page 54

#include <stdio.h>

    int
main(void)
{
    int distance = 100;
    float power = 2.345f;
    double super_power = 56789.4532;
    char initial = 'A';
    char first_name[] = "Zed";
    char last_name[] = "Shaw";

    printf("You are %d miles away.\n", distance);
    //              ^^
    //              convert int argument to signed decimal notation
    printf("You have %f levels of power.\n", power);
    //               ^^
    //               convert double argument to signed decimal notation
    printf("You have %f awesome super powers.\n", super_power);
    printf("I have an initial %c.\n", initial);
    //                        ^^
    //                        convert int argument to unsigned char and write resulting character
    printf("I have a first name %s.\n", first_name);
    //                          ^^
    //                          write characters from pointer to string up to NUL
    printf("I have a last name %s.\n", last_name);
    printf("My whole name is %s %c. %s.\n", first_name, initial, last_name);

    int bugs = 100;
    double bug_rate = 1.2;

    printf("You have %d bugs at the imaginary rate of %f.\n", bugs, bug_rate);

    // short for `long signed int`
    // v
    long universe_of_defects = 1L * 1024L * 1024L * 1024L;
    //                          ^       ^       ^       ^
    //                          long numbers
    printf("The entire universe has %ld bugs.\n", universe_of_defects);
    //                               ^^
    //                               format specifier for long numbers

    // C has a promotion system that  converts values to different types.  Here,
    // `bugs` –  which is an  `int` – is promoted  to a `double`  because it
    // appears  in an  arithmetic  expression where  one of  the  operands is  a
    // `double`.
    double expected_bugs = bugs * bug_rate;
    printf("You are expected to have %f bugs.\n", expected_bugs);

    double part_of_universe = expected_bugs / (double)universe_of_defects;
    printf("That is only a %e portion of the universe.\n", part_of_universe);
    //                     ^^
    //                     the value is small enough that it's easier to read in scientific notation

    // this makes no sense, just a demo of something weird:
    // `'\0'` is 0, and a `char` is just a small integer, thus can appear inside
    // an arithmetic expression
    char nul_byte = '\0';
    int care_percentage = bugs * nul_byte;
    printf("Which means you should care %d%%.\n", care_percentage);
    //                                    ^^
    //                                    to write a single percent, we need to double it inside the format

    return 0;
}
