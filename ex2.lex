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

<WHILESTATE>{PLUSES}			{	elem *ele = createElem(); ele->action = '+'; ele->value = strlen(yytext);	}
<WHILESTATE>{MINUSES}			{	elem *ele = createElem(); ele->action = '-'; ele->value = strlen(yytext);	}
<WHILESTATE>{RIGHT}				{	elem *ele = createElem(); ele->action = '>';	}	
<WHILESTATE>{LEFT} 				{	elem *ele = createElem(); ele->action = '<';	}
<WHILESTATE>{COMMA_ASCII}		{	elem *ele = createElem(); ele->action = ','; ele->value = atoi(yytext + 1);	}
<WHILESTATE>{COMMA}				{	elem *ele = createElem(); ele->action = ','; ele->value = (int) input();	}
<WHILESTATE>{DOT}				{	elem *ele = createElem(); ele->action = '.';	}
<WHILESTATE>{OPENBRACKET}		{	startWhile(); }
<WHILESTATE>{CLOSINGBRACKET}	{	
									elem *ele = createElem(); 
									ele->action = ']';	
									if (--openBrackets == 0)
									{
										loopFunction();
										BEGIN(INITIAL);
									}
								}


{PLUSES}		{	plus(strlen(yytext));	}
		
{MINUSES}		{ 
					if (!minus(strlen(yytext)))
					{
						return 0;
					}
	  			}
  		
{RIGHT}			{	right();	}

{LEFT}			{	
					if (!left()) 
						return 0;
				}
	  	
{COMMA_ASCII}	{	getChar((char) atoi(yytext + 1));	}
	  	
{COMMA}			{	getChar(input());	}

{DOT}			{	print();	}

{OPENBRACKET}	{	
					char c;
					if (!(*ptr)) 
						while((c = input()) != ']' && openBrackets == 0)
						{
							if (c == '[')
								openBrackets++;
							else if (c == ']')
								openBrackets--;
						}
					else
						startWhile();
				}

{SPACES}		{	/*nothing*/	}

{ALLCHARS}		{	printf("Unknown command\n"); return 0;	/*unknown character*/ } 
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
    elem *ele;
    if ((ele = (elem*) malloc(sizeof(elem))) == NULL)
    {
        printf("\nmalloc error\n");
        return NULL;
    }
    ele->action = 'a';
    ele->next = NULL;
    ele->previous = NULL;
    ele->value = 0;

    if (whileLinkedList == NULL)
    {
        whileLinkedList = ele;
        currentElem = ele;
    }
    else
    {
        if (currentElem == NULL)
        {
            currentElem = whileLinkedList;
        }

        while (currentElem->next != NULL)
            currentElem = currentElem->next;

        currentElem->next = ele;
        ele->previous = currentElem;
        currentElem = ele;
    }

    return ele;
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

    currentElem = createElem();
    currentElem->action = '[';
    if (whileLinkedList == NULL)
    	whileLinkedList = currentElem;
    openBrackets++;
    BEGIN(WHILESTATE);
}

int	loopFunction()
{
    if (whileLinkedList == NULL)
        return 1;
    currentElem = whileLinkedList;
	
    while (currentElem != NULL)
    {
        switch (currentElem->action)
        {
            default:
                break;
            case '[':
                openBrackets++;
                if (!(*ptr))
                {
                	int goal = openBrackets - 1;
                	while (currentElem->action != ']' || openBrackets != goal)
		            {
		                currentElem = currentElem->next;
		                if (currentElem->action == '[')
		                    openBrackets++;
		                else if (currentElem->action == ']')
		                    openBrackets--;
		            }
                }
                break;
            case ']':
                openBrackets -= 2;
                if (!(*ptr))
                    break;
                int goal = openBrackets + 1;
                while (currentElem->action != '[' || openBrackets != goal)
                {
                    currentElem = currentElem->previous;
                    if (currentElem->action == '[')
                        openBrackets++;
                    else if (currentElem->action == ']')
                        openBrackets--;
                }
                break;
            case '+':
                plus(currentElem->value);
                break;
            case '-':
                if (!minus(currentElem->value))
                    return 0;
                break;
            case '>': right();
                break;
            case '<':
                if (!left())
                    return 0;
                break;
            case ',': getChar((char) currentElem->value);
                break;
            case '.': print();
                break;
        }
        currentElem = currentElem->next;
    }
    return 1;
}
