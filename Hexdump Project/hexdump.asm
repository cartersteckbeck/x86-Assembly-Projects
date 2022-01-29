; Project that takes a text file as input and outputs the hex representation

.8086

.model small, stdcall

.stack 200h

DOS = 21h
TERMINATE = 4C00h

.data
filename    BYTE  1000 DUP(?)
oer         BYTE  "there was an opening error", 0
rer         BYTE  "there was a reading error", 0
curr_line   BYTE  16 DUP(?)
prev_line   BYTE  16 DUP(?)
placeh      WORD  0000h
filehandle  WORD  ?
bytes_read  WORD  ?
dx_place    WORD  ?
file        WORD  ?
filelen     WORD  ?

.code
main  PROC
      mov   ax, @data
      mov   ds, ax

      call  GetCommandTail
      call  LookFile
      mov   dx, es
      call  OpenFile
      mov   ax, 0
      mov   cx, 0
      mov   dx, 0
      L:
      call  ReadFile
      mov   si, dx_place
      mov   cx, 16
      mov   bx, OFFSET curr_line
      mov   di, 0
      call  CompareLines
      jz    star
      mov   dx, 0
      call  PrintOffset
      cmp   bytes_read, 10h
      jl    last_line
      call  OutputLine
      jmp   L
      star:
            cmp   dx, 1
            je    no_print
            call  Replace
            push  dx
            mov   dl, 2Ah
            call  PrintChar
            mov   dl, 0ah
            ;call  PrintChar
            call  PrintChar
            pop   dx
            add   ax, 16
            jz    over
            mov   dx, 1
            jmp   L
      no_print:
            call  Replace
            add   ax, 16
            jz    over
            jmp   L
      over:
            inc   placeh
            jmp   L
      last_line:
      mov   cx, bytes_read
      cmp   cx, 0
      je    finish
      call  OutputLine
      call  PrintOffset
      jmp   finish
      finish:
      call  EndProgram
main ENDP

Spacing PROC
      push  ax
      ;call  DumpRegs
      mov   ax, 16
      sub   ax, bytes_read
      mov   dx, 3
      mul   dx
      mov   cx, ax
      cmp   bytes_read, 8h
      jl    add_one
      jmp   top
      add_one:
      inc   cx
      top:
      mov   dl, 20h
      call  PrintChar
      loop  top

      pop   ax
      ret
Spacing ENDP

OutputLine PROC
      ; use dx as a counter to see when to double space, push and pop
      mov   dx_place, si
      mov   cx, bytes_read
      ;call  DumpRegs
      top:
      mov   dl, [si]
      mov   [bx+di], dl
      inc   di
      inc   si
      inc   ax
      jz    over
      loop  top
      jmp   finish_line

      over:
      inc   placeh
      cmp   cx, 1
      je    finish_line
      loop  top

      finish_line:
      mov   si, dx_place
      mov   cx, bytes_read
      mov   dx, 0

      L:
      push  dx
      mov   dl, [si]
      call  PrintHexByte
      mov   dl, 20h
      call  PrintChar
      pop   dx
      inc   dx
      inc   si
      cmp   dx, 8
      je    double_space
      loop  L

      continue:
      mov   cx, bytes_read
      cmp   cx, 10h
      jnl   two_space
      call  Spacing
      jmp   two_space

      double_space:
      push  dx
      mov   dl, 20h
      call  PrintChar
      pop   dx
      cmp   cx, 1
      je    continue
      loop  L

      two_space:
      call  Replace
      mov   dl, 20h
      ;call  PrintChar
      call  PrintChar
      call  WriteLine
      mov   dl, 0ah
      call  PrintChar
      ;call  PrintChar
      ret
OutputLine ENDP

CompareLines PROC
      push  dx
      push  cx
      push  bx
      push  ax
      push  si
      mov   cx, bytes_read
      mov   si, dx_place
      mov   di, 0
      cond:
      mov   bx, OFFSET prev_line
      mov   dl, [bx+di]
      cmp   dl, [si]
      jne   return
      inc   si
      inc   di
      loop  cond
      xor   ax, ax
      return:
      pop   si
      pop   ax
      pop   bx
      pop   cx
      pop   dx
      ret
CompareLines ENDP

Replace PROC
      push  dx
      push  cx
      push  bx
      push  ax
      push  si
      mov   cx, bytes_read
      mov   si, dx_place
      mov   di, 0
      mov   bx, OFFSET prev_line
      L2:
      mov   dl, [si]
      mov   [bx+di], dl
      inc   di
      inc   si
      loop  L2

      pop   si
      pop   ax
      pop   bx
      pop   cx
      pop   dx
      ret
Replace ENDP

PrintOffset PROC
      pushf
      push  dx
      push  cx
      push  bx
      push  ax
      push  si
      mov   dx, placeh
      call  PrintHexWord
      mov   dx, ax
      call  PrintHexWord
      mov   dl, 20h
      call  PrintChar
      mov   dl, 20h
      call  PrintChar
      pop   si
      pop   ax
      pop   bx
      pop   cx
      pop   dx
      popf
      ret
PrintOffset ENDP

HexOut2 PROC
      ; prints low 4 bits of DL aså a hexdigit
      pushf
      push  dx
      push  cx
      push  bx
      push  ax
      push  si
      and   dx, 0Fh
      .data
      digits    BYTE  "0123456789abcdef", 0
      .code
      mov   bx, OFFSET digits
      mov   si, dx
      mov   dl, [bx+si]
      call  PrintChar
      pop   si
      pop   ax
      pop   bx
      pop   cx
      pop   dx
      popf
      ret
HexOut2 ENDP

PrintHexByte PROC
      pushf
      push  cx
      push  bx
      push  ax
      push  si
      push  dx
      mov   cl, 4d
      shr   dl, cl ; cl is the value that you want to shift by
      call  HexOut2
      pop   dx
      call  HexOut2
      pop   si
      pop   ax
      pop   bx
      pop   cx
      popf
      ret
PrintHexByte ENDP

PrintHexWord PROC
      pushf
      push  cx
      push  bx
      push  ax
      push  si
      push  dx
      mov   cl, 8d
      shr   dx, cl ; cl is the value that you want to shift by
      call  PrintHexByte
      pop   dx
      call  PrintHexByte
      pop   si
      pop   ax
      pop   bx
      pop   cx
      popf
      ret
PrintHexWord ENDP

PrintChar PROC
      ; char comes in from dl
      push  ax
      mov   ah, 02h
      int   DOS
      pop   ax
      ret
PrintChar ENDP

WriteLine PROC
      pushf
      push  dx
      push  cx
      push  bx
      push  ax
      push  si
      mov   cx, bytes_read
      mov   si, dx_place
      mov   dl, 7ch
      call  PrintChar
      top:
      mov   dl, [si]
      cmp   dl, 7fh
      jge   dot
      cmp   dl, 1Fh
      jle   dot
      call  PrintChar
      inc   si
      loop  top
      jmp   finish
      dot:
      mov   dl, 2eh
      call  PrintChar
      inc   si
      loop  top
      finish:
      mov   dl, 7ch
      call  PrintChar
      pop   si
      pop   ax
      pop   bx
      pop   cx
      pop   dx
      popf
      ret
WriteLine ENDP

OpenFile PROC
      mov   ah, 3Dh
      mov   cl, 0
      mov   al, 0
      int   DOS
      mov   filehandle, ax
      jc    open_error
      ret
      open_error:
      mov   dx, OFFSET oer
      call  PrintString ; CHANGE
      call  EndProgram
      ret
OpenFile ENDP

ReadFile PROC
      pushf
      push  ax
      push  cx
      push  bx
      push  si
      mov   ax, 0
      mov   ah, 3Fh
      mov   bx, filehandle
      mov   cx, 10h
      int   DOS
      mov   bytes_read, ax
      mov   dx_place, dx
      jc    read_error
      pop   si
      pop   bx
      pop   cx
      pop   ax
      popf
      ret
      read_error:
      mov   dx, OFFSET rer
      call  PrintString ; CHANGE
      call  EndProgram
      ret
ReadFile ENDP

PrintString PROC
      pushf
      push  ax
      push  cx
      push  bx
      push  si
      mov   cx, 0
      mov   bx, dx ; move offset of string into bx
      mov   si, 0
      top:
      cmp   dl, 0 ; if the string is done, jump to finish
      je    finish
      mov   dl, [bx + si] ; get character at given index and move it into dl
      call  PrintChar
      inc   si
      jmp   top
      finish:
      pop   si
      pop   bx
      pop   cx
      pop   ax
      popf
      ret
PrintString ENDP

; Get the command tail, which I got directly from the book that we use
GetCommandTail PROC
      push  es
      mov   ah, 62h
      int   21h
      mov   es, bx

      mov   si, dx
      mov   di, 81h
      mov   cx, 0
      mov   cl, es:[di-1]
      cmp   cx, 0
      je    command_error
      cld
      mov   al, 20h
      repz  scasb
      jz    command_error
      dec   di
      inc   cx

      top:
      mov   al, es:[di]
      mov   [si], al
      inc   si
      inc   di
      loop  top
      jmp   cont

      command_error:
      mov   dx, OFFSET rer
      call  PrintString
      call  EndProgram

      cont:
      mov   byte ptr [si], 0

      pop   es
      ret
GetCommandTail ENDP

; Looks for the file
LookFile PROC
      push  ax
      push  bx
      push  cx
      push  dx
      mov   ax, 1
      mov   file, es
      mov   bx, es
      mov   cx, 0
      jmp   cond

      top:
      inc   cx

      cond:
      add   bx, cx
      mov   dl, [bx]
      sub   bx, cx
      cmp   dl, 00h
      je    finish
      cmp   ax, 1
      jne   bool
      cmp   dl, 20h
      jne   L
      add   file, 1
      jmp   top

      L:
      inc   ax

      bool:
      cmp   dl, 20h
      je    finish
      jmp   top

      finish:
      mov   filelen, cx
      add   bx, cx
      inc   bx
      mov   dx, [bx]
      mov   dx, 0h
      pop   dx
      pop   cx
      pop   bx
      pop   ax
      ret
LookFile ENDP

EndProgram PROC
      mov   ax, TERMINATE
      int   DOS
EndProgram ENDP

END main
