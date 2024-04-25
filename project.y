%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <ctype.h>
    #include "project.tab.h"

    void yyerror(char *msg);
    extern int yyparse();
    int yyerrstatus;

    bool hasVal(char);
    void setVal(char, int);
    int getVal(char);
    int doOp(char*, int, int);
    void doPrint(char*);
    char* doComp(char* x, char* y, char* z);
    bool digCheck(char*);
    char* toString(int);
    char* writeChar(char);

    int symbol_table[100][2];
    int symbol_count = 0;
    int i = 0;
    char cval;
    int a;
    int b;
    int val1;
    int val2;
%}

%union{
    int i;
    char* s;
    char c;
}

%token NEWLINE
%token <i> NMBR
%token <s> ASGN GT GTE LS LSE EQU PRINT ADD SUB MUL UNEX EXIT
%token <c> ID CM

%type <s> S E VAL BOOL COMP OP PR
%type <i> NUM
%type <c> IDR

%%

    S       :   S E NEWLINE         {  }
            |   E NEWLINE           {  }
            |   error NEWLINE       { yyerrok; }
            |   EXIT NEWLINE        { printf("PROGRAM TERMINATED\n"); exit(0); }
            ;

    E       :   VAL                 { $$ = $1; }
            |   PR                  { $$ = $1; }
            ;

    VAL     :   IDR                 { 
                                        char temp[2];
                                        sprintf(temp, "%c", $1);
                                        $$ = strdup(temp);
                                    }
            |   NUM                 { $$ = toString($1); }
            |   BOOL                {
                                        if (strcmp($1, "*") == 0) { $$ = "UNCOMPAREABLE";}
                                        else { $$ = $1; }
                                    }
            ;
    
    IDR     :   ID                  { $$ = $1; }
            |   ASGN IDR CM NUM     { $$ = $2; setVal($2, $4); printf("SUCCESS\n"); }
            |   OP IDR CM NUM       {   
                                        $$ = $2;
                                        if (!hasVal($2)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $2); }
                                        else { setVal($2, doOp($1, getVal($2), $4)); }
                                    }
            |   OP NUM CM IDR       {   
                                        $$ = $4;
                                        if (!hasVal($4)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $4); }
                                        else { setVal($4, doOp($1, $2, getVal($4))); }
                                    }
            |   OP IDR CM IDR       {   
                                        $$ = $2;
                                        if (!hasVal($2)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $2); }
                                        else if (!hasVal($4)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $4); }
                                        else { setVal($2, doOp($1, getVal($2), getVal($4))); }
                                    }
            ;
    
    NUM     :   OP NUM CM NUM       { $$ = doOp($1, $2, $4); }
            |   NMBR                { $$ = $1; }
            ;

    OP      :   ADD                 { $$ = $1; }
            |   SUB                 { $$ = $1; }
            |   MUL                 { $$ = $1; }

    BOOL    :   COMP VAL CM VAL     { $$ = doComp($1, $2, $4); }
            |   COMP VAL CM UNEX    { $$ = "*"; printf("UNCOMPAREABLE\n"); }
            |   COMP UNEX CM VAL    { $$ = "*"; printf("UNCOMPAREABLE\n"); }
            |   COMP UNEX CM UNEX   { $$ = "*"; printf("UNCOMPAREABLE\n"); }
            ;
        
    COMP    :   GT                  { $$ = $1; }
            |   GTE                 { $$ = $1; }
            |   LS                  { $$ = $1; }
            |   LSE                 { $$ = $1; }
            |   EQU                 { $$ = $1; }

    PR      :   PRINT E             { $$ = $2; doPrint($2); }

%%

void yyerror(char *msg){
    printf("UNEXPECTED COMMAND\n");
    yyerrok;
}

int main(){
    while(yyparse() == 0);
    return 0;
}

bool hasVal(char id) {
    for (i = 0; i < symbol_count; i++) {
        if (symbol_table[i][0] == id) {
            return true;
        }
    }
    return false;
}

int getVal(char id) {
    for (i = 0; i < symbol_count; i++) {
        if (symbol_table[i][0] == id) {
            return symbol_table[i][1];
        }
    }
    return -999; //debugging only
}

void setVal(char id, int value) {
    if (symbol_count > 0) {
        for (i = 0; i < symbol_count; i++) {
            if (symbol_table[i][0] == (int) id) {
                symbol_table[i][1] = value;
                return;
            }
        }
    }
    symbol_table[symbol_count][0] = (int) id;
    symbol_table[symbol_count][1] = value;
    symbol_count++;
}

int doOp(char* op, int x, int y) {
    if (strcmp(op, "ADD") == 0) {
        printf("SUCCESS\n");
        return x + y;
    }
    else if (strcmp(op, "SUB") == 0) {
        printf("SUCCESS\n");
        return x - y;
    }
    else if (strcmp(op, "MUL") == 0) {
        printf("SUCCESS\n");
        return x * y;
    }
    else if (strcmp(op, "DIV") == 0) {
        printf("SUCCESS\n");
        return x / y;
    }
    else if (strcmp(op, "MOD") == 0) {
        printf("SUCCESS\n");
        return x % y;
    }
}

void doPrint(char* val) {
    if (strlen(val) == 1 && isalpha(*val)) {
        if (hasVal(*val) == 0) {
            printf("NO VAL ASSIGN TO %s\n", val);
        }
        else {
            i = getVal(*val);
            printf("PRINTING %s %i\n", val, i);
        }
    }
    else {
        printf("PRINTING %s\n", val);
    }
}

char* doComp(char* x, char* y, char* z) {
    if (strcmp(y, "*") == 0 || strcmp(z, "*") == 0 || strcmp(y, "UNCOMP") == 0 || strcmp(z, "UNCOMP") == 0) {
        return "*";
    }

    if (strlen(y) == 1 && isalpha(*y)) {
        if (hasVal(*y) == 0) {
            printf("NO VAL ASSIGN TO %s\n", y);
            return "*";
        }
        else {
            val1 = getVal(*y);
        }
    }
    else if (digCheck(y)) {
        val1 = atoi(y);
    }
    else if (strcmp(y, "TRUE") == 0){
        val1 = 1;
    }
    else if (strcmp(y, "FALSE") == 0){
        val1 = 0;
    }
    else {
        printf("UNCOMPAREABLE\n");
        return "*";
    }

    if (strlen(z) == 1 && isalpha(*z)) {
        if (hasVal(*z) == 0) {
            printf("NO VAL ASSIGN TO %s\n", z);
            return "*";
        }
        else {
            val2 = getVal(*z);
        }
    }
    else if (digCheck(z)) {
        val2 = atoi(z);
    }
    else if (strcmp(z, "TRUE") == 0){
        val2 = 1;
    }
    else if (strcmp(z, "FALSE") == 0){
        val2 = 0;
    }
    else {
        printf("UNCOMPAREABLE\n");
        return "*";
    }

    if (strcmp(x, "GT") == 0) {
        printf("SUCCESS\n");
        return val1 > val2 ? "TRUE" : "FALSE";
    } else if (strcmp(x, "GTE") == 0) {
        printf("SUCCESS\n");
        return val1 >= val2 ? "TRUE" : "FALSE";
    } else if (strcmp(x, "LS") == 0) {
        printf("SUCCESS\n");
        return val1 < val2 ? "TRUE" : "FALSE";
    } else if (strcmp(x, "LSE") == 0) {
        printf("SUCCESS\n");
        return val1 <= val2 ? "TRUE" : "FALSE";
    } else if (strcmp(x, "EQU") == 0) {
        printf("SUCCESS\n");
        return val1 == val2 ? "TRUE" : "FALSE";
    }
}

bool digCheck(char* str) {
    while (*str) {
        if (!isdigit(*str)) {
            return false;
        }
        str++;
    }
    return true;
}

char* toString(int n) {
    int num_digits = snprintf(NULL, 0, "%d", n);
    char* str = (char*)malloc(num_digits + 1);
    if (str != NULL) {
        sprintf(str, "%d", n);
    }
    return str;
}

char* writeChar(char ch) {
    char *ptr = (char*) malloc(sizeof(char));
    if (ptr == NULL) { printf("NULL!\n"); return NULL; }
    *ptr = ch;
    return ptr;
}