// Purpose: Write a  program that  requests the download  speed in  megabits per
// second (Mbs) and  the size of a  file in megabytes (MB).   The program should
// calculate the download time for the file.  Note that in this context one byte
// is eight  bits.  Use  type `float`,  and use `/`  for division.   The program
// should  report all  three values  (download speed,  file sizee,  and download
// time)  showing two  digits to  the  right of  the  decimal point,  as in  the
// following:
//
//     At 18.12 megabits per second, a file of 2.20 megabytes
//     downloads in 0.97 seconds.
//
// Reference: page 141 (paper) / 170 (ebook)

#include <stdio.h>

    int
main(void)
{
    float speed, size, dl_time;

    printf("Enter your download speed in Mbs and your file size in MB: ");
    scanf("%f%f", &speed, &size);

    dl_time = size * 8 / speed;

    printf("At %.2f megabits per second, a file of %.2f megabytes\n"
           "downloads in %.2f seconds.\n", speed, size, dl_time);

    return 0;
}
