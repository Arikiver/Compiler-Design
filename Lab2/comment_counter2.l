%{
#include <stdio.h>
int comment_lines = 0;
int yywrap(void) { return 1; }
%}

%%
\/\/.*                      { comment_lines++; }    // Single-line comment
\/\*([^*]|\*+[^\/])*\*+\/   { comment_lines++; }    // Multi-line comment
.|\n                        ;                       // Ignore other lines
%%

int main() {
    printf("Enter the C program code (Ctrl+D to end):\n");
    yylex();
    printf("Number of comment lines: %d\n", comment_lines);
    return 0;
}