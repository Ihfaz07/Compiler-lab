%{
#include "parser.tab.h"
#include <string.h>
%}

%%
[ \t]+          { /* ignore whitespace */ }
\n              { return NEWLINE; }
[0-9]+          { yylval.str = strdup(yytext); return NUM; }
[a-zA-Z][a-zA-Z0-9]* { yylval.str = strdup(yytext); return ID; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"//"            { return INTDIV; }
"**"            { return POWER; }
"%"             { return MOD; }
"="             { return ASSIGN; }
"+="            { return PLUSEQ; }
"-="            { return MINUSEQ; }
"*="            { return TIMESEQ; }
"/="            { return DIVEQ; }
"%="            { return MODEQ; }
"**="           { return POWEREQ; }
"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }
">"             { return GT; }
"<"             { return LT; }
"("             { return LPAREN; }
")"             { return RPAREN; }
.               { /* ignore other characters */ }
%%

int yywrap() { return 1; }
