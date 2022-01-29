; Calculates the square root of a given integer rounded to the closest integer 

INCLUDE CS240.inc

.8086

sqrt PROTO

DOS = 21h
TERMINATE = 4C00h

.data

question        BYTE  "Enter an integer: ", 0Dh, 0Ah, 0
orig_val        WORD  ?
temp_ax         WORD  ?
temp_bx         WORD  ?
diff            WORD  ?

.code

main PROC
        mov   ax, @data
        mov   ds, ax

        mov   dx, OFFSET question
        call  WriteString
        call  ReadUInt

        mov   orig_val, dx ; move integer to orignal value
        mov   ax, dx ; move integer to ax

        push  ax ; push ax onto stack
        call  sqrt

        cmp   ax, 0 ; if it is 0, finish
        je    finish

        mov   bx, ax ; move the value we think it is into bx

        mov   ax, orig_val ; let ax equal the original value

        mov   dx, 0

        div   bx ; divide the original value with the value we believe it is

        mov   temp_ax, ax ; move ax into a placeholder temp_ax
        sub   ax, bx ; subtract bx from ax, put the difference in ax
        mov   diff, ax ; move ax into the difference variable
        mov   ax, temp_ax ; move the placeholder into ax
        jns   check ; if the subtraction did not signal the sign flag, jump
                    ; to check
        inc   ax
        jmp   continue

check:
        cmp   diff, 0001h ; if the difference between ax and bx to 1
        jng   continue ; if the difference is less than one, jump to continue
        dec   ax

continue:
        cmp   ax, bx ; if they are equal, finish
        je    finish
        jg    check_distances ; if ax is greater than bx, check_distances
        mov   ax, bx ; otherwise, move bx into ax and finish
        jmp   finish

check_distances:
        mov   temp_bx, bx ; move bx into placeholder value temp_bx
        mov   bx, ax ; move ax into bx
        mul   bx ; multiply bx by ax, place value into ax
        mov   bx, temp_bx ; move placeholder back into bx
        mov   temp_ax, ax ; move ax into placeholder value temp_ax
        mov   ax, bx ; move bx into ax
        mul   bx ; multiply bx by ax, place value into ax
        mov   bx, ax ; move ax into bx
        mov   ax, temp_ax ; move placeholder back into ax
        mov   temp_bx, bx ; move bx into placeholder value
        sub   bx, orig_val ; subract orignal value from bx
        jns   check_ax_negative ; if subtraction did not signal the sign flag
                                ; jump to check_ax_negative
        neg   bx

check_ax_negative:
        sub   ax, orig_val ; subtract original value from ax
        jns   compare_ax_bx ; if subtraction did not signal the sign flag
                            ; jump to compare_ax_bx
        neg   ax

compare_ax_bx:
        cmp   ax, bx
        jl    run_again ; if ax is less than bx, jump to run_again
        jg    switch_and_run_again ; if ax is greater than bx, jump to


run_again:
        mov   ax, temp_ax ; set ax equal to temp_ax
        call  sqrt
        jmp   finish

switch_and_run_again:
        mov   bx, temp_bx ; set bx equal to temp_bx
        mov   ax, bx ; set ax equal to bx
        call  sqrt

finish:
        mov   dx, ax
        pop   ax

        call  WriteInt
        call  NewLine

        mov   ax, TERMINATE
        int   DOS
main ENDP
END main
