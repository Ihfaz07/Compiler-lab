%{
#include "math_parser.tab.h"
#include <string.h>
%}

%%
[ \t]+          { /* ignore whitespace */ }
\n              { return NEWLINE; }
[0-9]+          { yylval.str = strdup(yytext); return NUM; }
"sqrt"          { return SQRT; }
"pow"           { return POW; }
"log"           { return LOG; }
"exp"           { return EXP; }
"sin"           { return SIN; }
"cos"           { return COS; }
"tan"           { return TAN; }
"abs"           { return ABS; }
[a-zA-Z][a-zA-Z0-9]* { yylval.str = strdup(yytext); return ID; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"%"             { return MOD; }
"="             { return ASSIGN; }
"("             { return LPAREN; }
")"             { return RPAREN; }
","             { return COMMA; }
.               { /* ignore other characters */ }
%%

int yywrap() { return 1; }
