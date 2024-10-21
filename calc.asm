.model small                               
.STACK 512
.586                                 
                                           
.DATA                                                               
  entrada DB 25 DUP(20H); la entrada es de maximo 25 chars
  peticion DB "Ingrese la expresion a calcular: "
  respuesta DB "Resultado: "
  fila DB ?
  columna DB ?
  parentesisAbiertos DB 0
  parentesisCerrados DB 0
  
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
    add al, -30H; cambiar de ascii a binario
    mov entrada[si], al; guardar la entrada en el vector
    
    mov ah, 07; comando para imprimir
    mov di, 1684; posicion
    inc si
    mov ax, si
    mov bl, 2h
    mul bl
    add di, ax; cambia la posición a [anterior+2]
    mov bl, entrada[si-1]; debido a que si ya fue incrementado, lo que quiero imprimir es el anterior
    call imprimirChar
    inc columna
    call ponerCursor
    
    loop leerEntrada
              
    mov cx, 11; la hilera es de 32 chars          
    mov si, offset respuesta
    mov di, 1824; posicion de la hilera en pantalla
    call imprimirString
   
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
   
   
end Begin
