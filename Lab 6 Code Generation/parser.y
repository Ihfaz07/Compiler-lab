%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
void yyerror(const char *s);

int temp_count = 0;
int reg_count = 0;

char* new_temp() {
    char* temp = (char*)malloc(10);
    sprintf(temp, "t%d", ++temp_count);
    return temp;
}

void emit_tac(const char* dest, const char* src1, const char* op, 
              const char* src2) {
    if (src2) {
        printf("%s = %s %s %s\n", dest, src1, op, src2);
    } else if (op) {
        printf("%s = %s %s\n", dest, op, src1);
    } else {
        printf("%s = %s\n", dest, src1);
    }
}

void emit_asm(const char* op, const char* dest, const char* src) {
    if (src) {
        printf("%s %s , %s\n", op, dest, src);
    } else {
        printf("%s %s\n", op, dest);
    }
    printf("\n");
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
        emit_tac($1, $3, NULL, NULL);
        emit_asm("MOV", $3, $1);
        emit_asm("MOV", $1, $3);
    }
    | ID ASSIGN expression {
        emit_tac($1, $3, NULL, NULL);
        emit_asm("MOV", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | ID PLUSEQ expression NEWLINE {
        char* temp = new_temp();
        emit_tac(temp, $1, "+", $3);
        emit_tac($1, temp, NULL, NULL);
        
        emit_asm("MOV", "R0", $1);
        emit_asm("ADD", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | ID MINUSEQ expression NEWLINE {
        char* temp = new_temp();
        emit_tac(temp, $1, "-", $3);
        emit_tac($1, temp, NULL, NULL);
        
        emit_asm("MOV", "R0", $1);
        emit_asm("SUB", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | ID TIMESEQ expression NEWLINE {
        char* temp = new_temp();
        emit_tac(temp, $1, "*", $3);
        emit_tac($1, temp, NULL, NULL);
        
        emit_asm("MOV", "R0", $1);
        emit_asm("MUL", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | ID DIVEQ expression NEWLINE {
        char* temp = new_temp();
        emit_tac(temp, $1, "/", $3);
        emit_tac($1, temp, NULL, NULL);
        
        emit_asm("MOV", "R0", $1);
        emit_asm("DIV", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | ID MODEQ expression NEWLINE {
        char* temp = new_temp();
        emit_tac(temp, $1, "%", $3);
        emit_tac($1, temp, NULL, NULL);
        
        emit_asm("MOV", "R0", $1);
        emit_asm("MOD", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | ID POWEREQ expression NEWLINE {
        char* temp = new_temp();
        emit_tac(temp, $1, "**", $3);
        emit_tac($1, temp, NULL, NULL);
        
        emit_asm("MOV", "R0", $1);
        emit_asm("POW", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | NEWLINE
    ;

expression:
    expression PLUS term {
        char* temp = new_temp();
        emit_tac(temp, $1, "+", $3);
        $$ = temp;
    }
    | expression MINUS term {
        char* temp = new_temp();
        emit_tac(temp, $1, "-", $3);
        $$ = temp;
    }
    | expression OR term {
        char* temp = new_temp();
        emit_tac(temp, $1, "||", $3);
        $$ = temp;
    }
    | term { $$ = $1; }
    ;

term:
    term TIMES factor {
        char* temp = new_temp();
        emit_tac(temp, $1, "*", $3);
        $$ = temp;
    }
    | term DIVIDE factor {
        char* temp = new_temp();
        emit_tac(temp, $1, "/", $3);
        $$ = temp;
    }
    | term INTDIV factor {
        char* temp = new_temp();
        emit_tac(temp, $1, "//", $3);
        $$ = temp;
    }
    | term MOD factor {
        char* temp = new_temp();
        emit_tac(temp, $1, "%", $3);
        $$ = temp;
    }
    | term AND factor {
        char* temp = new_temp();
        emit_tac(temp, $1, "&&", $3);
        $$ = temp;
    }
    | term GT factor {
        char* temp = new_temp();
        emit_tac(temp, $1, ">", $3);
        $$ = temp;
    }
    | term LT factor {
        char* temp = new_temp();
        emit_tac(temp, $1, "<", $3);
        $$ = temp;
    }
    | factor { $$ = $1; }
    ;

factor:
    factor POWER unary {
        char* temp = new_temp();
        emit_tac(temp, $1, "**", $3);
        $$ = temp;
    }
    | unary { $$ = $1; }
    ;

unary:
    NOT unary {
        char* temp = new_temp();
        emit_tac(temp, "!", $2, NULL);
        $$ = temp;
    }
    | MINUS unary %prec UMINUS {
        char* temp = new_temp();
        emit_tac(temp, "-", $2, NULL);
        $$ = temp;
    }
    | primary { $$ = $1; }
    ;

primary:
    LPAREN expression RPAREN { $$ = $2; }
    | ID { $$ = $1; }
    | NUM { 
        char* temp = (char*)malloc(strlen($1) + 2);
        sprintf(temp, "#%s", $1);
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
