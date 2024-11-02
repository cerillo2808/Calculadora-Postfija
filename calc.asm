
INCLUDE macro.asm

.model small                               
.STACK 512
.586                                 
                                           
.DATA                                                               
  entrada DB 25 DUP(20H); la entrada es de maximo 25 chars
  guardarRespuesta DB 9 DUP(0H)
  peticion DB "Ingrese la expresion a calcular: "
  respuesta DB "Resultado: "
  fila DB ?; para imprimir en pantalla
  columna DB ?; para imprimir en pantalla
  parentesisAbiertos DB 0H; cantidad total
  parentesisCerrados DB 0H; cantidad total
  resultado DB 0H; resultado final
  shunting DB 25 DUP(20H); las operaciones ordenadas
  operando1 DB 0
  operando2 DB 0
  operador DB 0
  operadores DB 25 DUP(20H); a utilizarse como pila
  numeros DB 25 DUP(20H); a utilizarse como pila
  tamanoOperadores DW 0; a utilizarse como indice de la pila
  tamanoNumeros DW 0; a utilizarse como indice de la pila
  tamanoShunting DW 0; a utilizarse como indice de la pila
  subexpresion DB 25 DUP (20H)
  recorrido DW 0
  
  
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
    
    
    
    ;calcularM shunting, operando1, operando2, operador, resultado
    ;call imprimirResultado
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

moverAShunting PROC
    mov si, tamanoShunting
    mov al, shunting[si]
    inc tamanoShunting
moverAShunting ENDP

moverANumeros PROC
    mov si, tamanoNumeros
    mov al, numeros[si]
    inc tamanoNumeros
    moverANumeros ENDP

moverAOperadores PROC
    mov si, tamanoOperadores
    mov al, operadores[si]
    inc tamanoOperadores
moverAOperadores ENDP

prioridad PROC
   add al, 30H; convertirlo a ASCII
   cmp al, '+'
   je baja
   mov al, 2; cuando no es + es / o * que es de mas prioridad
   jmp salirPrioridad
baja:
   mov al, 1
salirPrioridad:
   ret
   prioridad ENDP
   
desencadenarParentesis PROC

buscarCierre:
    mov si, tamanoOperadores
    ;mov subexpresion[si], operadores[si]
    ;TO-DO
    
    ret
    desencadenarParentesis ENDP
    
tratarOperador PROC
   cmp tamanoOperadores, 0
   je vacio
   ;si no esta vacio hay que ver si el anterior tiene mas prioridad o no
   call prioridad
   mov bl, al; para preservar la prioridad del actual operador
   mov recorrido, si
   mov si, tamanoOperadores
   dec si
   mov al, operadores[si]
   mov si, recorrido
   call prioridad
   cmp bl, al
   jg mayorPrioridad; actual operador es mayor, va a la pila
   ; si el actual operador es menor, las operaciones anteriores ocupan ser resueltas
   ; TO-DO
   
mayorPrioridad:
   mov al, entrada[si]
   mov recorrido, si
   call moverAOperadores
   mov si, recorrido
   jmp finOperador
   
   ;si operadores no anda vacío
    ;si el anterior es menor, va directo
    ;si el anterior es mayor, guarda al presente, usa pone en shunting el numero, operador, numero, y luego pone presente en operadores
   
vacio:
   mov recorrido, si
   call moverAOperadores
   mov si, recorrido
   jmp finOperador
   
finOperador:
   ret
   tratarOperador ENDP
   
shuntingYard PROC
    call compararParentesisIguales
    cmp al, 0; si retorna 0 significa que no son iguales
    je tirarError
   
    mov cx, 25
    mov si, 0
    
ordenar:
    
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
   
   jmp continuar; ignora espacios
   
esNumero:
   mov recorrido, si
   call moverANumeros
   mov si, recorrido
   jmp continuar
   
esOperador:
   call tratarOperador
   jmp continuar
   
parentesisAbierto:
   mov al, entrada[si]
   mov recorrido, si
   call moverAOperadores
   mov si, recorrido
   jmp continuar
   
parentesisCerrado:
   ;mover todo hasta el parentesis cerrado y llamar macro
   ;mover resultado a numeros
   mov recorrido, si
   call desencadenarParentesis
   mov si, recorrido
   ;call macro
   ;mover resultado a numero
   jmp continuar
   
continuar:
   inc si
   loop ordenar
   
tirarError:
    ; TO-DO manejar error con un bool
    
finShunting:
    ret
shuntingYard ENDP



salir:
    .EXIT

end Begin
