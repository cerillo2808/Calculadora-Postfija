
INCLUDE macro.asm

.model small                               
.STACK 512
.586                                 
                                           
.DATA                                                               
  entrada DB 25 DUP(20H); la entrada es de maximo 25 chars
  tamanoEntrada DW 0H
  guardarRespuesta DB 9 DUP(0H)
  peticion DB "Ingrese la expresion a calcular: "
  respuesta DB "Resultado: "
  instrucciones DB "Ingrese Enter para calcular. Ingrese X para salir."; 50 chars
  nuevaPeticion DB "Ingrese cualquier tecla para volver a calcular."; 48 chars
  fila DB ?; para imprimir en pantalla
  columna DB ?; para imprimir en pantalla
  parentesisAbiertos DB 0H; cantidad total
  parentesisCerrados DB 0H; cantidad total
  resultado DB 0H; resultado final
  operando1 DB 0
  operando2 DB 0
  operador DB 0
  expresionPostfija DB 25 DUP(20H)
  tamanoSubexpresion DW 0H
  tamanoPila DW 0H
  recorrido DW 0H
  direccionOrdenar DB ?
  
  
.CODE

Begin:                                     
    mov ax, @data     
    mov ds, ax                                           
    cld                                
    mov ax,0B800H                  
    mov es,ax  
    
    mov cx, 50
    mov si, offset instrucciones
    mov di, 1300
    call imprimirString
              
    mov cx, 32; la hilera es de 32 chars          
    mov si, offset peticion
    mov di, 1620; posicion de la hilera en pantalla        
    call imprimirString
    
    ;incializar contadores en 0 para soportar mas calculos
    mov tamanoEntrada, 0
    mov parentesisAbiertos, 0
    mov parentesisCerrados, 0
    mov resultado, 0
    mov operando1, 0
    mov operando2, 0
    mov operador, 0
    mov tamanoSubexpresion, 0
    
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
    cmp al, 08; igual a backspace
    je retroceder
    cmp al, 0DH ; igual a enter
    je analizarEntrada
    
    add al, -30H ; cambiar de ascii a binario
    
    mov entrada[si], al ; guardar la entrada en el vector
    inc tamanoEntrada
    
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
    
    ;calcularM shunting, operando1, operando2, operador, resultado
    ;call imprimirResultado
    
    call ordenar
devolverse:
    call imprimirShunting
    
    mov cx, 47
    mov si, offset nuevaPeticion
    mov di, 1940
    call imprimirString
    call getch
    call clearScreen
    
    jmp Begin ; Volver a leer entrada despu?s de analizar
    
retroceder:
    dec columna
    dec si
    dec tamanoEntrada
    call clearCursor
    call ponerCursor
    jmp leerEntrada
    
    imprimirShunting PROC
    mov cx, 25
    mov si, 0
imp:
    mov bl, expresionPostfija[si]
    call imprimirChar
    inc si
    loop imp
    ret
    imprimirShunting ENDP
    
    clearCursor PROC                                  
    mov ax, 0600h                             
    mov bh, 07h                               
    mov cx, 0A2Bh
    add cx, si
    mov dx, cx                             
    int 10h                                   
    RET                                       
    clearCursor ENDP
    
    clearScreen PROC
    mov ax, 0600h                             
        mov bh, 07h                               
        mov cx, 0000h                             
        mov dx, 184Fh                             
        int 10h                                   
        RET
    clearScreen ENDP

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
    loop print
        
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
    jmp cerrar ; instruccion redundante
cerrar:
    ret
compararParentesisIguales ENDP
   
verificarNumero PROC ; el n?mero a verificar ocupa estar en al
    cmp al, 1
    je siEsNumero
    cmp al, 2
    je siEsNumero
    cmp al, 3
    je siEsNumero
    cmp al, 4
    je siEsNumero
    cmp al, 5
    je siEsNumero
    cmp al, 6
    je siEsNumero
    cmp al, 7
    je siEsNumero
    cmp al, 8
    je siEsNumero
    cmp al, 9
    je siEsNumero
    cmp al, 0
    je siEsNumero
    jmp noEsNumero
   
siEsNumero:
    mov bl, 1
    ret
   
noEsNumero:
    mov bl, 0
    ret
   
verificarNumero ENDP
   
verificarOperador PROC ; el char a verificar ocupa estar en al
    add al, 30H; convertirlo a ASCII de nuevo para compararlo
    cmp al, '+'
    je siEsOperador
    cmp al, '*'
    je siEsOperador
    cmp al, '/'
    je siEsOperador
    jmp noEsOperador
   
siEsOperador:
    mov bl, 1
    ret
   
noEsOperador:
    mov bl, 0
    ret
   
verificarOperador ENDP

prioridad PROC
   add bl, 30H; convertirlo a ASCII
   cmp bl, '+'
   je baja
   cmp bl, '('
   je muyBaja
   mov bl, 2; cuando no es + es / o * que es de mas prioridad
   jmp salirPrioridad
baja:
   mov bl, 1
   jmp salirPrioridad
muyBaja:
   mov bl, 0
   jmp salirPrioridad
salirPrioridad:
   ret
   prioridad ENDP
   
   ponerEnExpresionPostfija PROC; lo que se pone es al
   mov recorrido, si; preservar si del recorrido original
   mov si, tamanoSubexpresion
   call verificarNumero
   cmp bl, 1
   je moverlo
   add al, -30H
moverlo:
   mov expresionPostfija[si], al
   inc tamanoSubexpresion
   mov si, recorrido; devolverlo
   ret
   ponerEnExpresionPostfija ENDP
   
   ordenar PROC
   mov cx, tamanoEntrada
   mov si, 0
recorrer:
   mov al, entrada[si]
   
   call verificarNumero
   cmp bl, 1
   je esNumero
   
   call verificarOperador
   cmp bl, 1
   je esOperador
   
   cmp al, '('
   je parentesisAbierto
   
   cmp al, ')'
   je parentesisCerrado

   jmp continuar; ignora espacios en blanco
   
esNumero:
   call ponerEnExpresionPostfija
   jmp continuar
   
saltoConejo:
   loop recorrer
   jmp salirOrdenar
   
esOperador:
   ;verificar si pila esta vacia
   cmp tamanoPila, 0
   mov bl, al
   call prioridad
   mov dl, bl
   pop bx
   push bx
   call prioridad
   cmp dl, bl
   jge meterAPila; mayor igual que
   ;cuando es menor hay que desapilarlo
   
comparar:
   
   mov dh, al; guardar la entrada que se esta leyendo
   
   cmp tamanoPila, 0
   je salirDesapilar
   
   pop bx
   push bx
   call prioridad
   cmp bl, dl
   jl menor; si es menor es que es un parentesis
   
   pop bx
   mov al, bl
   call ponerEnExpresionPostfija
   dec tamanoPila
   jmp comparar; repetir hasta que se salga
   
menor:
   jmp salirDesapilar
   
salirDesapilar:
   mov al, dh; devolver a al la entrada
   jmp meterAPila
   
meterAPila:
   push ax
   inc tamanoPila
   jmp continuar
   
parentesisAbierto:
   call ponerEnExpresionPostfija
   jmp continuar
   
parentesisCerrado:
   ; quitar cosas hasta encontrar a (
   compararC:
   
   mov dh, al; guardar la entrada que se esta leyendo
   
   cmp tamanoPila, 0
   je salirDesapilarC
   
   pop bx
   push bx
   call prioridad
   cmp bl, dl
   jl menorC; si es menor es que es un parentesis
   
   pop bx
   mov al, bl
   call ponerEnExpresionPostfija
   dec tamanoPila
   jmp compararC; repetir hasta que se salga
   
menorC:
   dec tamanoPila
   jmp salirDesapilar
   
salirDesapilarC:
   mov al, dh; devolver a al la entrada
   pop bx; quito el parentesis
   jmp continuar
   
continuar:
   inc si
   ;loop recorrer
   jmp saltoConejo
   
salirOrdenar:
   ;vaciar la pila
   cmp tamanoPila, 0
   je salirVaciarPila
   
   mov cx, tamanoPila
quitar:
   pop bx
   cmp bl, '('
   je continuarQuitar
   mov al, bl
   call ponerEnExpresionPostfija
continuarQuitar:
   loop quitar
   
salirVaciarPila:
   jmp devolverse
   ret
   ordenar ENDP

salir:
    .EXIT

end Begin
