*----------------------------------------------------------------------
* Programmer: Jan Domingo
* Class Account: cssc0797
* Assignment or Title: Assignment 3
* Filename: prog3.s
* Date completed: April 18, 2018
*----------------------------------------------------------------------
* Problem statement: Become familiar with flow control in assembler. 
* You will accept a currency input and then you will output the appropriate
* list of bills and coins equal to the input amount
* Input: A decimal number 
* Output: A list of bills and coins equal to the input amount
* Error conditions tested: Input no less than 0.01 and no greater than 
* 32,767.99. Also checks for invalid entries such as letters and symbols
* that is not a decimal
* Included files: None
* Method and/or pseudocode: Take the user input and split it up into two 
* categories: whole numbers and decimals. Check for whole numbers using
* a loop and store them into an adress register. After detecting a decimal
* point, store following decimal numbers into a different address register.
* Error checking occurs while sorting these numbers into their address 
* registers. Then develop an algorithm to sort out how many bills/cents
* are needed. This is done by starting from the largest bill, and dividing
* until all bills are calculated. Then do the same for cents. Lastly, move the numbers
* into the arry and output the following strings with values in them. 
* References: pindar.sdsu.edu/cs237/prog3.php, Lecture Notes, CS 237 Course Reader
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
*       D1 = Length of the user input
*       D2 = First used as loop counter for decimals then stores the 
*            whole number 2's comp
*       D3 = Stores decimal number 2's comp
*       A0 = Stores beginning address of original user input
*       A1 = Used to copy user input into other address registers
*       A2 = Stores the whole numbers
*       A4 = Address for the Array
*       A5 = Convert to 2's complement for decimal numbers
*       
*----------------------------------------------------------------------
*
start:  initIO                  * Initialize (required for I/O)
        setEVT                  * Error handling routines
*       initF                   * For floating point macros only        

        lineout title

begin:  clr.l   D2              *Resets number to 0 from previously stored whole number
        clr.l   buffer
        clr.l   buffer+4        *Ensures buffer is cleared from previous inputs
        clr.l   buffer+8        *with large numbers
        clr.l   whole           
        clr.l   whole+4
        clr.l   decsto
        clr.l   decsto+4

        lineout skipln
        lineout prompt

        linein  buffer
        stripp  buffer,D0       
        move.l  D0,D1           *D1 stores the input length incl. decimal       

        lea     buffer,A0       *A0 stores a copy of the original buffer
        lea     buffer,A1       
        lea     whole,A2
*----------------------------------------------------------------------
* THIS SECTION BELOW VALIDATES THE USER INPUT

check:  cmpi.b  #'.',(A1)       *Checks until there is a decimal
        beq     dec
        cmpi.b  #00,(A1)        *Checks for null terminator
        beq     algrtm
        cmpi.b  #'0',(A1)       *Checks for values less than zero
        blt     err
        cmpi.b  #'9',(A1)       *Checks for values greater than 9
        bgt     err
        move.b  (A1)+,(A2)+     *Values are moved into (A2)
        bra     check           

dec:    lea      decsto,A5      *Assigns spot in memory so it doesn't override (A2)
decl:   adda.w  #1,A1           *Skips over the decimal
        cmpi.b  #00,(A1)        *Similar to error checking method above,
        beq     decac           *except this is for decimals
        cmpi.b  #'0',(A1)
        blt     err
        cmpi.b  #'9',(A1)
        bgt     err
        move.b  (A1),(A5)+      *Adress A5 will store the decimal
        addi.w  #1,D2           *Adds one to the loop counter
        bra     decl

decac:  cmpi.b  #2,D2           *Stands for 'decimal-additional check'  
        blt     err             *This loops checks if the user input
        cmpi.b  #2,D2           *Has less than or greater than 2 decimal
        bgt     err             *points
        cmpi.b  #2,D2
        beq     dfix    

err:    lineout error
        bra     begin

*----------------------------------------------------------------------
* THIS SECTION BELOW IS THE ALGORITHM CALCULATION

dfix:   suba.w  #2,A5           *Points to the beginning of the decimals
        cvta2   (A5),#2         *Converts decimals to 2's comp
        move.l  D0,D3           *Stores 2's comp decimals to D3
        subi.b  #3,D1           *Fixes D1 so that it is the length of only whole numbers

algrtm: lea     array,A4        *We will be modifying A4 for the lineout statement
        suba.l  D1,A2
        cvta2   (A2),D1
        move.l  D0,D2           *D2 now holds the 2's comp number of the whole number input
        cmpi.l  #32767,D2
        bgt     err
        lineout skipln
        lineout output

loop:   cmpi.w  #100,D2
        bge     hun
        cmpi.w  #50,D2
        bge     fif
        cmpi.w  #20,D2
        bge     twent
        cmpi.w  #10,D2
        bge     ten
        cmpi.w  #5,D2
        bge     five
        cmpi.w  #1,D2
        bge     one
        bra     decal           *Once no more dollars branch to decal, 'decimal algorithm loop'

hun:    divu.w  #100,D2         *D2 holds the amount of $100 bills in 2's comp
        move.w  D2,D0           *Moves to D0 for cvt2a macro
        cmpi.w  #3,D1
        bgt     big
        adda.w  #2,A4           *Cvt2a and striips properly for input divisible by 100
        cvt2a   (A4),#1
        stripp  (A4),#1         
        suba.w  #2,A4
        lineout array+2         *Adds two so it doesn't lineout spaces before value
        bra     hunout
big:    cmpi.w  #4,D1           *Cvt2a and stripps properly for input divisible by 1000 
        bgt     bigger
        adda.w  #1,A4
        cvt2a   (A4),#2
        stripp  (A4),#2
        suba.w  #1,A4
        lineout array+1
        bra     hunout  
bigger: cvt2a   (A4),#3         *Cvt2a and stripps properly for input divisible by 10000
        stripp  (A4),#3
        lineout array
hunout: clr.w   D2              
        swap    D2              *Takes the remainder and uses that to determine next bill
        bra     loop

fif:    divu.w  #50,D2          
        move.w  D2,D0           
        adda.w  #11,A4
        cvt2a   (A4),#1
        lineout array+11        
        suba.w  #11,A4          *Resets A4 to starting Array position
        clr.w   D2
        swap    D2
        bra     loop

twent:  divu.w  #20,D2
        move.w  D2,D0
        adda.w  #20,A4
        cvt2a   (A4),#1
        lineout array+20
        suba.w  #20,A4
        clr.w   D2
        swap    D2
        bra     loop

ten:    divu.w  #10,D2
        move.w  D2,D0
        adda.w  #29,A4
        cvt2a   (A4),#1
        lineout array+29
        suba.w  #29,A4
        clr.w   D2
        swap    D2      
        bra     loop

five:   divu.w  #5,D2
        move.w  D2,D0
        adda.w  #38,A4
        cvt2a   (A4),#1
        lineout array+38
        suba.w  #38,A4
        clr.w   D2
        swap    D2
        bra     loop    

one:    divu.w  #1,D2
        move.w  D2,D0
        adda.w  #47,A4
        cvt2a   (A4),#1
        lineout array+47
        suba.w  #47,A4
        clr.w   D2
        swap    D2      
        bra     loop

*----------------------------------------------------------------------
*THIS SECTION BELOW IS THE DECIMAL ALGORITHM

decal:  cmpi.w  #50,D3          *Similar branching loop as above, except
        bge     fifc            *values are modified for cents. 
        cmpi.w  #25,D3
        bge     quart
        cmpi.w  #10,D3
        bge     dime
        cmpi.w  #5,D3
        bge     nick
        cmpi.w  #1,D3
        bge     penny
        bra     done

fifc:   divu.w  #50,D3          
        move.w  D3,D0
        adda.w  #62,A4          *Adds the cents sign to the output
        move.b  #$A2,(A4)
        suba.w  #62,A4
        adda.w  #56,A4
        cvt2a   (A4),#1
        lineout array+56        
        suba.w  #56,A4          
        clr.w   D3
        swap    D3
        bra     decal

quart:  divu.w  #25,D3          
        move.w  D3,D0   
        adda.w  #71,A4
        move.b  #$A2,(A4)
        suba.w  #71,A4  
        adda.w  #65,A4
        cvt2a   (A4),#1
        lineout array+65        
        suba.w  #65,A4  
        clr.w   D3
        swap    D3
        bra     decal

dime:   divu.w  #10,D3          
        move.w  D3,D0   
        adda.w  #80,A4
        move.b  #$A2,(A4)
        suba.w  #80,A4  
        adda.w  #74,A4
        cvt2a   (A4),#1
        lineout array+74        
        suba.w  #74,A4  
        clr.w   D3
        swap    D3
        bra     decal

nick:   divu.w  #5,D3           
        move.w  D3,D0
        adda.w  #88,A4
        move.b  #$A2,(A4)
        suba.w  #88,A4          
        adda.w  #83,A4
        cvt2a   (A4),#1
        lineout array+83        
        suba.w  #83,A4  
        clr.w   D3
        swap    D3
        bra     decal

penny:  divu.w  #1,D3           
        move.w  D3,D0   
        adda.w  #97,A4
        move.b  #$A2,(A4)
        suba.w  #97,A4  
        adda.w  #92,A4
        cvt2a   (A4),#1
        lineout array+92        
        suba.w  #92,A4  
        clr.w   D3
        swap    D3
        bra     decal


done:   break                   * Terminate execution
*
*----------------------------------------------------------------------
*       Storage declarations

title:  dc.b    'Program #3, Jan Domingo, cssc0797',0
skipln  dc.b    0
prompt: dc.b    'Enter an amount in U.S. Dollars (no $ sign):',0
error:  dc.b    'Sorry, invalid entry.',0
buffer: ds.b    80
whole:  ds.b    40
decsto: ds.b    40              *'Decimal Storage' - Decimal memory storage from user input
output: dc.b    'That amount is:',0
array:  dc.b    '    x $100',0
        dc.b    '  x $50 ',0
        dc.b    '  x $20 ',0
        dc.b    '  x $10 ',0
        dc.b    '  x $5  ',0
        dc.b    '  x $1  ',0
        dc.b    '  x 50  ',0
        dc.b    '  x 25  ',0
        dc.b    '  x 10  ',0
        dc.b    '  x 5   ',0
        dc.b    '  x 1   ',0    


        end