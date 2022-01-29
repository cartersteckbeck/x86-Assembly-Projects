; Project that implements functions that would be helpful in x86 Assembly

INCLUDE CS240.inc

.8086

DOS = 21h

.code
SumArray PROC
        push  cx
        push  si
        push  bx
        push  dx
        mov   si, ax ; set si to offset of array
        mov   dx, ax ; set dx to offset of array
        mov   ax, 0
        mov   bx, 0
        lahf ; move flag values into ah
top:
        add   bx, [si] ; add bx and the element at si, put result in bx
        jo    overflow ; jump if there's overflow
        add   si, 0002h ; otherwise, add 2 to si
        loop  top
        jmp   switch ; if no overflow, then jmp to finish

overflow:
        sahf ; push ah bits into flag values
        mov   ax, dx ; move offset of array into ax
        jmp   done

switch:
        sahf ; push ah bits into flag values
        mov   ax, bx ; move sum into ax

done:
        pop   dx
        pop   bx
        pop   si
        pop   cx
        ret

SumArray ENDP

PrintHexDigit PROC
        pushf
        push  dx
        push  ax
        and   dx, 0Fh ; isolates last 4 bits in dx
        cmp   dx, 10 ; jump if dx is less than 10, otherwise jump to continue
        jl    zero_to_nine
        jmp   continue

zero_to_nine:
        add   dx, '0' ; add '0' to dx, put result in dx, then jump to finish
        jmp   finish

continue:
        cmp   dx, 10
        je    ten
        cmp   dx, 11
        je    eleven
        cmp   dx, 12
        je    twelve
        cmp   dx, 13
        je    thirteen
        cmp   dx, 14
        je    fourteen
        cmp   dx, 15
        je    fifteen

ten:
        mov   dx, 'A'
        jmp   finish

eleven:
        mov   dx, 'B'
        jmp   finish

twelve:
        mov   dx, 'C'
        jmp   finish

thirteen:
        mov   dx, 'D'
        jmp   finish

fourteen:
        mov   dx, 'E'
        jmp   finish

fifteen:
        mov   dx, 'F'
        jmp   finish

finish:
        mov   ah, 02h ; print out the character
        int   DOS
        pop   ax
        pop   dx
        popf
        ret

PrintHexDigit ENDP

PrintString PROC
        pushf
        push  bx
        push  ax
        push  cx
        push  si
        push  dx
        mov   cx, 0
        mov   ax, 0
        mov   bx, dx ; move offset of string into bx
top:
        cmp   dl, 0 ; if the string is done, jump to finish
        je    finish
        mov   dl, [bx + si] ; get character at given index and move it into dl
        inc   si
        mov   ah, 02h ; print out the character in dl
        int   DOS
        loop  top

finish:
        pop   dx
        pop   si
        pop   cx
        pop   ax
        pop   bx
        popf
        ret

PrintString ENDP
END
