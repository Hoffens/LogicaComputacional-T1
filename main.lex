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

unsigned char Pop(struct Stack *a);
void Push(struct Stack *a, unsigned char c);

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
    unsigned char var; //128

    if (option == 0)    // es delimitador
    {  
        delimiterSymbolAmount++;

        if (delimiterSymbolAmount == 2)     // ya se termino de evaluar la expresion
        {
            // sacamos todo lo de la pila y pusheamos a postfix exp
            
            while (StatusStack(&stack) != EMPTY)   // mientras la pila no este vacia
            {
                unsigned char symbol = Pop(&stack);

                if (symbol != LEFTPARENTHESIS)  // si no es parentesis metemos a postfixexp
                {
                    postfixExp.n++;
                    postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);
                    postfixExp.expression[postfixExp.n - 1] = symbol;
                }
            }
            
            printf("postfix => ");    //imprimir exp en postfix
            for (i = 0; i < postfixExp.n; i++)
            {
                printf("%d ", postfixExp.expression[i]);
            }
            //printf("\n STACK: ");
            
            /*
            while (stack.top != -1)
            {
                unsigned char xd = Pop(&stack);
                printf("%d ", xd);
            }
            */
        }
    } 
    else if (option == 1) // es variable
    {   

        unsigned char exp[yyleng];   
        unsigned char value;
        strcpy(exp, yytext);
        postfixExp.n++;

        // fix it
        char aux;
        int varr=0;
        int c=0;
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

        if (postfixExp.expression == NULL)  // expresion vacia
            postfixExp.expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
        else
            postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);

        postfixExp.expression[postfixExp.n - 1] = var;
        
    } 
    else if (option == 2)   // parentesis izq
    {   
        Push(&stack, LEFTPARENTHESIS);
    }
    
    else if (option == 3)   // parentesis der
    {
        while (StatusStack(&stack) != EMPTY)    // mientras la pila no este vacia
        {
            if (stack.data[stack.top] != LEFTPARENTHESIS) // mientras no encontremos un parentesis izq
            {
                postfixExp.n++;
                postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);
                postfixExp.expression[postfixExp.n - 1] = Pop(&stack);
            }
            else
            {
                Pop(&stack); // encontramos parentesis izq, lo sacamos de la pila
                break;
            }
        }
    } 
    else    // operadores
    {   
        if (option == 4)    // operador negacion
        {
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
                            postfixExp.n++;

                            if (postfixExp.expression == NULL)
                                postfixExp.expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
                            else
                                postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);
                                
                            postfixExp.expression[postfixExp.n - 1] = Pop(&stack);
                        }
                        else   // parentesis izq u operador de menor prioridad
                        {
                            Push(&stack, NEG);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                        Push(&stack, NEG);
                }
            }
            else
            {
                Push(&stack, NEG);
            }  
        }
        else if (option == 5)   // disjuncion, esto tiene codigo repetido
        {
            if (StatusStack(&stack) != EMPTY)
            {
                if (stack.data[stack.top] == LEFTPARENTHESIS || stack.data[stack.top] == RIGHTARROW)
                {
                    Push(&stack, WEDGE);
                }
                else if (stack.data[stack.top] == NEG)    // sacamos la neg del top y la colocamos en la exp.
                {
                    while (StatusStack(&stack) != EMPTY)
                    {   
                        if (stack.data[stack.top] == NEG || stack.data[stack.top] == WEDGE || stack.data[stack.top] == VEE)
                        {
                            postfixExp.n++;

                            if (postfixExp.expression == NULL)
                                postfixExp.expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
                            else
                                postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);

                            postfixExp.expression[postfixExp.n - 1] = Pop(&stack);
                        }
                        else
                        {
                            Push(&stack, WEDGE);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                        Push(&stack, WEDGE);
                }
                else    // wedge o vee
                {
                    while (StatusStack(&stack) != EMPTY)
                    {   
                        if (stack.data[stack.top] == NEG || stack.data[stack.top] == WEDGE || stack.data[stack.top] == VEE)
                        {
                            postfixExp.n++;

                            if (postfixExp.expression == NULL)
                                postfixExp.expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
                            else
                                postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);

                            postfixExp.expression[postfixExp.n - 1] = Pop(&stack);
                        }
                        else
                        {
                            Push(&stack, WEDGE);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                        Push(&stack, WEDGE);
                }
            }
            else
            {
                Push(&stack, WEDGE);
            }
        }
        
        else if (option == 6)   // conjuncion
        {
            if (StatusStack(&stack) != EMPTY)
            {
                if (stack.data[stack.top] == LEFTPARENTHESIS || stack.data[stack.top] == RIGHTARROW)
                {
                    Push(&stack, VEE);
                }
                else if (stack.data[stack.top] == NEG)    // sacamos la neg del top y la colocamos en la exp.
                {
                    while (StatusStack(&stack) != EMPTY)
                    {   
                        if (stack.data[stack.top] == NEG || stack.data[stack.top] == WEDGE || stack.data[stack.top] == VEE)
                        {
                            postfixExp.n++;

                            if (postfixExp.expression == NULL)
                                postfixExp.expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
                            else
                                postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);

                            postfixExp.expression[postfixExp.n - 1] = Pop(&stack);
                        }
                        else // parentesis izq o right arrow
                        {
                            Push(&stack, VEE);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                        Push(&stack, VEE);
                }
                else    // wedge o vee
                {
                    while (StatusStack(&stack) != EMPTY)
                    {   
                        if (stack.data[stack.top] == NEG || stack.data[stack.top] == WEDGE || stack.data[stack.top] == VEE)
                        {
                            postfixExp.n++;

                            if (postfixExp.expression == NULL)
                                postfixExp.expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
                            else
                                postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);

                            postfixExp.expression[postfixExp.n - 1] = Pop(&stack);
                        }
                        else
                        {
                            Push(&stack, VEE);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                        Push(&stack, VEE);
                }
            }
            else
            {
                Push(&stack, VEE);
            }
        }
        else    // implicacion (REVISAR. DEBE ESTAR MAL)
        {
            if (StatusStack(&stack) != EMPTY)
            {
                if (stack.data[stack.top] != LEFTPARENTHESIS)
                {
                    while (StatusStack(&stack) != EMPTY)
                    {   
                        if (stack.data[stack.top] != LEFTPARENTHESIS)
                        {
                            postfixExp.n++;

                            if (postfixExp.expression == NULL)
                                postfixExp.expression = (unsigned char*) malloc(1 * sizeof(unsigned char));
                            else
                                postfixExp.expression = realloc(postfixExp.expression, postfixExp.n);

                            postfixExp.expression[postfixExp.n - 1] = Pop(&stack);
                        }
                        else
                        {
                            Push(&stack, RIGHTARROW);
                            break;
                        }
                    }
                    if (StatusStack(&stack) == EMPTY)
                        Push(&stack, RIGHTARROW);
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
}


/*
 *
 * Verifies Stack Status
 *
 */                            
int StatusStack(struct Stack *a) {

   if (a->top == -1)
      return EMPTY;
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
        a->data = (unsigned char*) malloc(1 * sizeof(unsigned char)); //mejorar
    else
        a->data = realloc(a->data, a->n + 1);

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

   //printf("%d", a->data[a->top]);

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
main() {
    InitStack(&stack);
    yylex();
}  



