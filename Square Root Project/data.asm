INCLUDE CS240.inc
.8086

DOS = 21h
TERMINATE = 4C00h

.data
example1  BYTE    255d                        ; 8-bits unsigned (1 bytes)
example2  SBYTE   127d                        ; 8-bits signed (1 bytes)
example3  WORD    65535d                      ; 16-bits unsigned (2 bytes)
example4  SWORD   32767d                      ; 16-bits signed (2 bytes)
example5  DWORD   0ABCDEF12h                  ; 32-bits unsigned (4 bytes)
example6  SDWORD  81234567h                   ; 32-bits signed (4 bytes)
example7  FWORD   123456789ABCh               ; 48-bits unsigned (6 bytes)
example8  QWORD   1122334455667788h           ; 64-bits unsigned (8 bytes)
example9  TBYTE   12333333333333333334h       ; 80-bits unsigned (10 bytes)
; 1 + 1 + 2 + 2 + 4 + 4 + 6 + 8 + 10 = 38 bytes

.code
main PROC
      mov   cx, 26h
      ;call  DumpMem
      mov   ax, TERMINATE
      int   DOS
main ENDP
END main
