%{ 
#include <stdio.h> 
#include <stdlib.h> 
#include <math.h> 
// Function prototype for error handling 
void yyerror(const char *s); 
int yylex(void); 
%} 
%union { 
double num;  // For numerical values 
} 
// Declare tokens and their associated types 
%token <num> NUMBER 
// Associate non-terminal symbols with a data type 
%type <num> expr 
%left '+' '-' 
%left '*' '/' 
%% 
// Grammar rules and actions 
input: 
/* empty */ 
| input line 
   ; 
line: 
    expr '\n' { printf("Result: %lf\n", $1); } 
    ; 
expr: 
    expr '+' expr { $$ = $1 + $3; } 
    | expr '-' expr { $$ = $1 - $3; } 
    | expr '*' expr { $$ = $1 * $3; } 
    | expr '/' expr {  
        if ($3 == 0) { 
            yyerror("Division by zero"); 
            $$ = 0; 
        } else { 
            $$ = $1 / $3; 
        } 
    } 
    | '(' expr ')' { $$ = $2; } 
    | NUMBER { $$ = $1; } 
    ; 
%% 
void yyerror(const char *s) { 
    fprintf(stderr, "Error: %s\n", s); 
} 
 
int main() { 
    printf("Enter an expression (e.g., 3 + 4 * 2):\n"); 
    return yyparse(); 
}