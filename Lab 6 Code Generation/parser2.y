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

void emit_function_asm(const char* func, const char* arg1, 
                       const char* arg2) {
    printf("MOV R0 , %s\n", arg1);
    if (arg2) {
        printf("%s R0 , %s\n", func, arg2);
    } else {
        printf("%s R0\n", func);
    }
    printf("\n");
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
        emit_tac($1, $3, NULL, NULL);
        emit_asm("MOV", "R0", $3);
        emit_asm("MOV", $1, "R0");
    }
    | ID ASSIGN expression {
        emit_tac($1, $3, NULL, NULL);
        emit_asm("MOV", "R0", $3);
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
    | term MOD factor {
        char* temp = new_temp();
        emit_tac(temp, $1, "%", $3);
        $$ = temp;
    }
    | factor { $$ = $1; }
    ;

factor:
    function_call { $$ = $1; }
    | LPAREN expression RPAREN { $$ = $2; }
    | ID { $$ = $1; }
    | NUM { 
        char* temp = (char*)malloc(strlen($1) + 2);
        sprintf(temp, "#%s", $1);
        $$ = temp; 
    }
    | MINUS factor {
        char* temp = new_temp();
        printf("%s = -%s\n", temp, $2);
        printf("MOV R0 , %s\n", $2);
        printf("NEG R0\n\n");
        $$ = temp;
    }
    ;

function_call:
    SQRT LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = sqrt ( %s )\n", temp, $3);
        emit_function_asm("SQRT", $3, NULL);
        $$ = temp;
    }
    | POW LPAREN expression COMMA expression RPAREN {
        char* temp = new_temp();
        printf("%s = pow (%s , %s)\n", temp, $3, $5);
        emit_function_asm("POW", $3, $5);
        $$ = temp;
    }
    | LOG LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = log ( %s )\n", temp, $3);
        emit_function_asm("LOG", $3, NULL);
        $$ = temp;
    }
    | EXP LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = exp ( %s )\n", temp, $3);
        emit_function_asm("EXP", $3, NULL);
        $$ = temp;
    }
    | SIN LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = sin ( %s )\n", temp, $3);
        emit_function_asm("SIN", $3, NULL);
        $$ = temp;
    }
    | COS LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = cos ( %s )\n", temp, $3);
        emit_function_asm("COS", $3, NULL);
        $$ = temp;
    }
    | TAN LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = tan ( %s )\n", temp, $3);
        emit_function_asm("TAN", $3, NULL);
        $$ = temp;
    }
    | ABS LPAREN expression RPAREN {
        char* temp = new_temp();
        printf("%s = abs ( %s )\n", temp, $3);
        emit_function_asm("ABS", $3, NULL);
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
\end{lstlisting}

\textbf{Compilation and Execution:}
\begin{verbatim}
# Generate parser and lexer
bison -d math_parser.y
flex math_lexer.l

# Compile
gcc math_parser.tab.c lex.yy.c -o math_codegen

# Run with input file
math_codegen.exe input.txt
