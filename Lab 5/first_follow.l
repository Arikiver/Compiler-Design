%{
    /* Include necessary header files */
    #include <stdio.h>
    #include <string.h>
    #include <ctype.h>
    
    /* Constants for maximum limits */
    #define MAX_PROD 50    // Maximum number of productions
    #define MAX_LEN 50     // Maximum length of RHS of any production
    
    /* Structure to store a production rule of the form A->BC */
    typedef struct {
        char lhs;              // Left-hand side non-terminal
        char rhs[MAX_LEN];     // Right-hand side of production
    } Production;
    
    /* Global variables */
    Production prods[MAX_PROD];    // Array to store all productions
    int prod_count = 0;            // Counter for number of productions
    char firstSets[26][MAX_LEN];   // Array to store FIRST sets of non-terminals (A-Z)
    char followSets[26][MAX_LEN];  // Array to store FOLLOW sets of non-terminals (A-Z)
    int firstCalculated[26] = {0}; // Flags to track if FIRST set is calculated
    int followCalculated[26] = {0};// Flags to track if FOLLOW set is calculated

    /* Function declarations */
    void computeFirst(char symbol, char first[]);   // Compute FIRST set of a symbol
    void computeFollow(char symbol, char follow[]); // Compute FOLLOW set of a non-terminal
    void removeRedundant(char arr[]);              // Remove duplicate characters from a string
%}


%%
[A-Z]"->"[A-Za-z#]+    {
                            prods[prod_count].lhs = yytext[0];
                            strcpy(prods[prod_count].rhs, yytext + 3);
                            prod_count++;
                        }   /* Flex pattern matching rules: match a production rule (e.g., A->BC, S->aB), Store LHS, Store RHS (skip "->") */
\n                      ;   /* Ignore newlines */
.                       ;   /* Ignore all other characters */
%%

/* Function to remove duplicate characters from an array */
void removeRedundant(char arr[]) {
    int i, j, k;
    for(i = 0; arr[i] != '\0'; i++) {
        for(j = i + 1; arr[j] != '\0'; j++) {
            if(arr[i] == arr[j]) {  /* If duplicate found */
                /* Remove duplicate by shifting remaining characters left */
                for(k = j; arr[k] != '\0'; k++) {
                    arr[k] = arr[k + 1];
                }
                j--;  /* Adjust position after shifting */
            }
        }
    }
}

/* Function to compute FIRST set of a symbol */
void computeFirst(char symbol, char first[]) {
    /* If symbol is terminal (lowercase) or epsilon (#) */
    if(!(symbol >= 'A' && symbol <= 'Z')) {
        first[0] = symbol;
        first[1] = '\0';
        return;
    }

    /* If FIRST set already calculated, return stored result */
    if(firstCalculated[symbol - 'A']) {
        strcpy(first, firstSets[symbol - 'A']);
        return;
    }

    int firstIndex = 0;
    
    /* Check all productions where symbol is LHS */
    for(int i = 0; i < prod_count; i++) {
        if(prods[i].lhs == symbol) {
            /* If production is of form A-># */
            if(prods[i].rhs[0] == '#') {
                first[firstIndex++] = '#';
                continue;
            }

            /* Get FIRST set of first symbol in RHS */
            char tempFirst[MAX_LEN];
            computeFirst(prods[i].rhs[0], tempFirst);
            
            /* Add all non-epsilon symbols to FIRST set */
            for(int j = 0; tempFirst[j] != '\0'; j++) {
                if(tempFirst[j] != '#') {
                    first[firstIndex++] = tempFirst[j];
                }
            }
        }
    }
    
    /* Finalize the FIRST set */
    first[firstIndex] = '\0';
    removeRedundant(first);
    strcpy(firstSets[symbol - 'A'], first);
    firstCalculated[symbol - 'A'] = 1;
}

/* Function to compute FOLLOW set of a non-terminal */
void computeFollow(char symbol, char follow[]) {
    /* If FOLLOW set already calculated, return stored result */
    if(followCalculated[symbol - 'A']) {
        strcpy(follow, followSets[symbol - 'A']);
        return;
    }

    int followIndex = 0;
    
    /* For start symbol, add $ to FOLLOW set */
    if(symbol == prods[0].lhs) {
        follow[followIndex++] = '$';
    }

    /* Check all productions for symbol in RHS */
    for(int i = 0; i < prod_count; i++) {
        char *ptr = strchr(prods[i].rhs, symbol);
        while(ptr != NULL) {
            /* If symbol is not at the end of RHS */
            if(*(ptr + 1) != '\0') {
                char tempFirst[MAX_LEN];
                computeFirst(*(ptr + 1), tempFirst);
                
                /* Add all non-epsilon symbols from FIRST(next) to FOLLOW set */
                for(int j = 0; tempFirst[j] != '\0'; j++) {
                    if(tempFirst[j] != '#') {
                        follow[followIndex++] = tempFirst[j];
                    }
                }
                
                /* If FIRST(next) contains epsilon, add FOLLOW(LHS) */
                if(strchr(tempFirst, '#') != NULL) {
                    char tempFollow[MAX_LEN];
                    computeFollow(prods[i].lhs, tempFollow);
                    for(int j = 0; tempFollow[j] != '\0'; j++) {
                        follow[followIndex++] = tempFollow[j];
                    }
                }
            }
            /* If symbol is at the end of RHS, add FOLLOW(LHS) */
            else if(prods[i].lhs != symbol) {
                char tempFollow[MAX_LEN];
                computeFollow(prods[i].lhs, tempFollow);
                for(int j = 0; tempFollow[j] != '\0'; j++) {
                    follow[followIndex++] = tempFollow[j];
                }
            }
            ptr = strchr(ptr + 1, symbol);
        }
    }
    
    /* Finalize the FOLLOW set */
    follow[followIndex] = '\0';
    removeRedundant(follow);
    strcpy(followSets[symbol - 'A'], follow);
    followCalculated[symbol - 'A'] = 1;
}

/* Required for Flex */
int yywrap() {
    return 1;
}

/* Main function */
int main() {
    /* Get input file name and open it */
    printf("Enter the filename containing grammar: ");
    char filename[256];
    scanf("%s", filename);
    FILE *file = fopen(filename, "r");

    if (file == NULL) {
        printf("File not found!\n");
        return 1;
    }

    /* Process input file */
    yyin = file;  /* Set Flex input to file */
    yylex();      /* Start lexical analysis */
    fclose(file); /* Close input file */

    /* Calculate and print FIRST sets for all non-terminals */
    printf("\nFIRST Sets:\n");
    for(int i = 0; i < prod_count; i++) {
        if(!firstCalculated[prods[i].lhs - 'A']) {
            char first[MAX_LEN];
            computeFirst(prods[i].lhs, first);
            printf("FIRST(%c) = {%s}\n", prods[i].lhs, first);
        }
    }
    
    /* Reset FOLLOW calculation flags and compute FOLLOW sets */
    memset(followCalculated, 0, sizeof(followCalculated));
    printf("\nFOLLOW Sets:\n");
    for(int i = 0; i < prod_count; i++) {
        if(!followCalculated[prods[i].lhs - 'A']) {
            char follow[MAX_LEN];
            computeFollow(prods[i].lhs, follow);
            printf("FOLLOW(%c) = {%s}\n", prods[i].lhs, follow);
        }
    }
    
    return 0;
}