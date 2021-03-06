.MODEL small
.STACK 100h  

.code

OutInt proc
        
   test    ax, ax
   jns     oi1


   mov  cx, ax
   mov     ah, 02h
   mov     dl, '-'
   int     21h
   mov  ax, cx
   neg     ax
oi1:  
    xor     cx, cx
    mov     bx, 10 
oi2:
    xor     dx,dx
    div     bx
    push    dx
    inc     cx
    test    ax, ax
    jnz     oi2
    mov     ah, 02h
oi3:
    pop     dx
    add     dl, '0'
    int     21h
    loop    oi3
    
    ret
 
OutInt endp


ChToInt proc near 
    xor ax, ax
    xor bx, bx  
    
    Bigne:
    mul dexs
    cmp dl, 0h
    je OverFlow2:
    mov ax, 0900h
    mov dx, offset OverFlowed
    int 21h
    mov ax, 4C00h
	int 21h	
    OverFlow2:    
    mov dl, bx+si+2
    inc bx
    cmp dl, 2Dh
    je NotnowNeg: 
    sub dl, 48
    add ax, dx
    cmp ax, 7FFFh
    jle OverFlow1:
    mov ax, 0900h
    mov dx, offset OverFlowed
    int 21h
    mov ax, 4C00h
	int 21h	
    OverFlow1:
    NotnowNeg:
    mov dl, bx+si+2 
    cmp dl, 0Dh
    jne Bigne:
    
    cmp si+2, 2Dh
    jne NegativeTr:
        mov dx, 0FFFFh
        sub dx, ax
        inc dx
        mov ax, dx
    NegativeTr:
    RET
ChToInt endp

start:
    mov ax, @data
    mov ds, ax
    mov ax, 0900h
    mov dx, offset CountMessage
    int 21h
    mov ax, 0A00h
    mov dx, offset sizeCh
    int 21h
    mov si, dx  
    CALL ChToInt
    mov sizeInt, al
    cmp ax, 0001h 
    jg not1:                  ; Cheking for less then 2 elem
        mov ax, 4C00h
	    int 21h
    not1:
    mov ch, 00h
    mov cl, sizeInt
    mov si, offset massInt+1  ;entering massInt size
    mov [si], cx              ;
    mov ax, 0900h
    mov dx, offset NumbersMessage
    int 21h
    xor bp, bp
    EnterNumb:                ;cycle of entering mass
    mov ax, 0A00h
    mov dx, offset NumberCh
    int 21h
    mov si, dx
    CALL ChToInt
    mov si, offset massInt+2
    add si, bp
    add bp, 2h
    mov [si], ax
    cmp ax, MinNumb
    jg MinFinding:     ;Finding Min
    mov MinNumb, ax
    MinFinding:
    cmp ax, MaxNumb
    jl MaxFinding:     ;Finding Max
    mov MaxNumb, ax
    MaxFinding:
    mov ax, 0900h
    mov dx, offset NewString
    int 21h
    sub cx, 1h
    cmp cx, 0h
    jne EnterNumb:
    ;;add si+2, bp           ;;;;;;;;;;;;;;;;;;;;;;;;
    mov [si]+2, '$'
    mov ax, 0900h                   ;Set Min Border
    mov dx, offset MinBorderMess
    int 21h 
    mov ax, 0A00h
    mov dx, offset NumberCh
    int 21h
    mov si, dx
    CALL ChToInt 
    mov si, offset MinBorder
    mov [si], ax
    
    mov ax, 0900h                   ;Set Max Border
    mov dx, offset MaxBorderMess
    int 21h 
    mov ax, 0A00h
    mov dx, offset NumberCh
    int 21h
    mov si, dx
    CALL ChToInt 
    mov si, offset MaxBorder
    mov [si], ax
    
    cmp ax, MinBorder
    jge MaxNotLess: 
        mov ax, 0900h               ;Set Min Border
        mov dx, offset MaxLessMin
        int 21h
        mov ax, 4C00h
	    int 21h
    MaxNotLess:
    ;; END OF TYPING AND TRANSLATING TO INT;;
    mov ax, MaxBorder     ; Looking for A coff
    sub ax, MinBorder
    mov A, ax
    mov ax, MaxNumb
    sub ax, MinNumb
    mov A+2, ax           ;;;;
    mov B+2, ax     ;; by the way there is the same A+2 onto B+2 
    mov ax, MaxBorder
    mul A+2
    mov bx, ax
    mov ax, MaxNumb
    mul A
    sub bx, ax
    mov B, bx
    ;;COFF A AND B was FOUND;;
    xor bp, bp
    mov ch, 00h
    mov cl, sizeInt
    NewNumbersInt:  
    mov si, offset massInt+2
    add si, bp
    add bp, 2h
    mov ax, [si]
    mul A
    add ax, B 
    xor dx, dx   ;;;;;;;;;;;;;;; IMPORTANT IF NOT WORKING DELETE
    div A+2
    mov [si], ax
    mov bx, dx
    mov ax, A+2    ;; difference between normal div and div without remains       
    div double
    ;;cmp dx, 0h
    ;;je DXLow:
        inc ax
    ;;DXLow:
    cmp ax, bx
    jg Arrounding:
        mov ax, [si]
        inc ax
        mov [si], ax        
    Arrounding:
    sub cx, 1h
    cmp cx, 0h
    jne NewNumbersInt: 
    ;; OUTPUTTING IN DEC SYSTEM
    mov ax, 0900h                   ;Output
    mov dx, offset OutPuting
    int 21h   
    
    ;mov ax, offset massInt
    ;mov double, ax  
    mov double, 0h
    output:  
    mov bx, offset massInt
    mov ax, double
    add ax, 2h
    mov double, ax
    add bx, double 
    mov ax, [bx]
    CALL OutInt
    mov cx, massInt+1h 
    mov ch, 0h 
    sub cx, 1h
    mov massInt+1, cx 
    mov ax, 0900h                   
    mov dx, offset NewString
    int 21h
    cmp cx, 0
    jne output:
    
    mov ax, 4C00h
	int 21h   
    
.data       
    sizeCh db 3, ?, 3 dup (?), '$'
    sizeInt db ?
    NumberCh db 7, ?, 7 dup (?), '$'
    massInt dw 61, ?, 61 dup (?), '$'
    MinNumb dw 7FFFh  ;Maximum existed val
    MaxNumb dw 8000h  ;Minimum existed val
    MinBorder dw ?
    MaxBorder dw ?
    A dw ?, ?
    B dw ?, ?
    dexs dw 10 
    double dw 2h
    OverFlowed db 0Ah, 0Dh, "Register OverFlowed", '$'
    CountMessage db "Enter Count of numbers", 0Ah, 0Dh, '$'
    NumbersMessage db 0Ah, 0Dh, "Enter your numbers", 0Ah, 0Dh, '$'
    MinBorderMess db 0Ah, 0Dh, "Enter your Minimal border", 0Ah, 0Dh, '$'
    MaxBorderMess db 0Ah, 0Dh, "Enter your Maximal border", 0Ah, 0Dh, '$'
    MaxLessMin db 0Ah, 0Dh, "Max Border Cannot be less then Min Border" , 0Ah, 0Dh, '$' 
    OutPuting db 0Ah, 0Dh, "That is a result" , 0Ah, 0Dh, '$' 
    NewString db 0Ah, 0Dh, '$'
    ;;massCh db 181, ?, 181 dup (?), '$'
end start