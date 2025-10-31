%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
static int g_error = 0;
%}

%union {
    int ival; /* 1 if declarator denotes a function, else 0 */
}

%token VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED
%token CONST VOLATILE TYPEDEF STATIC EXTERN REGISTER
%token STRUCT UNION ENUM
%token TYPE_NAME
%token ID NUMBER FLOATCONST CHARCONST STRINGLIT
%token COMMA SEMICOLON ASSIGN ASTERISK LBRACKET RBRACKET LPAREN RPAREN LBRACE RBRACE INVALID

%type <ival> declarator direct_declarator

%%

decl
    : decl_specifiers init_declarator_list SEMICOLON   { if (!g_error) printf("Valid declaration\n"); }
    | decl_specifiers SEMICOLON                        { if (!g_error) printf("Valid declaration\n"); }
    ;

/* declaration specifiers: storage class | type specifiers | type qualifiers */
decl_specifiers
    : decl_specifiers decl_specifier
    | decl_specifier
    ;

decl_specifier
    : storage_class_specifier
    | type_qualifier
    | type_token
    | struct_or_union_specifier
    | enum_specifier
    ;

storage_class_specifier
    : TYPEDEF
    | EXTERN
    | STATIC
    | REGISTER
    ;

type_token
    : VOID
    | CHAR
    | SHORT
    | INT
    | LONG
    | FLOAT
    | DOUBLE
    | SIGNED
    | UNSIGNED
    | TYPE_NAME
    ;

/* struct/union definitions or tags */
struct_or_union_specifier
    : STRUCT opt_id LBRACE member_declaration_list_opt RBRACE
    | UNION  opt_id LBRACE member_declaration_list_opt RBRACE
    ;

opt_id
    : /* empty */
    | ID
    ;

member_declaration_list_opt
    : /* empty */
    | member_declaration_list
    ;

member_declaration_list
    : member_declaration
    | member_declaration_list member_declaration
    ;

member_declaration
    : decl_specifiers member_declarator_list_opt SEMICOLON
    ;

member_declarator_list_opt
    : /* empty */
    | member_declarator_list
    ;

member_declarator_list
    : member_declarator
    | member_declarator_list COMMA member_declarator
    ;

member_declarator
    : declarator
    ;

/* enum definitions or tags */
enum_specifier
    : ENUM opt_id LBRACE enumerator_list_opt RBRACE
    | ENUM opt_id LBRACE enumerator_list COMMA RBRACE
    | ENUM ID
    ;

enumerator_list_opt
    : /* empty */
    | enumerator_list
    ;

enumerator_list
    : enumerator
    | enumerator_list COMMA enumerator
    ;

enumerator
    : ID
    | ID ASSIGN const_expr_opt
    ;

type_qualifier
    : CONST
    | VOLATILE
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list COMMA init_declarator
    ;

/* Disallow initializers for function declarators by only allowing assignment
   to non-function declarators */
init_declarator
    : declarator
    | declarator ASSIGN initializer   { if ($1) yyerror("function declarator cannot be initialized"); }
    ;

/* pointer and array declarators like: *p, **q, a[10], b[3][4] */
declarator
    : pointer_opt direct_declarator   { $$ = $2; }
    ;

pointer_opt
    : /* empty */
    | pointer
    ;

/* pointer with optional qualifiers after each '*' */
pointer
    : ASTERISK type_qual_list_opt
    | ASTERISK type_qual_list_opt pointer
    ;

type_qual_list_opt
    : /* empty */
    | type_qual_list
    ;

type_qual_list
    : type_qualifier
    | type_qual_list type_qualifier
    ;

direct_declarator
    : ID                                            { $$ = 0; }
    | LPAREN declarator RPAREN                      { $$ = $2; }
    | direct_declarator LBRACKET const_expr_opt RBRACKET   { $$ = $1; }
    | direct_declarator LPAREN parameter_list_opt RPAREN   { $$ = 1; }
    ;

const_expr_opt
    : /* empty */
    | NUMBER
    | ID
    ;

/* keep initializer simple (constants or identifiers) */
initializer
    : NUMBER
    | FLOATCONST
    | CHARCONST
    | STRINGLIT
    | ID
    ;

/* parameters: simplified */
parameter_list_opt
    : /* empty */
    | parameter_list
    ;

parameter_list
    : parameter_declaration
    | parameter_list COMMA parameter_declaration
    ;

parameter_declaration
    : decl_specifiers declarator
    | decl_specifiers
    ;

%%
void yyerror(const char *s) {
    g_error = 1;
    printf("Invalid declaration\n");
}

int main() {
    printf("Enter declaration: ");
    g_error = 0;
    yyparse();
    return 0;
}