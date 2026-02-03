%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex();
void yyerror(const char *s);
%}

%token IF ELSE ID NUM LT ASSIGN PLUS MINUS DIV
%token LPAREN RPAREN LBRACE RBRACE SEMI

%%
program: statement_list
       ;

statement_list: statement
              | statement_list statement
              ;

statement: assignment SEMI
         | if_statement
         ;

assignment: ID ASSIGN expr
          ;

if_statement: IF LPAREN expr RPAREN LBRACE statement_list RBRACE
            | IF LPAREN expr RPAREN LBRACE statement_list RBRACE 
              ELSE LBRACE statement_list RBRACE
            ;

expr: ID
    | NUM
    | expr PLUS expr
    | expr MINUS expr
    | expr DIV expr
    | expr LT expr
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (file) {
            yyin = file;
        }
    }
    if (yyparse() == 0) {
        printf("Parsing successful!\n");
    }
    return 0;
}
