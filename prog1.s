*----------------------------------------------------------------------
* Programmer: Jan Domingo
* Class Account: CSSC0797
* Assignment or Title: Prog1 
* Filename: prog1.s
* Date completed: February 26, 2018
*----------------------------------------------------------------------
* Problem statement: Read integers from 0-20 then print the English
*                    word that corresponds with the number entered
* Input:An integer
* Output:The English word of that integer
* Error conditions tested: None
* Included files: None
* Method and/or pseudocode: Took in an integer user input and converted 
*  into two's comp. I then used that number to multiply by 12 in order 
*  to find the value in the array with the correct english word. We then
*  copy each byte of that array into the address that will be outputted.                                
* References: Riggins Lecture, CS237 Supplement
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
* D0 is used for converting the user input into a two's comp number
* A0 holds the num array index
* A1 holds the English word answer
*----------------------------------------------------------------------
*
start:  initIO                  * Initialize (required for I/O)
        setEVT                  * Error handling routines
*       initF                   * For floating point macros only        

        lineout title
        lineout newline
        lineout prompt
        linein  buffer

        cvta2   buffer,D0       *Converts buffer to two's comp by the amount of digits inputted 
                                *(either 2 or 1 in this case)

        mulu    #12,D0          *Index * 12 - The exact number of characetrs in each array entry
                                *multiplies by 12 in order to jump to the next array

        lea     num,A0          *Loads the 'num' array into the address A0
        adda.l  D0,A0           *Source, adds the two's comp number to A0 to find the English Word 
                                *in the array

        lea     number,A1       *Destination, A1 will hold the English word value to output

        move.b  (A0)+,(A1)+     *Moves each char from A0 to A1
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0)+,(A1)+
        move.b  (A0),(A1)       *use move.b 12 times because that is the length of each array index.

        lineout answer          *Prints out answer which is at the start of A1 

        break                   * Terminate execution
*
*----------------------------------------------------------------------
*       Storage declarations
num:    dc.b    'zero.      ',0
        dc.b    'one.       ',0
        dc.b    'two.       ',0
        dc.b    'three.     ',0
        dc.b    'four.      ',0
        dc.b    'five.      ',0
        dc.b    'six.       ',0
        dc.b    'seven.     ',0
        dc.b    'eight.     ',0
        dc.b    'nine.      ',0
        dc.b    'ten.       ',0
        dc.b    'eleven .   ',0
        dc.b    'twelve .   ',0
        dc.b    'thirteen.  ',0
        dc.b    'fourteen.  ',0
        dc.b    'fifteen.   ',0
        dc.b    'sixteen.   ',0
        dc.b    'seventeen. ',0
        dc.b    'eighteen.  ',0
        dc.b    'nineteen.  ',0
        dc.b    'twenty.    ',0


title:  dc.b    'Program #1, Jan Domingo, cssc0797',0
newline:dc.b    0
prompt: dc.b    'Enter an integer in the range 0 .. 20:',0
buffer: ds.b    80
answer: dc.b    'The number you entered is '
number: ds.b    14
        end