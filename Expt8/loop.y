%{ 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 

int yylex(); 
void yyerror(const char *msg); 
extern int line_no; 
int had_error = 0; 
%} 

%token FOR OP CP OB CB SC ASSIGN RELOP OPERATOR NUMBER ID INVALID EXIT 

%% 
input:
      /* empty */
    | input statement 
    ; 

statement:
      loop               
        {  
          if (!had_error)  
              printf("Valid loop structure\n\n");  
          had_error = 0;  
          line_no = 1;  
        } 

    | EXIT               
        {  
          printf("\nExiting loop validator. Goodbye!\n");  
          exit(0);  
        } 

    | invalid_stmt 
    ; 

invalid_stmt:
      error              
        {  
          if (!had_error) { 
              printf("Invalid loop syntax. Please check missing symbols.\n\n"); 
              had_error = 1; 
          } 
          yyclearin;  
          yyerrok;  
          while (getchar() != '\n'); /* Flush leftover input */ 
          line_no = 1;  
        } 
    ; 

/* LOOP GRAMMAR */ 
loop:
      /* Valid loop */ 
      FOR OP assign_stmt SC condition SC assign_stmt CP block 

      /* Missing '(' after 'for' */ 
    | FOR ID 
        {  
          printf("Missing '(' after 'for' keyword at line %d\n\n", line_no); 
          had_error = 1; 
          yyclearin; 
          yyerrok; 
        } 

      /* Missing braces for loop body */ 
    | FOR OP assign_stmt SC condition SC assign_stmt CP stmt 
        {  
          printf("Missing '{' or '}' in loop body at line %d\n\n", line_no); 
          had_error = 1; 
        } 

      /* Missing parentheses */ 
    | FOR error 
        {  
          printf("Missing or incorrect '(' or ')' in for loop header at line %d\n\n", line_no); 
          had_error = 1; 
          yyclearin; 
          yyerrok; 
        } 

      /* Missing semicolon after initialization */ 
    | FOR OP assign_stmt error 
        {  
          printf("Missing semicolon ';' after initialization at line %d\n\n", line_no); 
          had_error = 1; 
        } 

      /* Missing braces after complete header */ 
    | FOR OP assign_stmt SC condition SC assign_stmt CP error 
        {  
          printf("Missing or incorrect '{' or '}' in loop body at line %d\n\n", line_no); 
          had_error = 1; 
        } 

      /* Unexpected token after 'for' */ 
    | FOR INVALID 
        { 
          printf("Missing '(' after 'for' keyword at line %d\n\n", line_no); 
          had_error = 1; 
          yyclearin; 
          yyerrok; 
        } 
    ; 

block:
      OB stmt_list CB 
    ; 

stmt_list:
      stmt 
    | stmt stmt_list 
    ; 

stmt:
      assign_stmt SC 
    | loop 
    ; 

assign_stmt:
      ID ASSIGN expr 
    ; 

expr:
      ID 
    | NUMBER 
    | ID OPERATOR expr 
    | NUMBER OPERATOR expr 
    ; 

condition:
      ID RELOP ID 
    | ID RELOP NUMBER 
    ; 
%% 

void yyerror(const char *msg) { 
    if (!had_error) { 
        printf("Syntax Error: %s at line %d\n\n", msg, line_no); 
        had_error = 1; 
    } 
} 

int main() { 
    printf("=== YACC Loop Validator ===\n"); 
    printf("Enter your loops below (type 'exit' to quit):\n\n"); 
    while (1) { 
        yyparse(); 
    } 
    return 0; 
}
