#include<termios.h>
#include<stdio.h>
int main() {
  struct termios t;
  printf ("VMIN:	equ %d\n",VMIN);
  printf ("VTIME:	equ %d\n",VTIME);
  printf ("OFFSET:	equ %d\n",(int)(((char *)&t.c_cc)-((char *)&t)));
  printf ("SIZE:	equ %d\n",sizeof(t.c_cc[0]));
}