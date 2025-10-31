%{
#include "expr.tab.h"
#include <stdlib.h>

/* yylval is defined by bison/yacc as an int (see expr.y) */

/* Provide yywrap so linking doesn't require -lfl on Windows/mingw */
int yywrap(void) { return 1; }
%}

%%
[0-9]+      { yylval = atoi(yytext); return NUM; }
[ \t]+     ;
"\n"      { return '\n'; }
"+"        { return '+'; }
"-"        { return '-'; }
"*"        { return '*'; }
"/"        { return '/'; }
"("        { return '('; }
")"        { return ')'; }
.           { return yytext[0]; }
%%