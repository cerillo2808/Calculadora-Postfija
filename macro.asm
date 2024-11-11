;Guarda registros en pila cierto orden
guardarRegistros MACRO reg1, reg2, reg3, reg4, reg5, reg6
    ; se encarga de preguntar si los registros estan vacios y si no lo estan ingresa el dato a la pila
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
    ; se encarga de preguntar si los registros estan vacios y si no lo estan saca el dato a la pila
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
    
;Se encarga de realizar una operacion, decide que operacion hacer a partir de operador
operacion macro ope1, ope2, operador
    cmp operador, '+'
    je sumar
    cmp operador, '/'
    je dividir
    cmp operador, '*'
    je multiplicar
    ; si no se encuentra un operador valido simplemente se descarta y se va al final de la macro
    jmp fin
;Se cargan las cosas necesarias para hacer la operacion, las etiquetas son significativas para cada operacion, se usa en la postfija
sumar:
    mov al, ope1
    add al, ope2
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