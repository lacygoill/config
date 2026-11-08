// Purpose: constants and declarations for 09.c and 10.c
// Reference: page 365 (paper) / 394 (ebook)

#define QUIT 5
#define HOTEL1 180.00
#define HOTEL2 225.00
#define HOTEL3 255.00
#define HOTEL4 355.00
#define DISCOUNT 0.95
#define STARS "**********************************"

// shows list of choices
int menu(void);

// returns number of nights desired
int getnights(void);

// calculates prices from rate, nights
// and display result
void showprice(double rate, int nights);
