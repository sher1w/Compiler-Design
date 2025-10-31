%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YYSTYPE int
extern char id_name[];
int yylex(void);
void yyerror(const char *s);
%}

%token ID NUM ASSIGN SEMICOLON
%left '+' '-'
%left '*' '/'
%right UMINUS

%%

input:
      /* empty */
    | input stmt
    ;

stmt:
      ID ASSIGN expr SEMICOLON  { printf("%s = %d\n", id_name, $3); }
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
    printf("Enter assignments like x = 3 + 4; Ctrl+Z then Enter to quit.\n");
    yyparse();
    return 0;
}