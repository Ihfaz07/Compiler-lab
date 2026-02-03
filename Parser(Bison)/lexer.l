%{
#include "parser.tab.h"
%}

%%
"if"        { return IF; }
"else"      { return ELSE; }
[a-zA-Z_][a-zA-Z0-9_]*  { return ID; }
[0-9]+      { return NUM; }
"<"         { return LT; }
"="         { return ASSIGN; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"/"         { return DIV; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
";"         { return SEMI; }
[ \t\n]+    { /* skip whitespace */ }
.           { return yytext[0]; }
%%

int yywrap() { return 1; }
