run: compile
	./a.out

compile: flex
	gcc lex.yy.c

flex:
	flex ./ex2.lex

