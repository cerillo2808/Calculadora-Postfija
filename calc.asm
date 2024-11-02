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
  shunting DB 25 DUP(20H); las operaciones ordenadas
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
    
    cmp al, 0DH; igual a enter
    je analizarEntrada
    
    add al, -30H; cambiar de ascii a binario
    
    mov entrada[si], al; guardar la entrada en el vector
    
    mov ah, 07; comando para imprimir
    mov di, 1684; posicion
    inc si
    mov ax, si
    mov bl, 2h
    mul bl
    add di, ax; cambia la posici?n a [anterior+2]
    mov bl, entrada[si-1]; debido a que si ya fue incrementado, lo que quiero imprimir es el anterior
    call imprimirChar
    call verificarParentesis
    inc columna
    call ponerCursor
    
    loop leerEntrada
    
analizarEntrada:  
    
    mov cx, 11; la hilera es de 32 chars          
    mov si, offset respuesta
    mov di, 1824; posicion de la hilera en pantalla
    call imprimirString
    
    mov al, entrada[0]
    call verificarOperador
    
    mov resultado, bl
    call imprimirResultado
    
    
    
    .EXIT
    
   
   getch PROC    NEAR                        
        MOV     AH,10H                                          
        INT     16H                       
        RET                                                                      
   getch ENDP
   
   leer PROC
   mov cx, 25      ;pide 25 chars
     mov si, 0      ;indice del vector de los mumeros inicializado en 0
       
       leerChar:
         call getch     ;llama a lectura de un (1) caracter, retornado en al
         add al, -30H; cambia de ascii a bin
         mov entrada[si], al ;guardamos el caracter leido en el vector de entrada
         INC si         ;nos movemos a la siguiente posicion
         loop leerChar  ;siguiente iteracion, la CPU ira reduciendo el numero en cx hasta que llegue a 0
         
     RET
   leer ENDP
   
   imprimirChar PROC
   add bl, 30H; cambia de bin a ascii
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
        loop    print; imprime la peticion
        
   ret
   imprimirString ENDP
   
   ponerCursor PROC
   mov ah, 02h; comando para poner el cursor
   mov bh, 00
   mov dh, fila
   mov dl, columna
   int 10h
   ret
   ponerCursor ENDP
   
   suma PROC
   add al, bl; resultado queda en al
   ret
   suma ENDP
   
   division PROC; hay que darle el dividendo a ax
   div al; resultado entero queda en al
   ret
   division ENDP
   
   multiplicacion PROC; hay que darle el otro factor a al
   mul bl; resultado queda en al
   ret
   multiplicacion ENDP
   
   verificarParentesis PROC
   cmp bl, '('; es igual a (, 28H
   je esParentesisAbierto
   cmp bl, ')'; es igual a ), 29H
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
   jmp cerrar; instruccion redundante
cerrar:
   ret
   compararParentesisIguales ENDP
   
   verificarNumero PROC; el numero a verificar ocupa estar en al
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
   
   verificarOperador PROC; el char a verificar ocupa estar en al
   cmp al, '+'
   je siEsOperador
   cmp al, '*'
   je siEsOperador
   cmp al, '/'
   je siEsOperador
   cmp al, '-'
   je siEsOperador
   jmp noEsOperador
   
siEsOperador:
   mov bl, 1
   ret
   
noEsOperador:
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
   ;TO-DO comparacion de al
   inc si
   ;TO-DO recorrer la entrada
   loop ordenar
   
tirarError:
   ;manejar error con un bool
   ret
   shuntingYard ENDP
   
   
   
   
end Begin
