grammar Expr;

// Parser rules
expr:   expr op=('*'|'/') expr      # MulDiv
    |   expr op=('+'|'-') expr      # AddSub
    |   expr '^' expr               # Power
    |   '(' expr ')'                # Parens
    |   ID                          # Id
    |   NUM                         # Num
    ;

// Lexer rules
ID  :   [a-zA-Z]+ ;
NUM :   [0-9]+ ('.' [0-9]+)? ;
WS  :   [ \t\r\n]+ -> skip ;
