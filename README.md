Para compilar:

1- flex main.lex
2- gcc -o source.exe lex.yy.c -ll -lm   // con biblioteca math.h
3- ./source.exe -V < archivo.txt   // ejecuta el programa en modo verboso
4- ./source.exe -S < archivo.txt   // ejecuta el programa en modo silence

Formato de archivos
Las expresiones escritas en los archivos .txt deben comenzar y terminar con $$ (como se escribiría una expresión en latex).

Ej:

$$(((v_{1} \rightarrow v_{2} ) \vee (v_{1} \vee \neg v_{3} )) \vee (v_{3} \rightarrow v_{1} )) \vee (\neg v_{1} \rightarrow v_{2} )$$
