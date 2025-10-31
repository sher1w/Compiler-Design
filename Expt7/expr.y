%{
#include <stdio.h>
#include <stdlib.h>

#define YYSTYPE int

int yylex(void);
void yyerror(const char *s);
%}

%token NUM
%left '+' '-'
%left '*' '/'
%right UMINUS

%%

input:
      /* empty */
    | input line
    ;

line:
      expr '\n'    { printf("Result = %d\n", $1); }
    ;

expr:
      expr '+' expr    { $$ = $1 + $3; }
    | expr '-' expr    { $$ = $1 - $3; }
    | expr '*' expr    { $$ = $1 * $3; }
    | expr '/' expr    { if ($3 == 0) { yyerror("division by zero"); $$ = 0; } else $$ = $1 / $3; }
    | '-' expr %prec UMINUS { $$ = -$2; }
    | '(' expr ')'     { $$ = $2; }
    | NUM              { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    printf("Enter expression (press Ctrl+Z then Enter to quit on Windows)\n");
    yyparse();
    return 0;
}