TITLE 'Menu with mouse'
.MODEL SMALL

SetCursorPos MACRO X,Y
    MOV AH, 02h     ;load function 02h to set cursor position
    MOV BH, 00h     ;page number
    MOV DH, X       ;row of the cursor (hex)
    MOV DL, Y       ;column of the cursor (hex)
    INT 10h         ;call DOS
ENDM

PrintString MACRO STRING
    MOV AH, 09h     ;load function 09h to print string
    LEA DX, STRING  ;load string to print (must be terminated with '$')
    INT 21h         ;call DOS
ENDM

ReadInputChar MACRO
    MOV AH, 01h     ;load function 01h to read a character from stdin
    INT 21h         ;call DOS
ENDM

.STACK
.DATA
    num1        DB 0 ;?
    num2        DB 0
    result       DB 0
    lblMenu     DB 'MENU','$'
    lblSumar    DB '[1] Sumar','$'
    lblRestar   DB '[2] Restar','$'
    lblSalir    DB '[3] Salir','$'
    coordX      DB ?, '$'
    coordY      DB ?, '$'
    lblInput1   DB 'Primer valor: ','$'
    lblInput2   DB 'Segundo valor: ','$'
    lblResult   DB 'Resultado: ','$'

.CODE
main PROC FAR
    MOV AX, @DATA
    MOV DS, AX
;----------------------------------- Menu ---------------------------------|
menu:
CALL clrscr
; print menu label
    SetCursorPos 06h,25h
    PrintString lblMenu
; print addition label
    SetCursorPos 08h,20h
    PrintString lblSumar
; print subtraction label
    SetCursorPos 0Ah,20h
    PrintString lblRestar
; print exit label
    SetCursorPos 0ch,20h
    PrintString lblSalir
;----------------------------------- Click ---------------------------------|
 click:
;----- Show cursor on screen -------|
    mov ax, 01h
    int 33h
;----- Listen to mouse click -------|
    mov ax, 03h
    int 33h
;if bx = 1, left click was pressed -> check click coordinates
    cmp bx, 1
    je coordenadas
;if bx = 2, right click was pressed -> listen again
    cmp bx, 2
    jmp click
;--------------------------------- Coordinates ------------------------------|
  coordenadas:
;Get X coordinate from CX and save it in coordX
    mov ax, cx
    mov bl,8
    div bl
    mov coordX, al
;Get Y coordinate from DX and save it in coordY
    mov ax, dx
    mov bl,8
    div bl
    mov coordY, al
;----- Compare X coordinates -------|
    cmp coordx, 33
    ;if coordX > 33, the click was outside the menu -> listen again
    JA click
;----- Compare Y coordinates -------|
;If coordY = 8, the click was on the addition label -> addition
    cmp coordY, 8
    je addition
;If coordY = 10, the click was on the subtraction label -> subtraction
    cmp coordY, 10   ;
    je substraction
;If coordY = 12, the click was on the exit label -> exit
    cmp coordY, 12
    je exit
;If coordY is not 8, 10 or 12, the click wasn't on any label -> listen again
    jmp click
substraction:
jmp subs
;--------------------------------- EXIT ---------------------------------|
exit:
CALL clrscr
CALL clrscr
    MOV AX, 4C00h
    INT 21h
;--------------------------------- ADDITION ----------------------------------|
addition:
CALL clrscr
CALL clrscr
;----------- FIRST VALUE -----------|
    SetCursorPos 0bh,13h
    PrintString lblInput1
    SetCursorPos 0bh,21h
    ReadInputChar
    SUB AL, 30h     ;adjust input (ASCII to decimal)
    MOV num1, AL    ;move AL to num1
;----------- SECOND VALUE ----------|
    SetCursorPos 0bh,28h
    PrintString lblInput2
    SetCursorPos 0bh,37h
    ReadInputChar
    SUB AL, 30h   ;adjust input (ASCII to decimal)
    MOV num2, AL  ;move AL to num2
;-------------- ADD ----------------|
    MOV AL, num1  ;move num1 to AL
    ADD AL, num2  ;add num2 to AL
    MOV result, Al ;move AL (result) to result
;----- print lblResult -----|
    SetCursorPos 0dh,1eh
    PrintString lblResult
;--------- Unpack -----------|
;This block of code unpacks the result in AX because the result can be a
;two digit number. The logic is:
;divide AX value by 10 and save the quotient in AH and the remainder in AL
;then, add 30h to AH and AL to convert them to ASCII and print them
    aam
    MOV bx,ax
;--------------- Print digit1 --------------|
    MOV AH,02h ; load function 02h to print character
    MOV dl, bh ; move BH to DL
    ADD dl,30h ; add 30h to convert to ASCII
    int 21h    ; call DOS
;--------------- Print digit2 --------------|
    MOV ah,02h ; load function 02h to print character
    MOV dl,bl  ; move BL to DL
    ADD dl,30h ; add 30h to convert to ASCII
    int 21h    ; call DOS
;----------- delay -----------|
    MOV AH, 07h
    INT 21h
;----------- return to menu -----------|
    CALL clrscr
    JMP menu
;--------------------------------- SUBSTRACTION ----------------------------------|
subs:
CALL clrscr
CALL clrscr
;----------- FIRST VALUE -----------|
    SetCursorPos 0bh,13h
    PrintString lblInput1
    SetCursorPos 0bh,21h
    ReadInputChar
    SUB AL, 30h   ; substract 30h to convert to decimal
    MOV num1, AL  ; move AL to num1
;---------- SECOND VALUE ----------|
    SetCursorPos 0bh,28h
    PrintString lblInput2
    SetCursorPos 0bh,37h
    ReadInputChar
    SUB AL, 30h   ; substract 30h to convert to decimal
    MOV num2, AL  ; move AL to num2
;-------------- SUBSTRACT ----------------|
    MOV AL, num1    ; move num1 to AL
    SUB AL, num2    ; substract num2 to AL
    MOV result, Al  ; move AL (result) to result
    SetCursorPos 0dh,1eh
    PrintString lblResult
;--------- Unpack -----------|
;Description above
    aam
    MOV bx,ax
    MOV AH,02h
    MOV dl, bh
    ADD dl,30h
    int 21h
    MOV ah,02h
    MOV dl,bl
    ADD dl,30h
    int 21h
    MOV AH, 07h
    INT 21h
    CALL clrscr
    JMP menu
;------------------------------- CLS ------------------------------------|
clrscr PROC
    MOV AH, 06H ;load function 06h to scroll window
    MOV BH, 30h ;background color
    MOV CX, 0000 ;upper left corner
    MOV DX, 184FH ;lower right corner
    INT 10H ;call DOS
    RET
clrscr ENDP
;--------------------------------- END ---------------------------------|
main ENDP
END main