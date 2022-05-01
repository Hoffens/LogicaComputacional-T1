%{
/*
 * 
 *
 */
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


struct PostfixExpression {
    int n;
    unsigned char *expression;
};


struct Stack stack;
struct PostfixExpression postfixExp;   // expresion infix convertida a postfix
int variablesAmount = 0;
int delimiterSymbolAmount = 0;


// Functions definitions
int StatusStack(struct Stack *a);
void InitStack(struct Stack *a);
unsigned char Pop(struct Stack *a);
void Push(struct Stack *a, unsigned char c);
void InfixToPostfix(int option);
void AddItemToList(struct PostfixExpression *List, unsigned char c);
void AddDisjOrConj(unsigned char c);

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


void InfixToPostfix(int option) {

    unsigned int i;
    unsigned char var; 
    unsigned char exp[yyleng];   
    char aux;
    int varr = 0;
    int c = 0;

    switch (option)
    {
        case 0:     // caso delimitador    ($$)
            delimiterSymbolAmount++;
            if (delimiterSymbolAmount == 2)     // ya se termino de evaluar la expresion
            {
                // sacamos todo lo de la pila y pusheamos a postfix exp
                
                while (StatusStack(&stack) != EMPTY)   // mientras la pila no este vacia
                {
                    var = Pop(&stack);
                    if (var != LEFTPARENTHESIS)  // si no es parentesis metemos a postfixexp
                    {
                        AddItemToList(&postfixExp, var);
                    }
                }
                
                printf("postfix => ");    //imprimir exp en postfix
                for (i = 0; i < postfixExp.n; i++)
                {
                    printf("%d ", postfixExp.expression[i]);
                }
            }
            break;

        case 1:     // caso variable ( v_{1} ... v_{32} )
            strcpy(exp, yytext);
            do
            {
                aux = exp[c];
                if (aux == '{')
                    c++;
                aux = exp[c];

                if(aux >='0' && aux <='9')
                    varr=varr*10+aux-48;

                c++; 
            } while ( aux!='}' );

            var = varr;
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
        a->data = (unsigned char*) malloc(1 * sizeof(unsigned char)); //mejorar
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
 * main function
 *
 */
int main() {
    InitStack(&stack);
    yylex();
    return 0;
}  



