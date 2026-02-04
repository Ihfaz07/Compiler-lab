%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
void yyerror(const char *s);

int temp_count = 0;

char* new_temp() {
    char* temp = (char*)malloc(10);
    sprintf(temp, "t%d", ++temp_count);
    return temp;
}
%}

%union {
    char* str;
}

%token <str> ID NUM
%token PLUS MINUS TIMES DIVIDE INTDIV POWER MOD
%token ASSIGN PLUSEQ MINUSEQ TIMESEQ DIVEQ MODEQ POWEREQ
%token AND OR NOT GT LT LPAREN RPAREN NEWLINE

%type <str> expression term factor unary primary

%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDE INTDIV MOD
%right POWER
%right NOT UMINUS

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    ID ASSIGN expression NEWLINE {
        printf("%s = %s\n", $1, $3);
    }
    | ID ASSIGN expression {
        printf("%s = %s\n", $1, $3);
    }
    | ID PLUSEQ expression NEWLINE {
        char* temp = new_temp();
        printf("%s = %s + %s\n", temp, $1, $3);
        printf("%s = %s\n", $1, temp);
    }
    | ID MINUSEQ expression NEWLINE {
        char* temp = new_temp();
        printf("%s = %s - %s\n", temp, $1, $3);
        printf("%s = %s\n", $1, temp);
    }
    | ID TIMESEQ expression NEWLINE {
        char* temp = new_temp();
        printf("%s = %s * %s\n", temp, $1, $3);
        printf("%s = %s\n", $1, temp);
    }
    | ID DIVEQ expression NEWLINE {
        char* temp = new_temp();
        printf("%s = %s / %s\n", temp, $1, $3);
        printf("%s = %s\n", $1, temp);
    }
    | ID MODEQ expression NEWLINE {
        char* temp = new_temp();
        printf("%s = %s %% %s\n", temp, $1, $3);
        printf("%s = %s\n", $1, temp);
    }
    | ID POWEREQ expression NEWLINE {
        char* temp = new_temp();
        printf("%s = %s ** %s\n", temp, $1, $3);
        printf("%s = %s\n", $1, temp);
    }
    | NEWLINE
    ;

expression:
    expression PLUS term {
        char* temp = new_temp();
        printf("%s = %s + %s\n", temp, $1, $3);
        $$ = temp;
    }
    | expression MINUS term {
        char* temp = new_temp();
        printf("%s = %s - %s\n", temp, $1, $3);
        $$ = temp;
    }
    | expression OR term {
        char* temp = new_temp();
        printf("%s = %s || %s\n", temp, $1, $3);
        $$ = temp;
    }
    | term { $$ = $1; }
    ;

term:
    term TIMES factor {
        char* temp = new_temp();
        printf("%s = %s * %s\n", temp, $1, $3);
        $$ = temp;
    }
    | term DIVIDE factor {
        char* temp = new_temp();
        printf("%s = %s / %s\n", temp, $1, $3);
        $$ = temp;
    }
    | term INTDIV factor {
        char* temp = new_temp();
        printf("%s = %s // %s\n", temp, $1, $3);
        $$ = temp;
    }
    | term MOD factor {
        char* temp = new_temp();
        printf("%s = %s %% %s\n", temp, $1, $3);
        $$ = temp;
    }
    | term AND factor {
        char* temp = new_temp();
        printf("%s = %s && %s\n", temp, $1, $3);
        $$ = temp;
    }
    | term GT factor {
        char* temp = new_temp();
        printf("%s = %s > %s\n", temp, $1, $3);
        $$ = temp;
    }
    | term LT factor {
        char* temp = new_temp();
        printf("%s = %s < %s\n", temp, $1, $3);
        $$ = temp;
    }
    | factor { $$ = $1; }
    ;

factor:
    factor POWER unary {
        char* temp = new_temp();
        printf("%s = %s ** %s\n", temp, $1, $3);
        $$ = temp;
    }
    | unary { $$ = $1; }
    ;

unary:
    NOT unary {
        char* temp = new_temp();
        printf("%s = ! %s\n", temp, $2);
        $$ = temp;
    }
    | MINUS unary %prec UMINUS {
        char* temp = new_temp();
        printf("%s = -%s\n", temp, $2);
        $$ = temp;
    }
    | primary { $$ = $1; }
    ;

primary:
    LPAREN expression RPAREN { $$ = $2; }
    | ID { $$ = $1; }
    | NUM { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (file) {
            yyin = file;
        }
    }
    yyparse();
    return 0;
}
