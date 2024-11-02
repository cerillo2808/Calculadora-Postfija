operacion macro op1, op2, operador
    cmp operador, '+'
    je sumar
    cmp operador, '-'
    je restar
    cmp operador, '/'
    je dividir
    cmp operador, '*'
    je multiplicar
    jmp fin

sumar:
    mov al, op1
    add al, op2
    mov op1, al
    jmp fin

restar:
    mov al, op1
    sub al, op2
    mov op1, al
    jmp fin

dividir:
    mov al, op1
    cbw
    mov bl, op2
    div bl
    mov op1, al
    jmp fin

multiplicar:
    mov al, op1
    mov bl, op2
    imul bl
    mov op1, al
    jmp fin

fin:
endm
