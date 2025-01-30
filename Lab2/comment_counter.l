%{
    int single_line_comments = 0;    // Count of single-line comments
    int multi_line_comments = 0;     // Count of lines in multi-line comments
    int in_comment = 0;              // Flag to track if we're inside a multi-line comment
    int comment_line_start = 0;      // Flag to track if current line started a multi-line comment
%}

%x MULTI_COMMENT

%%
"//".*          { single_line_comments++; }  // Count single-line comments

"/*"            { 
                  BEGIN(MULTI_COMMENT);      // Enter multi-line comment state
                  in_comment = 1;
                  comment_line_start = 1;
                  multi_line_comments++;     // Count first line of multi-line comment
                }

<MULTI_COMMENT>{
    \n          {
                  if (!comment_line_start) { // Don't double-count the start line
                      multi_line_comments++;
                  }
                  comment_line_start = 0;    // Reset the start line flag
                }
    
    "*/"        {
                  BEGIN(INITIAL);            // Return to normal state
                  in_comment = 0;
                  comment_line_start = 0;
                }
    
    .           ;                           // Ignore other characters in comments
}

\n              ;                           // Ignore newlines outside comments
.               ;                           // Ignore all other characters

%%

int main() {
    printf("Enter the filename: ");
    char filename[256];
    scanf("%s", filename);
    
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        printf("File not found!\n");
        return 1;
    }

    yyin = file;
    yylex();
    
    printf("\nComment Statistics:\n");
    printf("Single-line comments: %d\n", single_line_comments);
    printf("Multi-line comment lines: %d\n", multi_line_comments);
    printf("Total comment lines: %d\n", single_line_comments + multi_line_comments);
    
    fclose(file);
    return 0;
}

int yywrap() {
    return 1;
}
