; Project that implements PacMan in x86 Assembly 

INCLUDE cs240.inc

.8086

TERMINATE = 4C00h
DOS = 21h

.code
KBDINTERRUPT = 09h
CLK_INTERRUPT = 1Ch
INTERRUPT = CLK_INTERRUPT
SPEAKER_PORT = 61h

currow BYTE 0
curcol BYTE 0
gcurrow1 BYTE 0
gcurcol1 BYTE 0
gcurrow2 BYTE 0
gcurcol2 BYTE 0
gcurrow3 BYTE 0
gcurcol3 BYTE 0
gcurrow4 BYTE 0
gcurcol4 BYTE 0
dir BYTE ?
points WORD 0
wincond BYTE 0
losecond BYTE 0
printstar1 BYTE 1
printstar2 BYTE 1
printstar3 BYTE 1
printstar4 BYTE 1
counter BYTE 0
ticks WORD 0

KeyboardVector LABEL DWORD
KeyboardOffset WORD 0
KeyboardSegment WORD 0

ClockVector LABEL DWORD
ClockOffset WORD 0
ClockSegment WORD 0

main PROC
	mov 	ax, cs
	mov		ds, ax

	call 	DrawBoard
	mov 	al, 153d
	mov 	ah, 00001011b
	mov 	cx, 083Dh
	call 	GhostScreenChar
	mov 	gcurcol1, cl
	mov 	gcurrow1, ch
	mov 	al, 153d
	mov 	ah, 00001100b
	mov 	cx, 0D1Bh
	call 	GhostScreenChar
	mov 	gcurcol2, cl
	mov 	gcurrow2, ch
	mov 	al, 153d
	mov 	ah, 00001101b
	mov 	cx, 0201h
	call 	GhostScreenChar
	mov 	gcurcol3, cl
	mov 	gcurrow3, ch
	mov 	al, 153d
	mov 	ah, 00001010b
	mov 	cx, 1619h
	call 	GhostScreenChar
	mov 	gcurcol4, cl
	mov 	gcurrow4, ch
	mov 	al, 3Eh
	mov 	cx, 0C01h
	call 	PacScreenChar
	mov		curcol, cl
	mov 	currow, ch
	mov 	si, 0

	mov 	al, INTERRUPT
	mov 	dx, OFFSET KeyboardVector
	call 	SaveVector ; gets the interrupt vector - es:bx
	mov 	dx, Game
	call 	InstallHandler ; sets the interrupt vector - ds:dx

	top:
	cmp 	losecond, 1
	je 		losefinish
	cmp 	wincond, 1
	je		winfinish
	call 	ReadDir
	jmp 	top

	losefinish:
	mov 	curcol, 0
	mov 	currow, 0
	call 	FixVector
	call 	DrawLoseScreen
	call 	ScoreCursor
	mov 	dx, points
	call 	WriteInt
	call 	ResetCursor
	call 	EndProgram

	winfinish:
	mov 	curcol, 0
	mov 	currow, 0
	call 	FixVector
	call 	DrawWinScreen
	call 	ResetCursor
	call 	EndProgram
main ENDP

Sound PROC
	push	cx
	push	ax
	push 	bx

	call	SpeakerOn

	out		42h, al
	mov		al, ah
	out		42h, al
	in		al, 61h
	or    al, 00000011b
	out   61h, al
	mov   cx, 40000
	top1:
	loop 	top1
	mov   cx, 40000
	top2:
	loop 	top2

	call 	SpeakerOff

	and   al, 11111100b
	out   61h, al

	pop		bx
	pop 	ax
	pop 	cx
	ret
Sound ENDP

SpeakerOn PROC
	push	ax
	in		al, 61h; Read the speaker register
	or 		al, 03h
	out 	61h, al
	pop 	ax
	ret
SpeakerOn ENDP

SpeakerOff PROC
	push 	ax
	in 		al, 61h
	and 	al, 0FCh
	out 	61h, al
	pop 	ax
	ret
SpeakerOff ENDP

ScoreCursor PROC
	push 	dx
	push 	ax
	push 	bx
	mov 	dl, 42d
	mov 	dh, 14d
	mov 	ah, 02h
	mov 	bh, 0
	int 	10h
	pop 	bx
	pop 	ax
	pop 	dx
	ret
ScoreCursor ENDP

ResetCursor PROC
	push 	dx
	push 	ax
	push 	bx
	mov 	dl, 00
	mov 	dh, 25
	mov 	ah, 02h
	mov 	bh, 0
	int 	10h
	pop 	bx
	pop 	ax
	pop 	dx
	ret
ResetCursor ENDP

ReadDir PROC
	push 	ax
	push 	dx
	pushf
	call 	SetCursor
	call 	DisplayScore
	mov 	ax, 10h
	int 	16h
	call 	SetCursor
	call 	DisplayScore
	cmp 	al, 3d
	je 		stop
	mov 	dir, ah
	jmp 	finish
	stop:
	call 	FixVector
	call 	ResetCursor
	call 	EndProgram
	finish:
	popf
	pop 	dx
	pop 	ax
	ret
ReadDir ENDP

SetCursor PROC
	push 	dx
	push 	ax
	push 	bx
	mov 	dl, 06
	mov 	dh, 00
	mov 	ah, 02h
	mov 	bh, 0
	int 	10h
	pop 	bx
	pop 	ax
	pop 	dx
	ret
SetCursor ENDP

DisplayScore PROC
	push 	dx
	mov 	dx, points
	call 	WriteInt
	pop 	dx
	ret
DisplayScore ENDP

Melody1 PROC
	mov 	ax, 1521h
	call 	Sound
	mov 	ax, 1355h
	call 	Sound
	ret
Melody1 ENDP

Melody2 PROC
	mov 	ax, 2152h
	call 	Sound
	mov 	ax, 2031h
	call 	Sound
	ret
Melody2 ENDP

Melody3 PROC
	mov 	ax, 1809h
	call 	Sound
	mov 	ax, 1715h
	call 	Sound
	ret
Melody3 ENDP

MovePacman PROC
	push 	ax
	push 	dx
	cmp 	si, 0
	je 		flow1
	cmp 	si, 1
	je 		flow2
	cmp 	si, 2
	je 		flow3
	flow1:
	call 	Melody1
	jmp 	cond
	flow2:
	call 	Melody2
	jmp 	cond
	flow3:
	call 	Melody3

	cond:
	inc 	si
	cmp 	si, 3
	je 		zero
	jmp 	nozero

	zero:
	mov 	si, 0

	nozero:
	mov 	ah, dir
	mov 	currow, ch
	mov 	curcol, cl
	cmp 	ah, 4Bh
	je 		moveleft
	cmp 	ah, 4Dh
	je 		moveright
	cmp 	ah, 50h
	je 		movedown
	cmp 	ah, 48h
	je 		moveup
	jmp 	finish

	moveright:
	inc 	cl
	mov 	al, 3Eh
	jmp 	check

	moveleft:
	dec 	cl
	mov 	al, 3Ch
	jmp 	check

	moveup:
	dec 	ch
	mov 	al, 5Eh
	jmp 	check

	movedown:
	inc 	ch
	mov 	al, 76h

	check:
	push 	ax
	call 	rowcol2index
	mov 	di, ax
	mov 	dx, es:[di]
	pop 	ax
	cmp 	dl, 179d
	je 		nomove
	cmp 	dl, 196d
	je 		nomove
	cmp 	dl, 249d
	je 		incscore
	cmp 	dl, 153d
	je 		lose
	jmp 	move

	incscore:
	inc 	points
	jmp 	move

	lose:
	mov 	losecond, 1

	move:
	push 	cx
	push 	ax
	mov 	ch, currow
	mov 	cl, curcol
	mov 	al, 20h
	call 	ScreenChar
	pop 	ax
	pop 	cx
	call 	PacScreenChar
	jmp 	finish

	nomove:
	mov 	ch, currow
	mov 	cl, curcol

	finish:
	pop 	dx
	pop 	ax
	ret
MovePacman ENDP

MoveGhost1 PROC
	push 	ax
	push 	dx
	mov 	ch, gcurrow1
	mov 	cl, gcurcol1
	mov 	ax, 4
	call 	RandRange
	cmp 	ax, 0
	je 		moveup
	cmp 	ax, 1
	je 		moveright
	cmp 	ax, 2
	je 		movedown
	cmp 	ax, 3
	je 		moveleft

	moveright:
	inc 	cl
	mov 	al, 153d
	jmp 	check

	moveleft:
	dec 	cl
	mov 	al, 153d
	jmp 	check

	moveup:
	dec 	ch
	mov 	al, 153d
	jmp 	check

	movedown:
	inc 	ch
	mov 	al, 153d

	check:
	push 	ax
	call 	rowcol2index
	mov 	di, ax
	mov 	dx, es:[di]
	pop 	ax
	cmp 	dl, 179d
	je 		nomove
	cmp 	dl, 196d
	je 		nomove
	cmp 	dl, 249d
	je 		move
	cmp 	dl, 3Eh
	je 		lose
	cmp 	dl, 3Ch
	je 		lose
	cmp 	dl, 5Eh
	je 		lose
	cmp 	dl, 76h
	je 		lose
	jmp 	move

	lose:
	mov 	losecond, 1

	move:
	push 	cx
	push 	ax
	cmp 	printstar1, 1
	je 		star
	jmp 	nostar

	star:
	cmp 	dl, 153d
	je 		switch1
	cmp 	dl, 20h
	je 		cond
	jmp 	nosetprintstar

	cond:
	mov 	printstar1, 0
	jmp 	nosetprintstar

	switch1:
	cmp 	dh, 00001100b
	je		switchghost2
	cmp 	dh, 00001101b
	je 		switchghost3
	cmp 	dh, 00001010b
	je 		switchghost4

	switchghost2:
	mov 	bh, printstar2
	mov 	printstar1, bh
	jmp 	nosetprintstar
	switchghost3:
	mov 	bh, printstar3
	mov 	printstar1, bh
	jmp 	nosetprintstar
	switchghost4:
	mov 	bh, printstar4
	mov 	printstar1, bh

	nosetprintstar:
	mov 	ch, gcurrow1
	mov 	cl, gcurcol1
	mov 	al, 249d
	call 	FoodScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001011b
	call 	GhostScreenChar
	jmp 	finish

	nostar:
	cmp 	dl, 153d
	je 		switch2
	cmp 	dl, 249d
	je 		setprintstar
	jmp 	noset

	setprintstar:
	mov 	printstar1, 1
	jmp 	noset

	switch2:
	cmp 	dh, 00001100b
	je		changeghost2
	cmp 	dh, 00001101b
	je 		changeghost3
	cmp 	dh, 00001010b
	je 		changeghost4

	changeghost2:
	mov 	bh, printstar2
	mov 	printstar1, bh
	jmp 	noset
	changeghost3:
	mov 	bh, printstar3
	mov 	printstar1, bh
	jmp 	noset
	changeghost4:
	mov 	bh, printstar4
	mov 	printstar1, bh

	noset:
	mov 	ch, gcurrow1
	mov 	cl, gcurcol1
	mov 	al, 20h
	call 	ScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001011b
	call 	GhostScreenChar
	jmp 	finish

	nomove:
	mov 	ch, gcurrow1
	mov 	cl, gcurcol1

	finish:
	pop 	dx
	pop 	ax
	ret
MoveGhost1 ENDP

MoveGhost2 PROC
	push 	ax
	push 	dx
	mov 	ch, gcurrow2
	mov 	cl, gcurcol2
	mov 	ax, 4
	call 	RandRange
	cmp 	ax, 0
	je 		moveup
	cmp 	ax, 1
	je 		moveright
	cmp 	ax, 2
	je 		movedown
	cmp 	ax, 3
	je 		moveleft

	moveright:
	inc 	cl
	mov 	al, 153d
	jmp 	check

	moveleft:
	dec 	cl
	mov 	al, 153d
	jmp 	check

	moveup:
	dec 	ch
	mov 	al, 153d
	jmp 	check

	movedown:
	inc 	ch
	mov 	al, 153d

	check:
	push 	ax
	call 	rowcol2index
	mov 	di, ax
	mov 	dx, es:[di]
	pop 	ax
	cmp 	dl, 179d
	je 		nomove
	cmp 	dl, 196d
	je 		nomove
	cmp 	dl, 249d
	je 		move
	cmp 	dl, 3Eh
	je 		lose
	cmp 	dl, 3Ch
	je 		lose
	cmp 	dl, 5Eh
	je 		lose
	cmp 	dl, 76h
	je 		lose
	jmp 	move

	lose:
	mov 	losecond, 1

	move:
	push 	cx
	push 	ax
	cmp 	printstar2, 1
	je 		star
	jmp 	nostar

	star:
	cmp 	dl, 153d
	je 		switch1
	cmp 	dl, 20h
	je 		cond
	jmp 	nosetprintstar

	cond:
	mov 	printstar2, 0
	jmp 	nosetprintstar

	switch1:
	cmp 	dh, 00001011b
	je		switchghost2
	cmp 	dh, 00001101b
	je 		switchghost3
	cmp 	dh, 00001010b
	je 		switchghost4

	switchghost2:
	mov 	bh, printstar1
	mov 	printstar2, bh
	jmp 	nosetprintstar
	switchghost3:
	mov 	bh, printstar3
	mov 	printstar2, bh
	jmp 	nosetprintstar
	switchghost4:
	mov 	bh, printstar4
	mov 	printstar2, bh

	nosetprintstar:
	mov 	ch, gcurrow2
	mov 	cl, gcurcol2
	mov 	al, 249d
	call 	FoodScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001100b
	call 	GhostScreenChar
	jmp 	finish

	nostar:
	cmp 	dl, 153d
	je 		switch2
	cmp 	dl, 249d
	je 		setprintstar
	jmp 	noset

	setprintstar:
	mov 	printstar2, 1
	jmp 	noset

	switch2:
	cmp 	dh, 00001011b
	je		changeghost2
	cmp 	dh, 00001101b
	je 		changeghost3
	cmp 	dh, 00001010b
	je 		changeghost4

	changeghost2:
	mov 	bh, printstar1
	mov 	printstar2, bh
	jmp 	noset
	changeghost3:
	mov 	bh, printstar3
	mov 	printstar2, bh
	jmp 	noset
	changeghost4:
	mov 	bh, printstar4
	mov 	printstar2, bh


	noset:
	mov 	ch, gcurrow2
	mov 	cl, gcurcol2
	mov 	al, 20h
	call 	ScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001100b
	call 	GhostScreenChar
	jmp 	finish

	nomove:
	mov 	ch, gcurrow2
	mov 	cl, gcurcol2

	finish:
	pop 	dx
	pop 	ax
	ret
MoveGhost2 ENDP

MoveGhost3 PROC
	push 	ax
	push 	dx
	mov 	ch, gcurrow3
	mov 	cl, gcurcol3
	mov 	ax, 4
	call 	RandRange
	cmp 	ax, 0
	je 		moveup
	cmp 	ax, 1
	je 		moveright
	cmp 	ax, 2
	je 		movedown
	cmp 	ax, 3
	je 		moveleft

	moveright:
	inc 	cl
	mov 	al, 153d
	jmp 	check

	moveleft:
	dec 	cl
	mov 	al, 153d
	jmp 	check

	moveup:
	dec 	ch
	mov 	al, 153d
	jmp 	check

	movedown:
	inc 	ch
	mov 	al, 153d

	check:
	push 	ax
	call 	rowcol2index
	mov 	di, ax
	mov 	dx, es:[di]
	pop 	ax
	cmp 	dl, 179d
	je 		nomove
	cmp 	dl, 196d
	je 		nomove
	cmp 	dl, 249d
	je 		move
	cmp 	dl, 3Eh
	je 		lose
	cmp 	dl, 3Ch
	je 		lose
	cmp 	dl, 5Eh
	je 		lose
	cmp 	dl, 76h
	je 		lose
	jmp 	move

	lose:
	mov 	losecond, 1

	move:
	push 	cx
	push 	ax
	cmp 	printstar3, 1
	je 		star
	jmp 	nostar

	star:
	cmp 	dl, 153d
	je 		switch1
	cmp 	dl, 20h
	je 		cond
	jmp 	nosetprintstar

	cond:
	mov 	printstar3, 0
	jmp 	nosetprintstar

	switch1:
	; 00001011b cyan
	; 00001100b red
	; 00001101b pink
	; 00001010b green
	cmp 	dh, 00001011b
	je		switchghost2
	cmp 	dh, 00001100b
	je 		switchghost3
	cmp 	dh, 00001010b
	je 		switchghost4

	switchghost2:
	mov 	bh, printstar1
	mov 	printstar3, bh
	jmp 	nosetprintstar
	switchghost3:
	mov 	bh, printstar2
	mov 	printstar3, bh
	jmp 	nosetprintstar
	switchghost4:
	mov 	bh, printstar4
	mov 	printstar3, bh

	nosetprintstar:
	mov 	ch, gcurrow3
	mov 	cl, gcurcol3
	mov 	al, 249d
	call 	FoodScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001101b
	call 	GhostScreenChar
	jmp 	finish

	nostar:
	cmp 	dl, 153d
	je 		switch2
	cmp 	dl, 249d
	je 		setprintstar
	jmp 	noset

	setprintstar:
	mov 	printstar3, 1
	jmp 	noset

	switch2:
	; 00001011b cyan
	; 00001100b red
	; 00001101b pink
	; 00001010b green
	cmp 	dh, 00001011b
	je		changeghost2
	cmp 	dh, 00001100b
	je 		changeghost3
	cmp 	dh, 00001010b
	je 		changeghost4

	changeghost2:
	mov 	bh, printstar1
	mov 	printstar3, bh
	jmp 	noset
	changeghost3:
	mov 	bh, printstar2
	mov 	printstar3, bh
	jmp 	noset
	changeghost4:
	mov 	bh, printstar4
	mov 	printstar3, bh

	noset:
	mov 	ch, gcurrow3
	mov 	cl, gcurcol3
	mov 	al, 20h
	call 	ScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001101b
	call 	GhostScreenChar
	jmp 	finish

	nomove:
	mov 	ch, gcurrow3
	mov 	cl, gcurcol3

	finish:
	pop 	dx
	pop 	ax
	ret
MoveGhost3 ENDP

MoveGhost4 PROC
	push 	ax
	push 	dx
	mov 	ch, gcurrow4
	mov 	cl, gcurcol4
	mov 	ax, 4
	call 	RandRange
	cmp 	ax, 0
	je 		moveup
	cmp 	ax, 1
	je 		moveright
	cmp 	ax, 2
	je 		movedown
	cmp 	ax, 3
	je 		moveleft

	moveright:
	inc 	cl
	mov 	al, 153d
	jmp 	check

	moveleft:
	dec 	cl
	mov 	al, 153d
	jmp 	check

	moveup:
	dec 	ch
	mov 	al, 153d
	jmp 	check

	movedown:
	inc 	ch
	mov 	al, 153d

	check:
	push 	ax
	call 	rowcol2index
	mov 	di, ax
	mov 	dx, es:[di]
	pop 	ax
	cmp 	dl, 179d
	je 		nomove
	cmp 	dl, 196d
	je 		nomove
	cmp 	dl, 249d
	je 		move
	cmp 	dl, 3Eh
	je 		lose
	cmp 	dl, 3Ch
	je 		lose
	cmp 	dl, 5Eh
	je 		lose
	cmp 	dl, 76h
	je 		lose
	jmp 	move

	lose:
	mov 	losecond, 1

	move:
	push 	cx
	push 	ax
	cmp 	printstar4, 1
	je 		star
	jmp 	nostar

	star:
	cmp 	dl, 153d
	je 		switch1
	cmp 	dl, 20h
	je 		cond
	jmp 	nosetprintstar

	cond:
	mov 	printstar4, 0
	jmp 	nosetprintstar

	switch1:
	; 00001011b cyan
	; 00001100b red
	; 00001101b pink
	; 00001010b green
	cmp 	dh, 00001011b
	je		switchghost2
	cmp 	dh, 00001100b
	je 		switchghost3
	cmp 	dh, 00001101b
	je 		switchghost4

	switchghost2:
	mov 	bh, printstar1
	mov 	printstar4, bh
	jmp 	nosetprintstar
	switchghost3:
	mov 	bh, printstar2
	mov 	printstar4, bh
	jmp 	nosetprintstar
	switchghost4:
	mov 	bh, printstar3
	mov 	printstar4, bh

	nosetprintstar:
	mov 	ch, gcurrow4
	mov 	cl, gcurcol4
	mov 	al, 249d
	call 	FoodScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001010b
	call 	GhostScreenChar
	jmp 	finish

	nostar:
	cmp 	dl, 153d
	je 		switch2
	cmp 	dl, 249d
	je 		setprintstar
	jmp 	noset

	setprintstar:
	mov 	printstar4, 1
	jmp 	noset

	switch2:
	; 00001011b cyan
	; 00001100b red
	; 00001101b pink
	; 00001010b green
	cmp 	dh, 00001011b
	je		changeghost2
	cmp 	dh, 00001100b
	je 		changeghost3
	cmp 	dh, 00001101b
	je 		changeghost4

	changeghost2:
	mov 	bh, printstar1
	mov 	printstar4, bh
	jmp 	noset
	changeghost3:
	mov 	bh, printstar2
	mov 	printstar4, bh
	jmp 	noset
	changeghost4:
	mov 	bh, printstar3
	mov 	printstar4, bh

	noset:
	mov 	ch, gcurrow4
	mov 	cl, gcurcol4
	mov 	al, 20h
	call 	ScreenChar
	pop 	ax
	pop 	cx
	mov 	ah, 00001010b
	call 	GhostScreenChar
	jmp 	finish

	nomove:
	mov 	ch, gcurrow4
	mov 	cl, gcurcol4

	finish:
	pop 	dx
	pop 	ax
	ret
MoveGhost4 ENDP

Game PROC
	sti
	mov 	dx, points
	cmp		dx, 40
	je 		win
	jmp 	nowin
	win:
	mov 	wincond, 1
	nowin:
	call 	MovePacman
	push 	cx
	call 	MoveGhost1
	mov 	gcurrow1, ch
	mov 	gcurcol1, cl
	call 	MoveGhost2
	mov 	gcurrow2, ch
	mov 	gcurcol2, cl
	call 	MoveGhost3
	mov 	gcurrow3, ch
	mov 	gcurcol3, cl
	call 	MoveGhost4
	mov 	gcurrow4, ch
	mov 	gcurcol4, cl
	pop 	cx
	push 	ax
	push 	dx
	pushf
	call 	DWORD PTR [KeyboardVector]
	pop 	dx
	pop 	ax
	iret
Game ENDP

PacScreenChar PROC
	;; ch - row
	;; cl - col
	;; al - character

	push	ax
	push	di

	mov 	di, 0B800h
	mov 	es, di

	push 	ax
	call 	rowcol2index
	mov 	di, ax
	pop 	ax

	mov 	ah, 00001110b
	mov 	es:[di], ax

	pop 	di
	pop 	ax
	ret
PacScreenChar ENDP

GhostScreenChar PROC
	push	ax
	push	di

	mov 	di, 0B800h
	mov 	es, di

	push 	ax
	call 	rowcol2index
	mov 	di, ax
	pop 	ax

	mov 	es:[di], ax

	pop 	di
	pop 	ax
	ret
GhostScreenChar ENDP

FoodScreenChar PROC
	;; ch - row
	;; cl - col
	;; al - character

	push	ax
	push	di

	mov 	di, 0B800h
	mov 	es, di

	push 	ax
	call 	rowcol2index
	mov 	di, ax
	pop 	ax

	mov 	ah, 00001011b
	mov 	es:[di], ax

	pop 	di
	pop 	ax
	ret
FoodScreenChar ENDP

BoarderScreenChar PROC
	push	ax
	push	di

	mov 	di, 0B800h
	mov 	es, di

	push 	ax
	call 	rowcol2index
	mov 	di, ax
	pop 	ax

	mov 	ah, 00001001b
	mov 	es:[di], ax

	pop 	di
	pop 	ax
	ret
BoarderScreenChar ENDP

ScreenChar PROC
	;; ch - row
	;; cl - col
	;; al - character

	push	ax
	push	di

	mov 	di, 0B800h
	mov 	es, di

	push 	ax
	call 	rowcol2index
	mov 	di, ax
	pop 	ax

	mov 	ah, 00001111b
	mov 	es:[di], ax

	pop 	di
	pop 	ax
	ret
ScreenChar ENDP

rowcol2index PROC
	;; ch - row
	;; cl - col
	;; return
	;; ax - index

	pushf
	push	cx

	mov		ax, 80
	mul		ch
	mov		ch, 0
	add 	ax, cx
	shl		ax, 1

	pop 	cx
	popf
	ret
rowcol2index ENDP

InstallHandler PROC
	;; AL - interrupt number
	;; CS:DX - new handler

	push 	bx
	push	ds

	mov		bx, cs
	mov		ds, bx
	call	SetInterruptVector

	pop		ds
	pop		bx
	ret
InstallHandler ENDP

SetInterruptVector PROC
	;; AL - interrupt number
	;; DS:DX - new handler
	push	ax
	mov		ah, 25h
	int		DOS
	pop		ax
	ret
SetInterruptVector ENDP

RestoreVector PROC
	;; AL - handler number
	;; DX - offset of DWORD containing vector

	push	dx
	push	si
	push	ds

	mov		si, dx
	mov		dx, [si]
	mov		ds, [si + 2]
	call	SetInterruptVector

	pop		ds
	pop		si
	pop		dx
	ret
RestoreVector ENDP

SaveVector PROC
	;; AL - handler number
	;; DX - offset of DWORD to store vector
	push	bx
	push	si
	push	es

	call	GetInterruptVector
	mov		si, dx
	mov		[si], bx
	mov		[si + 2], es

	pop		es
	pop		si
	pop		bx
	ret
SaveVector ENDP

GetInterruptVector PROC
	;; AL - interrupt number
	;; returns:
	;; ES:BX - interrupt
	push	ax
	mov		ah, 35h
	int		DOS
	pop		ax
	ret
GetInterruptVector ENDP

FIRST_SEED = 0100110001110000b
Random16Seed WORD FIRST_SEED

Random16 PROC
	;; returns:
	;; ax - a 16-bit random number
	.386
	pushf
	push	edx
	push	eax

	cmp	Random16Seed, FIRST_SEED
	jne	good
	call Randomize
	good:
	add	Random16Seed, 0FC15h
	movzx	eax, Random16Seed
	mov	edx, 02ABh
	mul	edx
	mov	edx, eax
	shr	edx, 16
	xor	eax, edx
	and	eax, 0FFFFh
	mov	edx, eax

	pop	eax
	mov	ax, dx
	pop	edx
	popf
	ret
Random16 ENDP

Randomize PROC
	;; sets seed to current hundreths of seconds
	pushf
	push	ax
	push	bx
	push	cx
	push	dx

	mov	ah,2Ch
	int	21h		; ch (hrs), cl (mins), dh (sec), dl (hsec)

	mov	bh, 0
	mov	bl, dl

	mov	dh, 0
	mov	dl, dh
	mov	ax, 100
	mul	dx
	add	bx, ax

	mov	dh, 0
	mov	dl, cl
	mov	ax, 6000
	mul	dx
	add	bx, ax

	mov	Random16Seed, bx
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
Randomize ENDP

RandRange PROC
	;; ax - maximum value + 1
	;; returns:
	;; ax - a value between 0 - (ax - 1)
	pushf
	push	bx
	push	dx

	mov	bx, ax
	call Random16
	mov	dx, 0
	div	bx
	mov	ax, dx

	pop	dx
	pop	bx
	popf

	ret
RandRange ENDP

BOARD LABEL 	BYTE
							BYTE "Score:                                                                          "
							BYTE "--------------------------------------------------------------------------------"
			  			BYTE "|* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "|* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "|* * --------- * * * * * * * * * --------------- * * * * * * * ----------- * * |"
							BYTE "|* * |       | * * * * * * * * * * * * | * * * * * * * * * * * |         | * * |"
							BYTE "|* * |       | * * * * * * * * * * * * | * * * * * * * * * * * |         | * * |"
							BYTE "|* * |       | * * * * * * * * * * * * | * * * * * * * * * * * |         | * * |"
							BYTE "|* * |       | * * * * * * * * * * * * | * * * * * * * * * * * |         | * * |"
							BYTE "|* * |       | * * * * * * * * * * * * | * * * * * * * * * * * |         | * * |"
							BYTE "|* * --------- * * * * * * * * * * * * | * * * * * * * * * * * ----------- * * |"
							BYTE "|* * * * * * * * * * * * * * * * --------------- * * * * * * * * * * * * * * * |"
							BYTE "|* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "|* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "|* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "|* * * * ----- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "|* * * * |   | * * * * --------------------------------- * * ------------- * * |"
							BYTE "|* * * * |   | * * * * |                               | * * |           | * * |"
							BYTE "|* * * * |   | * * * * |                               | * * |           | * * |"
							BYTE "|* * * * |   | * * * * |                               | * * |           | * * |"
							BYTE "|* * * * |   | * * * * --------------------------------- * * |           | * * |"
							BYTE "|* * * * |   | * * * * * * * * * * * * * * * * * * * * * * * ------------- * * |"
							BYTE "|* * * * ----- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "|* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * |"
							BYTE "--------------------------------------------------------------------------------"

DrawBoard PROC
		push 	dx
		push 	bx
		push 	si
		push 	cx
		push 	ax

		mov 	bx, OFFSET BOARD
		mov 	si, 0
		mov 	cx, 2000
		top:
		push 	cx
		mov 	cl, curcol
		mov 	ch, currow
		mov 	al, [bx+si]
		cmp 	al, 7CH
		je 		vertboarder
		cmp 	al, 2Dh
		je 		horboarder
		cmp 	al, 20h
		je 		space
		cmp 	al, 2Ah
		je 		food
		jmp 	space
		vertboarder:
		mov 	al, 179d
		call	BoarderScreenChar
		jmp		finish
		horboarder:
		mov 	al, 196d
		call 	BoarderScreenChar
		jmp 	finish
		space:
		call 	ScreenChar
		jmp 	finish
		food:
		mov 	al, 249d
		call 	FoodScreenChar
		finish:
		inc 	curcol
		inc 	si
		mov 	cl, curcol
		cmp 	cl, 80
		je 		setzero
		jmp 	cond
		setzero:
		mov 	curcol, 0
		inc 	currow
		cond:
		pop 	cx
		loop 	top

		pop 	ax
		pop 	cx
		pop 	si
		pop 	bx
		pop 	dx
		ret
DrawBoard ENDP

WinScreen LABEL	BYTE
								BYTE "                                                                                "
								BYTE "                                                                                "
			  				BYTE "--------------------------------------------------------------------------------"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                  You Won!:)                                  |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "--------------------------------------------------------------------------------"

DrawWinScreen PROC
		push 	dx
		push 	bx
		push 	si
		push 	cx
		push 	ax

		mov 	bx, OFFSET WinScreen
		mov 	si, 0
		mov 	cx, 2000
		top:
		push 	cx
		mov 	cl, curcol
		mov 	ch, currow
		mov 	al, [bx+si]
		cmp 	al, 7Ch
		je 		vertboarder
		cmp 	al, 2dh
		je 		horboarder
		jmp 	letter
		vertboarder:
		mov 	al, 179d
		call	BoarderScreenChar
		jmp		finish
		horboarder:
		mov 	al, 196d
		call	BoarderScreenChar
		jmp		finish
		letter:
		call 	ScreenChar
		finish:
		inc 	curcol
		inc 	si
		mov 	cl, curcol
		cmp 	cl, 80
		je 		setzero
		jmp 	cond
		setzero:
		mov 	curcol, 0
		inc 	currow
		cond:
		pop 	cx
		loop 	top

		pop 	ax
		pop 	cx
		pop 	si
		pop 	bx
		pop 	dx
		ret
DrawWinScreen ENDP

LoseScreen LABEL BYTE
								BYTE "                                                                                "
								BYTE "                                                                                "
			  				BYTE "--------------------------------------------------------------------------------"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                  You Lost!:(                                 |"
								BYTE "|                                  Score:                                      |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "|                                                                              |"
								BYTE "--------------------------------------------------------------------------------"

DrawLoseScreen PROC
		push 	dx
		push 	bx
		push 	si
		push 	cx
		push 	ax

		mov 	bx, OFFSET LoseScreen
		mov 	si, 0
		mov 	cx, 2000
		top:
		push 	cx
		mov 	cl, curcol
		mov 	ch, currow
		mov 	al, [bx+si]
		cmp 	al, 7Ch
		je 		vertboarder
		cmp 	al, 2dh
		je 		horboarder
		jmp 	letter
		vertboarder:
		mov 	al, 179d
		call	BoarderScreenChar
		jmp		finish
		horboarder:
		mov 	al, 196d
		call	BoarderScreenChar
		jmp		finish
		letter:
		call 	ScreenChar
		finish:
		inc 	curcol
		inc 	si
		mov 	cl, curcol
		cmp 	cl, 80
		je 		setzero
		jmp 	cond
		setzero:
		mov 	curcol, 0
		inc 	currow
		cond:
		pop 	cx
		loop 	top

		pop 	ax
		pop 	cx
		pop 	si
		pop 	bx
		pop 	dx
		ret
DrawLoseScreen ENDP

FixVector PROC
		mov 	al, INTERRUPT
		mov 	dx, OFFSET KeyboardVector
		call 	RestoreVector

		ret
FixVector ENDP

EndProgram PROC
		call 	SpeakerOff
		mov 	ax, TERMINATE
		int 	DOS
EndProgram ENDP

END main
