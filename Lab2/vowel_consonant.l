%{
    int vowels = 0, consonants = 0; // Global counters
%}

%%
[aeiouAEIOU]    { vowels++; }       // Match vowels
[a-zA-Z]        { consonants++; }   // Match consonants
[ \t]           ;                   // Ignore spaces and tabs
\n\n            { return 0; }       // Match newline and stop processing after one line
.|\n            ;                   // Match any other character
%%

// User Code Section
int main() {
    printf("Enter a string: ");
    yyin = stdin; // Set input stream to standard input
    yylex();      // Process the input
    printf("\nVowels: %d\n", vowels);
    printf("Consonants: %d\n", consonants);
    return 0;
}

int yywrap() {
    return 1; // Indicates end of input
}
