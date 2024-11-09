INCLUDE macro.asm

.model small                               
.STACK 512
.586                                 
                                           
.DATA                                                               
  entrada DB 25 DUP(20H); la entrada es de maximo 25 chars
  guardarRespuesta DB 9 DUP(0H)
  peticion DB "Ingrese la expresion a calcular: "
  respuesta DB "Resultado: "
  fila DB ?
  columna DB ?
  parentesisAbiertos DB 0H
  parentesisCerrados DB 0H
  resultado DB 0H
  shunting DB 5,2,3,'*','+',2,'+',22 DUP(20H); las operaciones ordenadas
  operando1 DB 0
  operando2 DB 0
  operador DB 0
  operadores DB 25 DUP(20H)
  numeros DB 25 DUP(20H)
  
.CODE

Begin:                                     
    mov ax, @data     
    mov ds, ax                                           
    cld                                
    mov ax,0B800H                  
    mov es,ax  
              
    mov cx, 32; la hilera es de 32 chars          
    mov si, offset peticion
    mov di, 1620; posicion de la hilera en pantalla        
    call imprimirString
    
    mov cx, 25
    mov si, 0
    mov fila, 10
    mov columna, 43
    
leerEntrada:
    
    call ponerCursor
    
    call getch
    
    cmp al, 'X' ; Verificar si la tecla presionada es 'X'
    je salir
    cmp al, 'x'
    je salir
    cmp al, 0DH ; igual a enter
    je analizarEntrada
    
    add al, -30H ; cambiar de ascii a binario
    
    mov entrada[si], al ; guardar la entrada en el vector
    
    mov ah, 07 ; comando para imprimir
    mov di, 1684 ; posicion
    inc si
    mov ax, si
    mov bl, 2h
    mul bl
    add di, ax ; cambia la posici?n a [anterior+2]
    mov bl, entrada[si-1] ; debido a que si ya fue incrementado, lo que quiero imprimir es el anterior
    call imprimirChar
    call verificarParentesis
    inc columna
    call ponerCursor
    
    loop leerEntrada
    
analizarEntrada:  
    
    mov cx, 11 ; la hilera es de 32 chars          
    mov si, offset respuesta
    mov di, 1824 ; posicion de la hilera en pantalla
    call imprimirString
    call postfija
    call imprimirResultado
    jmp leerEntrada ; Volver a leer entrada despu?s de analizar

getch PROC NEAR                        
    MOV AH,10H                                          
    INT 16H                       
    RET                                                                      
getch ENDP

leer PROC
    mov cx, 25 ; pide 25 chars
    mov si, 0 ; indice del vector de los n?meros inicializado en 0
       
leerChar:
    call getch ; llama a lectura de un (1) caracter, retornado en al
    add al, -30H ; cambia de ascii a bin
    mov entrada[si], al ; guardamos el caracter le?do en el vector de entrada
    INC si ; nos movemos a la siguiente posici?n
    loop leerChar ; siguiente iteraci?n, la CPU ir? reduciendo el n?mero en cx hasta que llegue a 0
         
    RET
leer ENDP
   
imprimirChar PROC
    add bl, 30H ; cambia de bin a ascii
    mov AH, 07H
    mov al, bl
    cld
    stosw
    RET
imprimirChar ENDP
   
imprimirResultado PROC
    mov al, resultado
    mov cx, 9
    mov si, 0
formatearNumeros:
    aam
    mov guardarRespuesta[si], al
    mov al, ah
    INC si
    loop formatearNumeros
    mov cx, 9
    mov si, 8
imprimirUno:
    mov bl, guardarRespuesta[si]
    call imprimirChar
    DEC si
    loop imprimirUno
    RET
imprimirResultado ENDP
   
imprimirString PROC
    mov ah, 07                  
    cld
    
print:                      
    lodsb               
    stosw               
    loop print ; imprime la petici?n
        
    ret
imprimirString ENDP
   
ponerCursor PROC
    mov ah, 02h ; comando para poner el cursor
    mov bh, 00
    mov dh, fila
    mov dl, columna
    int 10h
    ret
ponerCursor ENDP
   
suma PROC
    add al, bl ; resultado queda en al
    ret
suma ENDP
   
division PROC ; hay que darle el dividendo a ax
    div al ; resultado entero queda en al
    ret
division ENDP
   
multiplicacion PROC ; hay que darle el otro factor a al
    mul bl ; resultado queda en al
    ret
multiplicacion ENDP
   
verificarParentesis PROC
    cmp bl, '(' ; es igual a (, 28H
    je esParentesisAbierto
    cmp bl, ')' ; es igual a ), 29H
    jne terminar
    inc parentesisCerrados
    jmp terminar
   
esParentesisAbierto:
    inc parentesisAbiertos
terminar:
    ret
verificarParentesis ENDP
   
compararParentesisIguales PROC
    mov bl, parentesisCerrados
    cmp bl, parentesisAbiertos
    je esIgual
    jmp noEsIgual
esIgual:
    mov al, 1
    jmp cerrar
noEsIgual:
    mov al, 0
    jmp cerrar ; instrucci?n redundante
cerrar:
    ret
compararParentesisIguales ENDP
   
verificarNumero PROC ; el n?mero a verificar ocupa estar en al
    cmp al, 1
    je siEsN
    cmp al, 2
    je siEsN
    cmp al, 3
    je siEsN
    cmp al, 4
    je siEsN
    cmp al, 5
    je siEsN
    cmp al, 6
    je siEsN
    cmp al, 7
    je siEsN
    cmp al, 8
    je siEsN
    cmp al, 9
    je siEsN
    cmp al, 10
    je siEsN
    jmp noEsN
   
siEsN:
    mov bl, 1
    ret
   
noEsN:
    mov bl, 0
    ret
   
verificarNumero ENDP
   
verificarOperador PROC ; el char a verificar ocupa estar en al
    cmp al, '+'
    je siEsO
    cmp al, '*'
    je siEsO
    cmp al, '/'
    je siEsO
    cmp al, '-'
    je siEsO
    jmp noEsO
   
siEsO:
    mov bl, 1
    ret
   
noEsO:
    mov bl, 0
    ret
   
verificarOperador ENDP
   
shuntingYard PROC
    call compararParentesisIguales
    cmp al, 1
    jne tirarError
   
    mov cx, 25
    mov si, 0
ordenar:
    call verificarNumero
    ; TO-DO comparaci?n de al
    inc si
    ; TO-DO recorrer la entrada
    loop ordenar
   
tirarError:
    ; manejar error con un bool
    ret
shuntingYard ENDP

postfija PROC
    ;Se limpian los registros que se van a necesitar para realizar las operaciones
    mov cx, 5
    mov si, 0
    loopGeneral:
        mov al, shunting[si]
        cmp al, '+'
        je armarOperacion
        cmp al, '*'
        je armarOperacion
        cmp al, '/'
        je armarOperacion
        cmp al, 20h
        je saltar
        continuar:
            push ax
            add si, 1
        saltar:
        loop loopGeneral
    
    pop ax
    mov resultado, al
    ret
postfija ENDP

    armarOperacion:
        pop bx
        pop dx
        mov operando1, dl
        mov operando2, bl
        mov operador, al
        operacion operando1, operando2, operador
        mov al, operando1
        jmp continuar
        
    
salir:
    .EXIT

end Begin
