%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_WORDS 1000 
struct wordcount {
    char word[100];
    int count;
} words[MAX_WORDS];

int word_total = 0;
void to_lowercase(char *s) {
    for (int i = 0; s[i]; i++) {
        s[i] = tolower((unsigned char) s[i]);
    }
}

void add_word(char *w) {
    to_lowercase(w);
    for (int i = 0; i < word_total; i++) {
        if (strcmp(words[i].word, w) == 0) {
            words[i].count++;
            return;
        }
    }
    strcpy(words[word_total].word, w);
    words[word_total].count = 1;
    word_total++;
}


FILE *yyin;   
%}

%%
[A-Za-z]+    { add_word(yytext); }   
[^A-Za-z\n]+ { }
\n           {  }
%%

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <inputfile>\n", argv[0]);
        exit(1);
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening file");
        exit(1);
    }
    yylex();
    fclose(yyin);

    
    struct wordcount temp;
    for(int i=0;i<word_total;i++){
        for(int j=0;j<word_total-i-1;j++){
            if(words[j].count<words[j+1].count){
                temp= words[j];
                words[j]=words[j+1];
                words[j+1]=temp;
            }
        }
    }

    printf("Word frequencies:\n");
    for (int i = 0; i < word_total; i++) {
        printf("%s : %d\n", words[i].word, words[i].count);
    }
    return 0;
}
int yywrap() {
    return 1;
}
