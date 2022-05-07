%{
/*
 * Define if a logical expression is tautology, contradiction or contigency
 *
 * Authors: Nicolás Fernández Reinoso, Gino Verardi Maturana
 *
 * Santiago de Chile, 06/05/2022
 *
 */

#include <math.h>
#define EMPTY   0
#define NORMAL  1
#define LEFTPARENTHESIS 35
#define RIGHTPARENTHESIS 36
#define NEG 37
#define VEE 38
#define WEDGE 39
#define RIGHTARROW 40


struct Stack {
    int n;
    int top;
    unsigned char *data;
};


struct StackValue {
    int n;
    int top;
    unsigned int *data;
};


struct PostfixExpression {
    int n;
    unsigned char *expression;
};


// Global variables
struct Stack stack;
struct StackValue stackValue;

struct PostfixExpression postfixExp;   // expresion infix convertida a postfix
int variablesAmount = 0;
int delimiterSymbolAmount = 0;
int isVerboseMode = 0;


// Functions definitions
int StatusStack(struct Stack *a);
void InitStack(struct Stack *a);
unsigned char Pop(struct Stack *a);
void Push(struct Stack *a, unsigned char c);
void AddItemToList(struct PostfixExpression *List, unsigned char c);
void AddDisjOrConj(unsigned char c);
void InfixToPostfix(int option);
void EvaluatePostfix();
unsigned int valor(unsigned int fila, unsigned int var);


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
{delimitersymbol}           InfixToPostfix(0);
{variable}                  InfixToPostfix(1);
{leftparenthesis}           InfixToPostfix(2);
{rightparenthesis}          InfixToPostfix(3);
{negation}                  InfixToPostfix(4);
{disjunction}               InfixToPostfix(5);
{conjuction}                InfixToPostfix(6);
{implication}               InfixToPostfix(7);
%%


/*
 *
 * Verifies Stack Status
 *
 */                            
int StatusStack(struct Stack *a) {

   if (a->top == -1)
   {
      return EMPTY;
   }
   return NORMAL;
}

/*
 *
 * Initializes Stack 
 *
 */
void InitStack(struct Stack *a) {

   a->top = -1;
   a->n = 0;
}

/*
 *
 * Add Element to Stack
 *
 */
void Push(struct Stack *a, unsigned char c) {

    if (a->data == NULL)
    {
        a->data = (unsigned char*) malloc(1 * sizeof(unsigned char)); 
    }
    else
    {
        a->data = realloc(a->data, a->n + 1);
    }

    a->n++;
    a->top++;
    a->data[a->top] = c;
}
 
/*
 *
 * Remove first Element
 *
 */
unsigned char Pop(struct Stack *a) {

   unsigned char c;

   c = a->data[a->top];
   a->top--;
   a->n--;

   a->data = realloc(a->data, a->n);

   return c;
}


/*
 *
 * Verifies StackValue Status
 *
 */                            
int StatusStackValue(struct StackValue *a) {

   if (a->top == -1)
   {
      return EMPTY;
   }
   return NORMAL;
}

/*
 *
 * Initializes Stack 
 *
 */
void InitStackValue(struct StackValue *a) {

   a->top = -1;
   a->n = 0;
}

/*
 *
 * Add Element to Stack
 *
 */
void PushStackValue(struct StackValue *a, unsigned int c) {

    if (a->data == NULL)
    {
        a->data = (unsigned int*) malloc(1 * sizeof(unsigned int)); 
    }
    else
    {
        a->data = realloc(a->data, a->n + 1);
    }

    a->n++;
    a->top++;
    a->data[a->top] = c;
}
 
/*
 *
 * Remove first Element
 *
 */
unsigned int PopStackValue(struct StackValue *a) {

   unsigned int c;

   c = a->data[a->top];
   a->top--;
   a->n--;

   a->data = realloc(a->data, a->n);

   return c;
}


/*
 *
 * Add an item to a PostfixExpression list
 *
 */ 
void AddItemToList(struct PostfixExpression *List, unsigned char c)
{
    List->n++;

    if (List->expression == NULL)
    {
        List->expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
    }
    else
    {
        List->expression = realloc(List->expression, List->n);
    }

    List->expression[List->n - 1] = c;
}

/*
 *
 * Add a disjunction or conjunction to a PostfixExpression list
 *
 */ 
void AddDisjOrConj(unsigned char c)
{   
    
    unsigned char var;

    if (StatusStack(&stack) != EMPTY)
    {
        if (stack.data[stack.top] == LEFTPARENTHESIS || stack.data[stack.top] == RIGHTARROW)
        {
            Push(&stack, c);
        }
        else    // sacamos la neg del top y la colocamos en la exp.
        {
            while (StatusStack(&stack) != EMPTY)
            {   
                if (stack.data[stack.top] != LEFTPARENTHESIS && stack.data[stack.top] != RIGHTARROW)
                {
                    var = Pop(&stack);
                    AddItemToList(&postfixExp, var);
                }
                else
                {
                    Push(&stack, c);
                    break;
                }
            }

            if (StatusStack(&stack) == EMPTY)
            {
                Push(&stack, c);
            }
        }
    }
    else
    {
        Push(&stack, c);
    }
}

/*
 *
 * Converts an expression from infix to postfix notation
 *
 */ 
void InfixToPostfix(int option) {

    unsigned int i, varr, exists;
    unsigned char var, aux, exp[yyleng];    

    switch (option)
    {
        case 0:     // caso delimitador ($$)
            delimiterSymbolAmount++;
            if (delimiterSymbolAmount == 2)     // ya se termino de evaluar la expresion
            {
                // sacamos todo lo de la pila y pusheamos a postfixExp
                while (StatusStack(&stack) != EMPTY)   // mientras la pila no este vacia
                {
                    var = Pop(&stack);
                    if (var != LEFTPARENTHESIS)  // si no es parentesis agregamos a postfixexp
                    {
                        AddItemToList(&postfixExp, var);
                    }
                }
                
                printf("\n postfix => ");    //imprimir exp en postfix
                for (i = 0; i < postfixExp.n; i++)
                {
                    printf("%d ", postfixExp.expression[i]);
                }
                printf("\n cant. variables: %d", variablesAmount);
                printf("\n");
                EvaluatePostfix();
            }
            break;

        case 1:     // caso variable ( v_{1} ... v_{32} )
            var = 0; 
            i = 0;
            strcpy(exp, yytext);

            do
            {
                aux = exp[i];
                if (aux == '{')
                    i++;
                aux = exp[i];

                if(aux >='0' && aux <='9')
                    var = var*10 + aux-48;

                i++; 
            } while (aux != '}');

            exists = 0;
            for (i = 0; i < postfixExp.n; i++)
            {
                if (postfixExp.expression[i] == var)
                {
                    exists = 1;
                    break;
                }
            }

            if (exists == 0)
            {
                variablesAmount++;
            }

            AddItemToList(&postfixExp, var);
            break;

        case 2:     // caso parentesis izquierdo
            Push(&stack, LEFTPARENTHESIS);
            break;

        case 3:     // caso parentesis derecho 
            while (StatusStack(&stack) != EMPTY)    // mientras la pila no este vacia
            {
                if (stack.data[stack.top] != LEFTPARENTHESIS) // mientras no encontremos un parentesis izq
                {
                    var = Pop(&stack);
                    AddItemToList(&postfixExp, var);
                }
                else
                {
                    Pop(&stack); // encontramos parentesis izq, lo sacamos de la pila
                    break;
                }
            }
            break;

        case 4:     // caso negacion (\neg)
            if (StatusStack(&stack) != EMPTY)
            {
                if (stack.data[stack.top] != NEG)   
                {
                    Push(&stack, NEG);
                }
                else    // sacamos de la pila hasta que encontremos algo distinto de neg o pila sea vacia
                {
                    while (StatusStack(&stack) != EMPTY)
                    {
                        if (stack.data[stack.top] == NEG) 
                        {
                            var = Pop(&stack);
                            AddItemToList(&postfixExp, var);
                        }
                        else   // parentesis izq u operador de menor prioridad
                        {
                            Push(&stack, NEG);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                    {
                        Push(&stack, NEG);
                    }
                }
            }
            else
            {
                Push(&stack, NEG);
            }
            break;

        case 5:     // caso disjuncion (\wedge)
            AddDisjOrConj(WEDGE);
            break;

        case 6:     // caso conjuncion (\vee)
            AddDisjOrConj(VEE);
            break;

        default:    // caso implicacion (\rightarrow)
            if (StatusStack(&stack) != EMPTY)
            {
                if (stack.data[stack.top] != LEFTPARENTHESIS)
                {
                    while (StatusStack(&stack) != EMPTY)
                    {   
                        if (stack.data[stack.top] != LEFTPARENTHESIS)
                        {
                            var = Pop(&stack);
                            AddItemToList(&postfixExp, var);
                        }
                        else
                        {
                            Push(&stack, RIGHTARROW);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                    {
                        Push(&stack, RIGHTARROW);
                    }
                }
                else
                {
                    Push(&stack, RIGHTARROW);
                }
            }
            else
            {
                Push(&stack, RIGHTARROW);
            }
    }
}

/*
 *
 * Evaluate a postfix expression
 *
 */ 
void EvaluatePostfix()
{
    unsigned int i, row, pos, negAmount = 0, value1 = 0, value2 = 0, value3 = 0;
    unsigned long rowsAmount;
    unsigned char c;

    rowsAmount = (unsigned long)pow(2, variablesAmount);   // cant. de filas de la tabla de verdad

    // recorremos toda la expresion en postfix
    /*
    for (int i = 0; i < rowsAmount; i++)
    {
        for (int j = 0; j < variablesAmount; j++)
        {
            printf("%d ", i >> j & 1);
            //printf("%d \n ", i >> j);
        }
        printf("\n");
    }
        printf("\n");
        */
    for (i = 0; i < postfixExp.n; i++)
    {
        value1 = 0;
        value2 = 0;
        value3 = 0;
        if (postfixExp.expression[i] < NEG)     // si el simbolo es operando
        {   
            unsigned int pos;

            if (postfixExp.expression[i] == variablesAmount)
                pos = 0;
            else if (postfixExp.expression[i] - 1 == 0)
                pos = variablesAmount - 1;
            else
                pos = postfixExp.expression[i] - 1;

            if (negAmount > 0 && negAmount % 2 != 0)
            {
                value1 = ~value1;   // son solo 1's
                for (row = 0; row < rowsAmount; row++)
                {   
                    if (row & (1 << pos))   // si el bit en la columna pos está encendido
                    {
                        value1 = value1 ^ (1 << row);   // lo dejamos apagado en value1
                    }
                }
                value1 = ~value1;
                negAmount = 0;
            }
            else
            {
                value1 = ~value1;   // son solo 1's
                for (row = 0; row < rowsAmount; row++)
                {   
                    if (row & (1 << pos))   // si el bit en la columna pos está encendido
                    {
                        value1 = value1 ^ (1 << row);   // lo dejamos apagado en value1
                    }
                }
            }
            PushStackValue(&stackValue, value1);
        }
        else    // si el simbolo es un operador
        {
            value3 = 0;
            if (postfixExp.expression[i] == NEG)
            {
                if (StatusStackValue(&stackValue) != EMPTY)
                {
                    value1 = PopStackValue(&stackValue);
                    PushStackValue(&stackValue, ~value1);    
                }
                else
                {
                    negAmount++;
                }
            }
            else    // operador distinto a NEG
            {   
                value1 = PopStackValue(&stackValue);
                value2 = PopStackValue(&stackValue);

                if (postfixExp.expression[i] == WEDGE) // wedge (y logico)
                {   
                    for (row = 0; row < rowsAmount; row++)
                    {
                        if (value1 & (1 << row) && value2 & (1 << row)) // si ambos bits están encendidos
                        {
                            value3 = value3 ^ (1 << row);   // negamos el bit (lo encendemos) en la posicion row de value3
                        }
                    }
                    PushStackValue(&stackValue, value3);
                }
                else if (postfixExp.expression[i] == VEE) // vee (o logico)
                {    
                    value3 = 0;
                    value3 = ~value3; // son solo 1's
                    for (row = 0; row < rowsAmount; row++)
                    {
                        if (!(value1 & (1 << row) || value2 & (1 << row))) // si ninguno está encendido
                        {
                            value3 = value3 ^ (1 << row);   // apagamos el bit en posicion row
                        } 
                    }
                    PushStackValue(&stackValue, value3);
                }
                else    // rightarrow (implicacion)
                {   
                    value3 = 0;
                    value3 = ~value3;   // son solo 1's
                    for (row = 0; row < rowsAmount; row++)
                    {
                        if (value2 & (1 << row)) // si el bit en la posicion row de value2 está encendido
                        {
                            if (!(value1 & (1 << row))) // si el bit en la posicion row de value1 esta apagado
                                value3 = value3 ^ (1 << row);   // apagamos el bit en posicion row
                        }
                    }
                    PushStackValue(&stackValue, value3);
                }
            }
        }
    }
    value3 = PopStackValue(&stackValue);
    i = 0;
    int x = 0;
    int y = 0;
    printf("\n");

    for (int j = 0; j < rowsAmount; j++)
    {
        printf("%d ", value3 >> j & 1);
        //printf("%d \n ", i >> j);
    }

    printf("\n");

    for (row = 0; row < rowsAmount; row++)
    {   
        if (value3 & (1 << row)) // si el bit está encendido
        {   
            if (x > 0)
            {
                printf("Contingencia");
                y = 1;
                break;
            }
            else
            {
                i++;    // cantidad de verdaderos            
            }
        }
        else
        {
            if (i > 0)
            {
                printf("Contingencia");
                y = 1;
                break;
            }
            else
            {
                x++;
            }
        }
    }
    if (y != 1)
        if (i > x)
            printf("Tautología");
        else
            printf("Contradicción");
}


unsigned int valor(unsigned int fila, unsigned int var){
    unsigned int val=0;
    val=(~val-pow(2 ,var));
    if(~val & fila)
        return 1;
    return 0;
}

/*
 *
 * main function
 *
 */
 

int main(int argc, char *argv[]) {
    //EvaluatePostfix(arg) // S o V
        
        
        
            if(argv [1][0]=='-'){
                if(argv [1][1]=='S')
                    isVerboseMode=0;
                if(argv [1][1]=='V')    
                    isVerboseMode=1;
                    }
        
    printf("verboso: %d \n", isVerboseMode);
    InitStack(&stack);
    InitStackValue(&stackValue);
    yylex();
    return 0;
}  



