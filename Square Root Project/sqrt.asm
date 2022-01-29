INCLUDE CS240.inc

.8086

.data
    two       WORD  0002h
    counter   WORD  0028h
    divisor   WORD  ?
    initial   WORD  ?

.code
sqrt PROC
    push  cx
    push  dx

    mov   initial, ax ; move ax into initial
    mov   divisor, ax ; move ax into divisor
    mov   cx, counter ; set cs equal to 40

    cmp   ax, 0 ; if ax equals 0, jump to done
    je    done

; CITE: https://en.wikipedia.org/wiki/Newton%27s_method
; DESC: Source of Newton's approximation method for approximating squareroots
top:
    mov   ax, initial ; mov initial into ax
    mov   dx, 0
    div   divisor ; divide ax by divisor, put this value in ax
    add   ax, divisor ; add ax with divisor, put result in ax
    mov   dx, 0
    div   two ; divide ax by tw0, put result in ax
    mov   divisor, ax ; set divisor
    loop  top

done:
    pop   dx
    pop   cx
    ret
sqrt ENDP
END
