%{
#include "dec.tab.h"
#include <stdlib.h>
#include <string.h>
int yywrap(void){ return 1; }
%}

%%
[a-zA-Z][a-zA-Z0-9]*    { if (strcmp(yytext, "int") == 0) return INT; else return ID; }
","     { return COMMA; }
";"     { return SEMICOLON; }
[ \t\n]+    ;     
.       { return INVALID; }
%%