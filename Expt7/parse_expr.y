%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%token NUM
%left '+' '-'
%left '*' '/'
%right UMINUS

%%
input:
      expr '\n'   { printf(" Valid expression. Result = %d\n", $1); }
    | error '\n'  { yyerror(" Invalid expression"); yyerrok; }
    ;

expr:
      expr '+' expr   { $$ = $1 + $3; }
    | expr '-' expr   { $$ = $1 - $3; }
    | expr '*' expr   { $$ = $1 * $3; }
    | expr '/' expr   { 
                          if ($3 == 0) { 
                              yyerror(" Division by zero"); 
                              $$ = 0; 
                          } else $$ = $1 / $3; 
                       }
    | '-' expr %prec UMINUS { $$ = -$2; }
    | '(' expr ')'     { $$ = $2; }
    | NUM              { $$ = $1; }
    ;
%%

void yyerror(const char *s) {
    printf("%s\n", s);
}

int main(void) {
    printf("Enter an arithmetic expression (or Ctrl+D to exit):\n");
    yyparse();
    return 0;
}
