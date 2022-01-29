; Project that creates a buffer in memory for the user to input a string

INCLUDE CS240.inc

.8086

DOS = 21h
TERMINATE = 4C00h

.data
abort     BYTE  "error", 0

.code
SafeRead PROC
            push  bp
            mov   bp, sp
            push  si
            push  ax
            push  cx
            push  dx
            push  bx
            pushf
            mov   dx, [bp+4] ; lengh of buf
            mov   bx, [bp+6] ; offset of buf
            dec   dx
            mov   si, 0
            mov   ax, 0
            mov   cx, 0FFFFh

top:
            mov   ah, 10h
            int   16h
            cmp   al, 3d
            je    error
            cmp   al, 13d
            je    finish
            cmp   al, 8d
            je    back
            jne   continue

error:
            mov   dx, OFFSET abort
            call  NewLine
            call  WriteString
            mov   ax, TERMINATE
            int   DOS

back:
            call  BackSpace
            loop  top

continue:
            cmp   si, dx
            je    overflow
            jmp   add_character

overflow:
            call  Check
            loop  top

add_character:
            push  dx
            mov   [bx+si], al
            mov   dl, al
            mov   ah, 02h
            int   DOS
            inc   si
            pop   dx
            loop  top

finish:
            mov   ax, 0
            mov   [bx+si+1], ax
            popf
            pop   bx
            pop   dx
            pop   cx
            pop   ax
            pop   si
            pop   bp
            ret
SafeRead ENDP

BackSpace PROC
            cmp   si, 0 ; if si is zero, you are at the beginning of the buffer
                        ; cannot go before this
            je    underflow
            jmp   place_zero

underflow:
            push  dx
            push  cx
            mov   ax, 0
            mov   dl, 85d
            mov   ah, 02h
            int   DOS
            mov   cx, 0FFFFh
top:
            loop  top
            mov   cx, 0FFFFh

nothing:
            loop  nothing
            pop   cx
            jmp   done

place_zero:
            push  dx
            dec   si
            mov   ax, 0
            mov   [bx+si], ax

done:
            call  MoveCursor
            pop   dx
            ret
BackSpace ENDP

Check PROC
            push  dx
            push  cx
            mov   ax, 0
            mov   dl, 79d
            mov   ah, 02h
            int   DOS
            mov   cx, 0FFFFh
top:
            loop  top

            mov   cx, 0FFFFh
nothing:
            loop  nothing

            call  MoveCursor
            pop   cx
            pop   dx
            ret
Check ENDP

MoveCursor PROC
            mov   dl, 8d
            mov   ah, 02h
            int   DOS
            mov   dl, 32d
            mov   ah, 02h
            int   DOS
            mov   dl, 8d
            mov   ah, 02h
            int   DOS
            ret
MoveCursor ENDP
END
