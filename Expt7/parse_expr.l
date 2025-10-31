%{
#include "parse_expr.tab.h"
%}

%%
[0-9]+      { yylval = atoi(yytext); return NUM; }
[ \t]       { /* skip whitespace */ }
[\n]        { return '\n'; }
.           { return yytext[0]; }
%%

int yywrap() { return 1; }
