%{
#include "assign.tab.h"
#include <stdlib.h>
#include <string.h>
char id_name[64];
int yywrap(void){ return 1; }
%}

%%
[a-zA-Z][a-zA-Z0-9]* { strncpy(id_name, yytext, sizeof(id_name)-1); id_name[sizeof(id_name)-1] = '\0'; return ID; }
[0-9]+      { yylval = atoi(yytext); return NUM; }
"="        { return ASSIGN; }
";"        { return SEMICOLON; }
"+"        { return '+'; }
"-"        { return '-'; }
"*"        { return '*'; }
"/"        { return '/'; }
"("        { return '('; }
")"        { return ')'; }
[ \t\n]+   ;
.           { return yytext[0]; }
%%