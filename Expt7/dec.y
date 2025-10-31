%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}

%token INT ID COMMA SEMICOLON INVALID

%%

decl : INT varlist SEMICOLON  { printf("Valid declaration\n"); }
     ;

varlist : ID
         | varlist COMMA ID
         ;

%%
void yyerror(const char *s) {
    printf("Invalid declaration\n");
}

int main() {
    printf("Enter declaration: ");
    yyparse();
    return 0;
}