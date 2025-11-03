%{ 
#include "y.tab.h" 
#include <stdio.h> 
#include <string.h> 
int line_no = 1; 
%} 
 
%% 
"for"           { return FOR; } 
"("             { return OP; } 
")"             { return CP; } 
"{"             { return OB; } 
"}"             { return CB; } 
";"             { return SC; } 
"<="|">="|"<"|">"|"=="|"!="   { return RELOP; } 
"="             { return ASSIGN; } 
"+"|"-"|"*"|"/" { return OPERATOR; } 
[0-9]+          { return NUMBER; } 
[a-zA-Z_][a-zA-Z0-9_]*   {  
                        if(strcmp(yytext, "exit") == 0) 
                            return EXIT; 
                        return ID;  
                      } 
[ \t\r]+        ;   /* Ignore whitespace */ 
\n              { /* Prevent line increment during multiline input */ } 
.               { return INVALID; }   /* Handle invalid characters in YACC */ 
%% 
 
int yywrap() { return 1; }