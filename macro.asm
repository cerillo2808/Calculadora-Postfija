;Guarda registros en pila cierto orden
guardarRegistros MACRO reg1, reg2, reg3, reg4, reg5, reg6
    IFNB<reg1>
        PUSH reg1
    ENDIF
    IFNB<reg2>
        PUSH reg2
    ENDIF
    IFNB<reg3>
        PUSH reg3
    ENDIF
    IFNB<reg4>
        PUSH reg4
    ENDIF
    IFNB<reg5>
        PUSH reg5
    ENDIF
    IFNB<reg6>
        PUSH reg6
    ENDIF
    ENDM

;Restaura registros de la pila (puestos en orden inverso)
restaurarRegistros MACRO reg1, reg2, reg3, reg4, reg5, reg6
    IFNB<reg1>
        POP reg1
    ENDIF
    IFNB<reg2>
        POP reg2
    ENDIF
    IFNB<reg3>
        POP reg3
    ENDIF
    IFNB<reg4>
        POP reg4
    ENDIF
    IFNB<reg5>
        POP reg5
    ENDIF
    IFNB<reg6>
        POP reg6
    ENDIF
    ENDM
    

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

calcularM macro vector, op1, op2, operador, resultado
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
    mov al, op1
    mov [vector], al
    add si, 2
    loop hacerCalculo
    mov resultado, al
endm