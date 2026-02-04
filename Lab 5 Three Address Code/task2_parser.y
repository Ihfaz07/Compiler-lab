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
%token PLUS MINUS TIMES DIVIDE MOD ASSIGN
%token LPAREN RPAREN COMMA NEWLINE
%token SQRT POW LOG EXP SIN COS TAN ABS

%type <str> expression term factor function_call

%left PLUS MINUS
%left TIMES DIVIDE MOD

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
    | term MOD factor {
        char* temp = new_temp();
        printf("%s = %s %% %s\n", temp, $1, $3);
        $$ = temp;
    }
    | factor { $$ = $1; }
    ;

factor:
    function_call { $$ = $1; }
    | LPAREN expression RPAREN { $$ = $2; }
    | ID { $$ = $1; }
    | NUM { $$ = $1; }
    | MINUS factor {
        char* temp = new_temp();
        printf("%s = -%s\n", temp, $2);
        $$ = temp;
    }
    ;

function_call:
    SQRT LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = sqrt ( %s )\n", temp, $3);
        $$ = temp;
    }
    | POW LPAREN expression COMMA expression RPAREN {
        char* temp = new_temp();
        printf("%s = pow (%s , %s)\n", temp, $3, $5);
        $$ = temp;
    }
    | LOG LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = log ( %s )\n", temp, $3);
        $$ = temp;
    }
    | EXP LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = exp ( %s )\n", temp, $3);
        $$ = temp;
    }
    | SIN LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = sin ( %s )\n", temp, $3);
        $$ = temp;
    }
    | COS LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = cos ( %s )\n", temp, $3);
        $$ = temp;
    }
    | TAN LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = tan ( %s )\n", temp, $3);
        $$ = temp;
    }
    | ABS LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = abs ( %s )\n", temp, $3);
        $$ = temp;
    }
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
