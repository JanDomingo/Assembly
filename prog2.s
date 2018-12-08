*----------------------------------------------------------------------
* Programmer: Jan Domingo
* Class Account: CSSC0797
* Assignment or Title: Assignment #2
* Filename: prog2.s
* Date completed: March 7, 2018
*----------------------------------------------------------------------
* Problem statement: Write a loan payment calculator taking user input
*                    of 1)The principal (P) 2)The APR (r) 3)The length 
*                    of the loan in months (n) then calculate and print 
*                    to the screen the monthly payment amount. Use the
*                    formula to calculate monthly payments
*
*                    P * r(1+r)^n
*                    ------------    <--- Division
*                    (1+r)^n - 1        
*
* Input: Three separate numbers - The principal, APR, and length in months
* Output: Monthly payment as a floating point number
* Error conditions tested: None
* Included files: None
* Method and/or pseudocode: First, when taking the user input, I have to 
*  convert the APR of the user input into a monthly percentage rate in 
*  order to make it work with the formula. I then had to turn that 
*  percentage into a decimal number. Next, I broke up the assignment into
*  chunks. I took the given formula and separated it into sections. 
*  The first step into calculating the formula is calculating (1+r)^n 
*  as that is found in both the numerator and denominator. I then assigned 
*  the value of that calculation into a register. Next, I multiplied that 
*  number by r to get the value of the numerator. Likewise, for the 
*  denominator I took that value but instead subtracted it by one. 
*  I then divided the numerator and denominator then multiplied that value 
*  by P to get the monthly payment value. The last step was to convert that 
*  value into ASCII and output the answer to the user. 
* References: Pindar, lecture, Riggins supplemental book
*----------------------------------------------------------------------
*
        ORG     $0
        DC.L    $3000           * Stack pointer value after a reset
        DC.L    start           * Program counter value after a reset
        ORG     $3000           * Start at location 3000 Hex
*
*----------------------------------------------------------------------
*
#minclude /home/cs/faculty/riggins/bsvc/macros/iomacs.s
#minclude /home/cs/faculty/riggins/bsvc/macros/evtmacs.s
*
*----------------------------------------------------------------------
*
* Register use
*
*----------------------------------------------------------------------
*
start:  initIO                  * Initialize (required for I/O)
        setEVT                  * Error handling routines
        initF                   * For floating point macros only        

        lineout title
        lineout skipln

        lineout pamt
        floatin buffer
        cvtaf   buffer,D1       *(P) Principal of the loan stored at D1

        lineout papr
        floatin buffer
        cvtaf   buffer,D2       *(r) APR stored at D2
        itof    #12,D3
        fdiv    D3,D2           *Converts APR into monthly interest rate
        itof    #100,D3         
        fdiv    D3,D2           *Converts monthly interest rate
                                *from a percentage to a decimal
        move.l  D2,D6           *D6 preserves copy of user input

        lineout plen
        floatin buffer
        cvtaf   buffer,D3       *(n) Length of loan stored at D3


*----------------------------------------------------------------------
*       THIS SECTION WILL CALCULATE (1+r)^n


        itof    #1,D4           *The number 1 is converted from 
                                *an int to a float

        fadd    D4,D2
        fpow    D2,D3
        move.l  D0,D5           *Stores (1+r)^n into D5

        move.l  D6,D2           *Moves the user input APR back to D2
        clr.l   D6

*----------------------------------------------------------------------
*       THIS SECTION WILL CALCULATE THE NUMERATOR (r * (1+r)^n)

        fmul    D5,D2           *D2 now holds the numerator

*----------------------------------------------------------------------
*       THIS SECTION WILL CALCULATE THE DENOMINATOR (1+r)^n - 1)

        fsub    D4,D5           *D5 now holds the denominator

*----------------------------------------------------------------------
*       THIS SECTION WILL DIVIDE THE NUMERATOR AND DENOMINATOR

*       (r * (1+r)^n)   -> D2
*       -------------
*       (1+r)^n - 1     -> D5

        fdiv    D5,D2   *The calculation is now stored in D2

*----------------------------------------------------------------------
*       THIS IS THE FINAL STEP OF CALCULATION AND WILL MULTIPLY (P)
*       THE PRINCIPAL 

*             r(1+r)^n
*       p *  -----------    
*            (1+r)^n - 1

        fmul    D1,D2           *The floating point value of the monthly
                                *payment is stored in D2

*----------------------------------------------------------------------
*       THIS STEP WILL CONVERT THE FLOATING POINT VALUE OF THE MONTHLY
*       PAYMENT AND CONVERT IT INTO ASCII AND OUTPUTS THE VALUE

        move.l  D2,D0
        cvtfa   paymnt,#2
        lineout answer

        break                   * Terminate execution
*
*----------------------------------------------------------------------
*       Storage declarations

title:  dc.b    'Program #2, Jan Domingo, CSSC0797',0
skipln  dc.b    0
pamt:   dc.b    'Enter the amount of the loan:',0               *Prompt - Amount
papr:   dc.b    'Enter the annual percentage rate:',0           *Prompt - APR
plen:   dc.b    'Enter the length of the loan in months',0      *Prompt - Length
buffer: ds.b    80
answer: dc.b    'Your monthly payment will be '
paymnt: ds.b    20

        end
