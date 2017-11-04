//
// Created by tomer on 04/11/17.
//

#include <stdio.h>
#include <stdlib.h>

#define INFINITELY_LARGE_SIZE 4096

//typedef enum {PLUS, MINUS, LEFT, RIGHT, INPUT, PRINT, WHILE, END_WHILE} ACTION;

typedef struct elm {
    //ACTION action;
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
void    getASCII(char *ASCIString);
void    getChar(char c);
void    print();
elem*   createElem();
void    freeWhileList();
void    startWhile();

/*************%%******************/
void plus(int n)
{
    *ptr += n;
}

int minus(int n)
{
    if ((*ptr -= n) < 0)
    {
        printf("Invalid – command\n");
        return 0;
    }
    return 1;
}

int left()
{
    if (--ptr < array)
    {
        printf("Index Out Of Range\n");
        return 0;
    }
    return 1;
}

void right()
{
    ptr++;
}

void getASCII(char *ASCIString)
{
    *ptr = (char) atoi(ASCIString);
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