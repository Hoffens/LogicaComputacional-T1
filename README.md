##Para compilar:

1. flex main.lex
2. gcc -o source.exe lex.yy.c -ll -lm   // con biblioteca math.h

* * *

##Para ejecutar:
1. ./source.exe -V < archivo.txt   // ejecuta el programa en modo verboso
2. ./source.exe -S < archivo.txt   // ejecuta el programa en modo silence

* * *

##Formato de archivos:
1. Las expresiones escritas en los archivos .txt deben comenzar y terminar con $$ y las variables se denotan como v_{1}, v_{2} ... v_{32}(como se escribiría una expresión en latex).


**Ej:**

$$(((v_{1} \rightarrow v_{2} ) \vee (v_{1} \vee \neg v_{3} )) \vee (v_{3} \rightarrow v_{1} )) \vee (\neg v_{1} \rightarrow v_{2} )$$
