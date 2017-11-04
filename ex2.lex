/*
 * Name:	 Tomer Gill
 * ID:		 318459450
 * Group:	 05
 * Username: gilltom
 */

%{
	#include <stdio.h>
    #include <stdlib.h>
	
	#define INFINITELY_LARGE_SIZE 2048
	
	typedef struct elm {
		char action;
		int value; //can be either a char for input or a number for +/-
		struct elm *next;
		struct elm *previous;
	} elem;

	char array[INFINITELY_LARGE_SIZE] = {0};
	char *ptr = array;
	int openBrackets = 0;
	elem *whileLinkedList = NULL, *currentElem = NULL;

	void    plus(int n);
	int     minus(int n);
	int     left();
	void    right();
	void    getChar(char c);
	void    print();
	elem*   createElem();
	void    freeWhileList();
	void    startWhile();
	int		loopFunction();
%}

/*ALIASES*/
PLUSES 			("+")+
MINUSES 		("-")+
RIGHT 			">"
LEFT 			"<"
COMMA_ASCII		,[0-9]+
COMMA 			,
DOT 			"."
SPACES 			" "|\n
ALLCHARS 		.
OPENBRACKET		"["
CLOSINGBRACKET	"]"

/*STATES*/
%s WHILESTATE

%option noyywrap

%%

{PLUSES}		{	plus(strlen(yytext));	}
		
{MINUSES}		{ 
					if (!minus(strlen(yytext)))
					{
						return 0;
					}
	  			}
  		
{RIGHT}			{	right();	}

{LEFT}			{	!left() ? return 0;	}
	  	
{COMMA_ASCII}	{	getChar((char) atoi(yytext + 1));	}
	  	
{COMMA}			{	getChar(input());	}

{DOT}			{	print();	}

{OPENBRACKET}	{	
					if (!(*ptr)) 
						while(input() != ']');
					else
						startWhile();
					
				}

{SPACES}		{	/*nothing*/	}

{ALLCHARS}		{	printf("Unknown command\n"); return 0;	/*unknown character*/ } 


<WHILESTATE>{PLUSES}			{	elem *ptr = createElem(); ptr.action = '+'; ptr.value = strlen(yytext);	}
<WHILESTATE>{MINUSES}			{	elem *ptr = createElem(); ptr.action = '-'; ptr.value = strlen(yytext);	}
<WHILESTATE>{RIGHT}				{	elem *ptr = createElem(); ptr.action = '>';	}	
<WHILESTATE>{LEFT} 				{	elem *ptr = createElem(); ptr.action = '<';	}
<WHILESTATE>{COMMA_ASCII}		{	elem *ptr = createElem(); ptr.action = ','; ptr.value = atoi(yytext + 1);	}
<WHILESTATE>{COMMA}				{	elem *ptr = createElem(); ptr.action = ','; ptr.value = (int) input();	}
<WHILESTATE>{DOT}				{	elem *ptr = createElem(); ptr.action = '.';	}
<WHILESTATE>{OPENBRACKET}		{	startWhile(); }
<WHILESTATE>{CLOSINGBRACKET}	{	
									elem *ptr = createElem(); 
									ptr.action = ']';	
									if (--openBrackets == 0)
									{
										loopFunction();
										BEGIN(INITIAL);
									}
								}
%%

int main()
{
    yylex();
    freeWhileList();
}

void plus(int n)
{
    *ptr += n;
}

int minus(int n)
{
    if ((*ptr -= n) < 0)
    {
        printf("\nInvalid – command\n");
        return 0;
    }
    return 1;
}

int left()
{
    if (--ptr < array)
    {
        printf("\nIndex Out Of Range\n");
        return 0;
    }
    return 1;
}

void right()
{
    ptr++;
}

void getChar(char c)
{
    *ptr = c;
}

void print()
{
    printf("%c", *ptr);
}

elem* createElem()
{
    elem *ptr;
    if ((ptr = (elem*) malloc(sizeof(elem))) == NULL)
    {
        printf("\nmalloc error\n");
        return NULL;
    }
    ptr->action = '\0';
    ptr->next = NULL;
    ptr->previous = NULL;
    ptr->value = 0;

    if (whileLinkedList == NULL)
    {
        whileLinkedList = ptr;
        currentElem = ptr;
    }
    else
    {
        if (currentElem == NULL)
        {
            currentElem = whileLinkedList;
        }

        while (currentElem->next != NULL)
            currentElem = currentElem->next;

        currentElem->next = ptr;
        ptr->previous = currentElem;
        currentElem = ptr;
    }

    return ptr;
}

void freeWhileList()
{
    while (whileLinkedList != NULL)
    {
        elem *temp = whileLinkedList;
        whileLinkedList = whileLinkedList->next;
        free(temp);
    }
}

void startWhile()
{
    if (!openBrackets && whileLinkedList != NULL)
        freeWhileList();

    whileLinkedList = createElem();
    whileLinkedList->action = '[';
    currentElem = whileLinkedList;
    openBrackets++;
    BEGIN(WHILESTATE);
}
