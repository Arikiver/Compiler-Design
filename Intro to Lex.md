# Lex Programming Guide

## Overview

Lex is a powerful tool for lexical analysis that allows you to define patterns (regular expressions) and execute specific code for each pattern match.

## Program Structure

A Lex program consists of three main sections:

1. Definition Section: For variable declarations and header includes
2. Rules Section: For pattern and action definitions
3. User Code Section: For supporting code like main()

Basic structure:
```
Definitions Section
%%
Rules Section
%%
User Code Section
```

## 1. Definitions Section

### Variable Declarations
Must be enclosed in `%{` and `%}`:
```c
%{
int count = 0;
#include <stdio.h>
%}
```

### Pattern Definitions
Format: `name pattern`
```
DIGIT    [0-9]
LETTER   [a-zA-Z]
```

### Start States
Format: `%x statename`
```
%x COMMENT
%x STRING
```

## 2. Rules Section

### Basic Rule Format
```
pattern { action }
```
Example:
```c
[0-9]+  { printf("Found number: %s\n", yytext); }
```

### Pattern Writing Guide

#### Special Characters
`.` `*` `+` `?` `[` `]` `^` `$` `(` `)` `{` `}` `|` `\` `/` `"`
- Must be escaped with `\` to match literally

#### Common Patterns
- `.` : Any character except newline
- `[abc]` : Character class
- `[^abc]` : Negated character class
- `r*` : Zero or more of r
- `r+` : One or more of r
- `r?` : Zero or one of r
- `r{n,m}` : n to m occurrences of r
- `r1|r2` : Either r1 or r2
- `(r)` : Grouping
- `^r` : r at start of line
- `r$` : r at end of line

### Actions

#### Special Variables
- `yytext`: Matched text
- `yyleng`: Length of match
- `yylineno`: Current line number

#### Special Functions
- `ECHO`: Print matched text
- `BEGIN(state)`: Switch to start state
- `REJECT`: Try next pattern
- `yymore()`: Append next match
- `yyless(n)`: Push back input
- `input()`: Get next character
- `unput(c)`: Push back character

### Start State Rules
```c
<STATE>pattern { action }

// Example:
<COMMENT>"*/"    { BEGIN(INITIAL); }
```

## 3. User Code Section

### Required Components
```c
int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
```

## Operational Guidelines

### Pattern Matching Priority
1. Longest match wins
2. If same length, first rule wins
3. More specific patterns should come before general ones

### Default Actions
- No action specified: Matched text is printed
- No pattern matches: Character is copied to output

### Error Handling
```c
.  { printf("Error: unexpected character %s\n", yytext); }
```

### Memory Management
- `yytext` is overwritten by each match
- Use `strdup()` to store matches
- Example:
  ```c
  char *saved_text = strdup(yytext);
  ```

### Input/Output Control
```c
yyin = fopen("input.txt", "r");
yyout = fopen("output.txt", "w");
```

## Common Pitfalls

1. Pattern ordering: Not putting specific patterns before general ones
2. Special characters: Forgetting to escape them
3. Input handling: Not accounting for all possible cases
4. `yytext` usage: Assuming it persists between matches
5. Line anchors: Improper use of `^` or `$`
6. Headers: Missing necessary includes
7. File handling: Not closing opened files

## License

Feel free to use and modify this guide. Please provide attribution if you share it.