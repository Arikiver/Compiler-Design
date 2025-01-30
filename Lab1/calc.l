%{
#include "calc.tab.h" // Include Bison header file
%}
%%
[0-9]+(\.[0-9]+)? {
 yylval.num = atof(yytext); // Convert matched text to a double
 return NUMBER;
}
[ \t] ; // Ignore whitespace
\n return '\n'; // Newline character
. return yytext[0]; // Return any other character
%%
int yywrap(void) {
 return 1;
}