%{ 
#include <stdio.h> 
#include <ctype.h> // for isspace 
int chars = 0, words = 0, spaces = 0, lines = 0; 
int yywrap(void) { return 1; } 
%}

%%
[ \t] { spaces++; chars++; }
\n { lines++; chars++; }
[^\t\n ]+ { words++; chars += yyleng; }
%%

int main() {
    printf("Enter text (Ctrl+D to end):\n"); 
    yylex(); 
    printf("Characters: %d\n", chars); 
    printf("Words: %d\n", words); 
    printf("Spaces: %d\n", spaces); 
    printf("Lines: %d\n", lines); 
    return 0; 
}