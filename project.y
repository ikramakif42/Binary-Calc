%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <ctype.h>

    void yyerror(char *msg);
    extern int yyparse();

    bool hasVal(char);
    void setVal(char, int);
    int getVal(char);
    int doOp(char*, int, int);
    void doPrint(char*);
    char* doComp(char* x, char* y, char* z);
    bool digCheck(char*);
    char* toString(int);

    int symbol_table[100][2];
    int symbol_count = 0;
    int i = 0;
    char cval;
    int a;
    int b;
%}

%union{
    int i;
    char* s;
    char c;
}

%token NEWLINE
%token <i> NMBR
%token <s> ASGN GT GTE LS LSE EQU PRINT ADD SUB MUL
%token <c> ID CM

%type <s> S E VAL BOOL COMP OP PR
%type <i> NUM
%type <c> IDR

%%

    S       :   S E NEWLINE         {  }
            |   E NEWLINE           {  }
            ;

    E       :   VAL                 { $$ = $1; }
            |   PR                  { $$ = $1; }
            ;

    VAL     :   IDR                 { 
                                        if (!hasVal($1)) { $$ = "*"; }
                                        else { $$ = ""; $$[0] = $1; }
                                    }
            |   NUM                 { $$ = toString($1); }
            |   BOOL                { $$ = $1; }
            ;
    
    IDR     :   ID                  { $$ = $1; }
            |   ASGN IDR CM NUM     { $$ = $2; setVal($2, $4); printf("SUCCESS\n"); }
            |   OP IDR CM NUM       {   
                                        $$ = $2;
                                        if (!hasVal($2)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $2); }
                                        else { setVal($2, doOp($1, getVal($2), $4)); }
                                    }
            |   OP NUM CM IDR       {   
                                        $$ = $2;
                                        if (!hasVal($4)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $4); }
                                        else { setVal($2, doOp($1, $2, getVal($4))); }
                                    }
            |   OP IDR CM IDR       {   
                                        $$ = $2;
                                        if (!hasVal($2)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $2); }
                                        else if (!hasVal($4)) { $$ = 42; printf("NO VAL ASSIGNED TO %c\n", $4); }
                                        else { setVal($2, doOp($1, getVal($2), getVal($4))); }
                                    }
            ;
    
    NUM     :   OP NUM CM NUM       {
                                        $$ = doOp($1, $2, $4);
                                    }
            |   NMBR                { $$ = $1; }//printf("NUMBER %d\n", $1); }
            ;

    OP      :   ADD                 { $$ = $1; }
            |   SUB                 { $$ = $1; }
            |   MUL                 { $$ = $1; }

    BOOL    :   COMP VAL CM VAL     { $$ = doComp($1, $2, $4); }
            ;
        
    COMP    :   GT                  { $$ = $1; }
            |   GTE                 { $$ = $1; }
            |   LS                  { $$ = $1; }
            |   LSE                 { $$ = $1; }
            |   EQU                 { $$ = $1; }

    PR      :   PRINT E             { 
                                        $$ = $2;
                                        doPrint($2);
                                    }

%%

void yyerror(char *msg){
    fprintf(stderr, "%s\n", msg);
    exit(1);
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
    printf("Now, ID: %i\n", symbol_table[symbol_count][0]);
    printf("and Val: %i\n", symbol_table[symbol_count][1]);
    symbol_table[0][0] = (int) id;
    symbol_table[0][1] = (int) value;
    printf("Now, ID: %i\n", symbol_table[symbol_count][0]);
    printf("and Val: %i\n", symbol_table[symbol_count][1]);
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
}

void doPrint(char* val) {
    if (strcmp(val, "*") == 0) {
        val = "NO VAL ASSIGN TO X";
        printf("%s\n", val);
    }
    else if (strlen(val) > 1 || (*val >= '0' && *val <= '9')){
        printf("PRINTING %s\n", val);
    }
    else {
        cval = (char) val[0];
        printf("PRINTING %c ", cval);
        printf("%d\n", getVal(cval));
    }
}

char* doComp(char* x, char* y, char* z) {
    printf("COMP TIME\n");
    return "SUCCESS";
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