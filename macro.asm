operacion macro ope1, ope2, operador
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
    mov al, ope1
    add al, ope2
    mov ope1, al
    jmp fin

restar:
    mov al, ope1
    sub al, ope2
    mov ope1, al
    jmp fin

dividir:
    mov al, ope1
    cbw
    mov bl, ope2
    div bl
    mov ope1, al
    jmp fin

multiplicar:
    mov al, ope1
    mov bl, ope2
    imul bl
    mov ope1, al
    jmp fin

fin:
endm

calcularM macro vector, op1, op2, operador
    mov cx, 25
    mov si, 1
    mov al, 0 ;va a almacenar el resultado final
    hacerCalculo:
    mov al, [vector]
    mov op1, al
    mov al, [vector + si + 1]
    mov op2, al
    mov al, [vector + si]
    mov operador, al
    operacion op1, op2, operador
    mov [vector], al
    add si, 2
    loop hacerCalculo
endm