%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "project.tab.h"
    int yywrap();
    extern yylex();
%}

%%
[ \t]+      ;
[a-zA-Z]    { yylval.c = yytext[0]; return ID; }
[0-9]+      { yylval.i = atoi(yytext); return NMBR; }
"ASSIGN"    { yylval.s = strdup(yytext); return ASGN; }
"GT"        { yylval.s = strdup(yytext); return GT; }
"GTE"       { yylval.s = strdup(yytext); return GTE; }
"LS"        { yylval.s = strdup(yytext); return LS; }
"LSE"       { yylval.s = strdup(yytext); return LSE; }
"EQU"       { yylval.s = strdup(yytext); return EQU; }
"PRINT"     { yylval.s = strdup(yytext); return PRINT; }
"ADD"       { yylval.s = strdup(yytext); return ADD; }
"SUB"       { yylval.s = strdup(yytext); return SUB; }
"MUL"       { yylval.s = strdup(yytext); return MUL; }
","         { yylval.c = yytext[0]; return CM; }
.           { printf("UNEXPECTED COMMAND\n"); }
\n          { return NEWLINE; }
%%

int yywrap() {
    return 1;
}