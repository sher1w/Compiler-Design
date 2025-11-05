%{
#include "y.tab.h"
%}

%%
"while"          { return WHILE; }
"<="             { return LE; }
">="             { return GE; }
"=="             { return EQ; }
"!="             { return NE; }
[a-zA-Z_][a-zA-Z0-9_]*   { yylval.str = strdup(yytext); return ID; }
[0-9]+           { yylval.str = strdup(yytext); return NUM; }
[ \t\n]+         { /* skip whitespace */ }
.                { return yytext[0]; }
%%

int yywrap() { return 1; }
