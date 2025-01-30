%{
    int characters = 0, words = 0, spaces = 0, lines = 0;
%}

%%
[ \t]           { spaces++; }       // Match spaces and tabs, increase space count
[a-zA-Z0-9]+    { words++; }        // Match words (sequences of alphanumeric characters), increase word count
\n              { lines++; }        // Match newline character, increase line count
.               { characters++; }   // Match any character (excluding newline), increase character count
%%

// Main function
int main() {
    // Open the file for reading
    printf("Enter the filename: ");
    char filename[256];
    scanf("%s", filename);
    FILE *file = fopen(filename, "r");

    if (file == NULL) {
        printf("File not found!\n");
        return 1;
    }

    yyin = file;  // Set input stream to the file
    yylex();      // Process the file

    // Print the counts
    printf("\nCharacters: %d\n", characters);
    printf("Words: %d\n", words);
    printf("Spaces: %d\n", spaces);
    printf("Lines: %d\n", lines);

    fclose(file);  // Close the file after processing
    return 0;
}

int yywrap() {
    return 1;  // End of input handling
}
