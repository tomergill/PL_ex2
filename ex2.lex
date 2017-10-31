%{
	#include <stdio.h>
	
	#define INFINITELY_LARGE_SIZE 4096
	
	char array[INFINITELY_LARGE_SIZE] = {0};
	char *ptr = array;
%}
%option noyywrap

%%

("+")+	{ 
			*ptr += strlen(yytext); 
		}
		
("-")+	{ 
			int n = strlen(yytext); 
			if ((*ptr -= n) > 0)
			{
				printf("Invalid – command\n");
				return 0;
			}
	  	}
  		
">"		{	++ptr;	}

"<"		{
			if (--ptr < array)
			{
				printf("Index Out Of Range\n");
				return 0;
			}
	  	}
	  	
","		{	*ptr = input();	}

"."		{	printf("%c", *ptr);	}

" "|\n	{	/*nothing*/	}

.		{	printf("Unknown command\n"); return 0;	}

%%

int main(){
    yylex();
    printf("\n");
}

