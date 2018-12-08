*----------------------------------------------------------------------
* Programmer: Jan Domingo
* Class Account: CSSC 0797
* Assignment or Title: Assignment #4
* Filename: binSearch.s
* Date completed: May 4, 2018 
*----------------------------------------------------------------------
* Problem statement:Perform a recursive binary search on the ordered array
*       and return the address of the element in the array if it is found.
*       If the key is not in the array, then the subroutine sets the V bit
*       in the CCR, and the return value is undefined.
* Input: The element in the array to search for.
* Output: The position of the element.
* Error conditions tested: Return undefined value if key is not in array. 
* Included files: prog4.s, getInput.s, p4datafile.s
* Method and/or pseudocode: Recursive Binary Search Algorithm
*
*  int &binSearch(int key, int &lo, int &hi) {
*    if(hi < lo)
*       return NOT_FOUND;  //RETURN with V = 1   
*    int mid = (lo+hi) / 2;
*       if(key == array[mid])
*               return mid;
*       else if(key < array[mid]) // go left
*               return binSearch(key, lo, mid-1); // left
*       else
*               return binSearch(key, mid+1, hi); // right
*    }
*
* References: CS 237 Lecture Supplement book, pindar, lecture notes
*----------------------------------------------------------------------

        ORG     $8000

*-----Retrieves parameters from stack and places it into registers----
binS:   link    A6,#0
        movem.l D1/A0/A1,-(SP)  
        move.w  8(A6),D1        *2's comp value of the key
        movea.l 10(A6),A0       *lo
        movea.l 14(A6),A1       *hi

        cmp.l   A0,A1
        blt     neg             *Return V = 1 in the CCR if return not found

        movea.l A0,A4           *A4 will be the mid address
        adda.l  A1,A4
        move.l  A4,D4           *D4 holds the address of A4 for division
        divu.w  #2,D4           *A4 divided by 2 is the mid address
        and.b   #$FE,D4         *Makes sure D4 is an even address to put into A4
        move.l  D4,A4
        move.w  (A4),D5         *D5 stores the mid value element

*-----------------Compares the key with the mid value-----------------
        cmp.w   D1,D5   
        beq     pstion          

        cmp.w   D5,D1            
        bgt     goright
goleft: subq.w  #2,A4           *Two bytes is the size of one element
        movea.l A4,A1           *Address of mid is copied into hi 
        bra     recrse

goright:addq.w  #2,A4
        movea.l A4,A0           *Address of mid is copied into lo


*----------------Places new pararmeters onto the stack-----------------
recrse: pea     (A1)
        pea     (A0)
        move.w  D1,-(SP)
        jsr     binS
        adda.l  #10,SP
        bra     done            

*-----------------Moves address of the element into D0-----------------
pstion: move.l  A4,D0           *Returns the position of the element
        bra     done    

*--------------------Pops parameters off the stack--------------------- 
neg:    move.w  #2,CCR
done:   movem.l (SP)+,D1/A0/A1
        unlk    A6
        rts                     
        end