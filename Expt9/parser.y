%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
void yyerror(const char *s);
int temp_count=0,label_count=0;


char* newtemp(){
char *t=(char*)malloc(10);
sprintf(t,"t%d",++temp_count);
return t;
}
char* newlabel(){
char *l=(char*)malloc(10);
sprintf(l,"L%d",++label_count);
return l;
}
void emit(char *s){
printf("%s\n",s);
}
char* make_binop(char *a,char *op,char *b){
char *t=newtemp();
char buf[100];
sprintf(buf,"%s = %s %s %s",t,a,op,b);
emit(buf);
return t;
}
%}



%union {char *str;}
%token <str> ID NUM
%token WHILE EQ NE LE GE
%type <str> expr term factor relop cond
%%
program: stmtlist;
stmtlist: stmtlist stmt | stmt;
stmt: ID '=' expr ';' {printf("%s = %s\n",$1,$3);}
| WHILE '(' cond ')' '{' stmtlist '}' {
    char *L1 = newlabel();   // start label
    char *L2 = newlabel();   // end label

    printf("%s:\n", L1);                     // label start of loop
    printf("t = %s\n", $3);                  // evaluate condition
    printf("if t == 0 goto %s\n", L2);       // if false → exit loop
    printf("%s\n", $6);                      // body of loop
    printf("goto %s\n", L1);                 // go back to start
    printf("%s:\n", L2);                     // end label
}



cond: expr relop expr {$$=make_binop($1,$2,$3);} ;
relop: '<' {$$="<";}| '>' {$$=">";}| LE {$$="<=";}| GE {$$=">=";}| EQ {$$="==";}| NE {$$="!=";};
expr: expr '+' term {$$=make_binop($1,"+",$3);} | expr '-' term {$$=make_binop($1,"-",$3);} | term {$$=$1;};
term: term '*' factor {$$=make_binop($1,"*",$3);} | term '/' factor {$$=make_binop($1,"/",$3);} | factor {$$=$1;};
factor: ID {$$=$1;}| NUM {$$=$1;}| '(' expr ')' {$$=$2;};
%%
void yyerror(const char *s){fprintf(stderr,"Error: %s\n",s);}
int main(){printf("--- THREE ADDRESS CODE ---\n");yyparse();return 0;}


