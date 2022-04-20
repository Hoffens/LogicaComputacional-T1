%{
/*
 * 
 *
 */

#define MAXSIZE 6
#define EMPTY   0
#define NORMAL  1
#define FULL    2

struct Stack {
    char data[MAXSIZE];
    int top;
};

struct Stack s;

int variables = 0;
int isfinalexpression = 0;

%}

leftparenthesis \(
rightparenthesis \)
negation \\neg
disjunction \\wedge
conjuction \\vee
implication \\rightarrow
variable [a-z]_\{[1-9][0-9]*\}
delimitersymbol ${2}

%%

{variable}            printf("%d", 10);
{leftparenthesis}     printf("%d", 100);
{delimitersymbol}     Postfix(0);

%%

void Postfix(int option) {

    if (option == 0) {
        isfinalexpression++;
    }
    // option = 0 es cuando se lee delimitersymbol
    // como sabemos cuando se termina la expresion? r: con delimitersymbol (si lo encuentra por 2da vez)

    // en caso de variable:
    // si la matriz está vacía o la variable no está en la matriz: se aumenta el contador y se introduce
    // en caso de operador:
    // si el stack está vacío o el operador es un leftparenthesis se hace push en el stack
    // comparamos la prioridad del operador que viene con el del top del stack
    // si el top del stack es un leftparenthesis hacemos push al operador que viene
    // si el top del stack tiene menor prioridad, hacemos push al operador que viene
    // si el top del stack tiene mayor prioridad, hacemos pop al top del stack hasta que encontremos un operador (dentro del stack)
    // con mayor prioridad que el que viene o hasta que la pila esté vacía
    
}

/*
 *
 * Initializes Stack 
 *
 */
void InitStack(struct Stack *a) {

   a->top = -1;
}

/*
 *
 * Add Element to Stack
 *
 */
void Push(struct Stack *a, char c) {

   a->top++;
   a->data[a->top] = c;
}
 
/*
 *
 * Remove first Element
 *
 */
char Pop(struct Stack *a) {

   char c;

   c = a->data[a->top];
   a->top--;
   return c;
}

/*
 *
 * main function
 *
 */
main() {

   InitStack(&s);
   yylex();
}  



