%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

int yylex(void);
void yyerror(const char *s);

static int temp_count = 0;
static int label_count = 0;

char *newtemp() {
    char buf[32];
    sprintf(buf, "t%d", ++temp_count);
    return strdup(buf);
}

char *newlabel() {
    char buf[32];
    sprintf(buf, "L%d", ++label_count);
    return strdup(buf);
}

/* Simple label stack to support nested loops */
#define MAX_LABELS 256
static char *label_stack[MAX_LABELS];
static int label_top = 0;
void push_label(char *l) { if (label_top < MAX_LABELS) label_stack[label_top++] = l; }
char *pop_label() { if (label_top>0) return label_stack[--label_top]; return NULL; }

/* Exit label stack to ensure condition jump is placed before body */
static char *exit_stack[MAX_LABELS];
static int exit_top = 0;
void push_exit(char *l) { if (exit_top < MAX_LABELS) exit_stack[exit_top++] = l; }
char *pop_exit() { if (exit_top>0) return exit_stack[--exit_top]; return NULL; }

void emit(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    printf("\n");
    va_end(ap);
}

%}

%union { char *str; }

%token <str> ID NUM
%token WHILE
%token LT LE GT GE EQ NE

%left '+' '-'
%left '*' '/'
%right UMINUS

%type <str> expr cond relop

%%

program:
      stmt_list
    ;

stmt_list:
      /* empty */
    | stmt_list stmt
    ;

stmt:
      assignment
    | while_stmt
    ;

assignment:
      ID '=' expr ';' {
          emit("%s = %s", $1, $3);
          free($1); free($3);
      }
    ;

/* mid-rule action to emit start label before condition code is generated */
while_stmt:
      WHILE { char *s = newlabel(); push_label(s); printf("%s:\n", s); }
      '(' cond ')' { char *e = newlabel(); push_exit(e); emit("if %s == 0 goto %s", $4, e); free($4); }
      '{' stmt_list '}' {
          char *start = pop_label();
          char *exit = pop_exit();
          /* loop back after body */
          emit("goto %s", start);
          printf("%s:\n", exit);
          free(start); free(exit);
      }
    ;

cond:
      expr relop expr {
          char *tmp = newtemp();
          emit("%s = %s %s %s", tmp, $1, $2, $3);
          free($1); free($2); free($3);
          $$ = tmp;
      }
    ;

relop:
      LT { $$ = strdup("<"); }
    | LE { $$ = strdup("<="); }
    | GT { $$ = strdup(">"); }
    | GE { $$ = strdup(">="); }
    | EQ { $$ = strdup("=="); }
    | NE { $$ = strdup("!="); }
    ;

expr:
      expr '+' expr { char *t=newtemp(); emit("%s = %s + %s", t, $1, $3); free($1); free($3); $$ = t; }
    | expr '-' expr { char *t=newtemp(); emit("%s = %s - %s", t, $1, $3); free($1); free($3); $$ = t; }
    | expr '*' expr { char *t=newtemp(); emit("%s = %s * %s", t, $1, $3); free($1); free($3); $$ = t; }
    | expr '/' expr { char *t=newtemp(); emit("%s = %s / %s", t, $1, $3); free($1); free($3); $$ = t; }
    | '(' expr ')'  { $$ = $2; }
    | '-' expr %prec UMINUS { char *t=newtemp(); emit("%s = - %s", t, $2); free($2); $$ = t; }
    | ID { $$ = $1; }
    | NUM { $$ = $1; }
    ;

%%

int main(int argc, char **argv) {
    printf("--- Three Address Code (TAC) output ---\n");
    if (yyparse() == 0) {
        printf("--- End of TAC ---\n");
    }
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}