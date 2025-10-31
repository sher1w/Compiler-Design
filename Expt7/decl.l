%{
#include "decl.tab.h"
#include <stdlib.h>
#include <string.h>

/* Simple typedef name table */
#define MAX_TYPENAMES 1024
static char* type_names[MAX_TYPENAMES];
static int type_name_count = 0;
static int typedef_mode = 0; /* set when scanning a typedef declaration */

static int is_typedef_name(const char* s) {
	for (int i = 0; i < type_name_count; ++i) {
		if (strcmp(type_names[i], s) == 0) return 1;
	}
	return 0;
}

static void add_typedef_name(const char* s) {
	if (is_typedef_name(s)) return;
	if (type_name_count < MAX_TYPENAMES) {
        type_names[type_name_count++] = strdup(s);
	}
}

int yywrap(void){ return 1; }
%}


%%

[a-zA-Z_][a-zA-Z0-9_]*    {
	/* Keywords for basic and modifier types */
	if (strcmp(yytext, "int") == 0) return INT;
	if (strcmp(yytext, "float") == 0) return FLOAT;
	if (strcmp(yytext, "double") == 0) return DOUBLE;
	if (strcmp(yytext, "char") == 0) return CHAR;
	if (strcmp(yytext, "short") == 0) return SHORT;
	if (strcmp(yytext, "long") == 0) return LONG;
	if (strcmp(yytext, "signed") == 0) return SIGNED;
	if (strcmp(yytext, "unsigned") == 0) return UNSIGNED;
	if (strcmp(yytext, "void") == 0) return VOID;
	if (strcmp(yytext, "const") == 0) return CONST;
	if (strcmp(yytext, "volatile") == 0) return VOLATILE;
	if (strcmp(yytext, "typedef") == 0) { typedef_mode = 1; return TYPEDEF; }
	if (strcmp(yytext, "static") == 0) return STATIC;
	if (strcmp(yytext, "extern") == 0) return EXTERN;
	if (strcmp(yytext, "register") == 0) return REGISTER;
	if (strcmp(yytext, "struct") == 0) return STRUCT;
	if (strcmp(yytext, "union") == 0) return UNION;
	if (strcmp(yytext, "enum") == 0) return ENUM;

	/* typedef-name handling */
	if (typedef_mode) { add_typedef_name(yytext); return TYPE_NAME; }
	if (is_typedef_name(yytext)) return TYPE_NAME;
	return ID;
}
","             { return COMMA; }
";"             { typedef_mode = 0; return SEMICOLON; }
"="             { return ASSIGN; }
"*"             { return ASTERISK; }
"["             { return LBRACKET; }
"]"             { return RBRACKET; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
	[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?   { return FLOATCONST; }
	\.[0-9]+([eE][+-]?[0-9]+)?         { return FLOATCONST; }
	[0-9]+([eE][+-]?[0-9]+)             { return FLOATCONST; }

[0-9]+                              { return NUMBER; }

	\"([^\\\"\n]|\\.)*\"            { return STRINGLIT; }
'(\\.|[^\\\n])'                { return CHARCONST; }

[ \t\n\r]+     { /* skip whitespace */ }
.               { return INVALID; }
%%