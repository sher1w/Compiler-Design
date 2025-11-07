%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}

%%

[ \t\r\n]+             ;
"while"                { return WHILE; }
"<="|">="|"=="|"!="    { return yytext[0] == '<' && yytext[1] == '=' ? LE :
                                 yytext[0] == '>' && yytext[1] == '=' ? GE :
                                 yytext[0] == '=' ? EQ : NE; }
"<"|">"                { return yytext[0] == '<' ? LT : GT; }
[0-9]+                 { yylval.str = strdup(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }
[=;(){}+\-*/]          { return yytext[0]; }
.                      { printf("Unknown character: %s\n", yytext); }

%%

int yywrap(void) { return 1; }
