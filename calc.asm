
INCLUDE macro.asm

.model small                               
.STACK 512
.586                                 
                                           
.DATA
  ;vectores:                                                              
  entrada DB 25 DUP(20H); la entrada es de maximo 25 chars
  expresionPostfija DB 25 DUP(20H); el vector ordenado por prioridad  
  
  ;contadores:
  tamanoEntrada DW 0H
  tamanoSubexpresion DW 0H
  tamanoPila DW 0H
  
  ;variables
  guardarRespuesta DB 9 DUP(0H); utilizada para formatear numeros
  fila DB ?; para imprimir en pantalla
  columna DB ?; para imprimir en pantalla
  parentesisAbiertos DB 0H; cantidad total
  parentesisCerrados DB 0H; cantidad total
  recorrido DW 0H; usado para preservar el si de un loop
  entradaActual DB 0H; usado para preservar la lectura actual de un loop
  operando1 DB 0H
  operando2 DB 0H
  operador DB 0H
  resultado DB 0H; resultado final
  
  ;peticiones:
  instrucciones DB "Ingrese Enter para calcular. Ingrese X para salir."; 50 chars
  peticion DB "Ingrese la expresion a calcular: "; 32 chars
  respuesta DB "Resultado: "; 11 chars
  nuevaPeticion DB "Ingrese cualquier tecla para volver a calcular."; 48 chars
  errorParentesis DB "Error: parentesis no cierran correctamente"; 42 chars
  errorChar DB "Error: caracter invalido"; 24 chars
  
.CODE

Begin:                                     
    mov ax, @data     
    mov ds, ax                                           
    cld                                
    mov ax,0B800H                  
    mov es,ax  
    
    mov cx, 50; la hilera es de  chars
    mov si, offset instrucciones
    mov di, 1300; posicio de la hilera en pantalla
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
    mov entradaActual, 0
    call limpiarVectorShunting; proc que sobreescribe todas las posiciones con espacio (20H)
    
    ;recibir la entrada
    mov cx, 25; la entrada es de maximo 25 caracteres
    mov si, 0
    ;la fila y la columna ubican al cursor
    mov fila, 10
    mov columna, 43
    
leerEntrada:
    
    call ponerCursor
    
    call getch; proc que lee un caracter
    
    cmp al, 'X'; Verificar si la tecla presionada es 'X'
    je salir
    cmp al, 'x'
    je salir
    
    cmp al, 08; igual a backspace
    je retroceder
    
    cmp al, 0DH; igual a enter
    je analizarEntrada
    
    add al, -30H; cambiar de ascii a binario
    
    mov entrada[si], al; guardar la entrada en el vector
    
    inc tamanoEntrada; actualizar el contador
    
    mov ah, 07; comando para imprimir
    mov di, 1684; posicion
    inc si; se incrementa el si para que en la siguiente iteracion se guarde en la proxima posicion del vector
    mov ax, si
    mov bl, 2h
    mul bl; multiplica al proximo SI por 2
    add di, ax; cambia la posicion a [anterior+2], sirve para ubicar el char a imprimir
    mov bl, entrada[si-1]; debido a que SI ya fue incrementado, lo que quiero imprimir es el anterior
    call imprimirChar; se imprime lo que el usuario va poniendo
    call verificarParentesis
    inc columna; se mueve el cursor a la izquierda
    call ponerCursor
    
    loop leerEntrada
    
    
analizarEntrada:  
    
    call verificarParentesisIguales
    call ordenar
    call postfija
    
    mov cx, 11; la hilera es de 32 chars          
    mov si, offset respuesta
    mov di, 1824; posicion de la hilera en pantalla
    call imprimirString
    
    call imprimirResultado
    
salirDeCalculo:
    mov cx, 47
    mov si, offset nuevaPeticion
    mov di, 1940
    call imprimirString
    call getch; esperar a que el usuario ingrese cualquier tecla para continuar
    call clearScreen
    
    jmp Begin; Volver a leer entrada despues de analizar
    
retroceder:
    dec columna; se actualiza la posicion del cursor
    dec si; la entrada anterior se sobreescribe
    dec tamanoEntrada; se actualiza el contador
    call clearCursor; el char borrado se quita de pantalla
    call ponerCursor; se pone el cursor en la posicion actualizada
    jmp leerEntrada; se sigue leyendo
    
    ; Fin del flujo
    
    ; PROCS: 
    
    verificarParentesisIguales PROC
    mov al, parentesisCerrados
    cmp al, parentesisAbiertos
    je noHayProblema
    mov cx, 42; la hilera es de 42 chars
    mov si, offset errorParentesis
    mov di, 1780; posicion de la hilera en pantalla
    call imprimirString
    jmp salirDeCalculo
noHayProblema:
    ret
    verificarParentesisIguales ENDP
    
    imprimirErrorChar PROC
    mov cx, 24; la hilera es de 24 chars
    mov si, offset errorChar
    mov di, 1780; posicion de la hilera en pantalla
    call imprimirString
    jmp salirDeCalculo
    ret
    imprimirErrorChar ENDP
    
    limpiarVectorShunting PROC
    mov cx, 25; el vector es de 25 espacios
    mov si, 0
sobreescribir:
    mov expresionPostfija[si], 20H; se sobreescribe lo que sea que haya en el vector con espacio (20H)
    inc si
    loop sobreescribir
    ret
    limpiarVectorShunting ENDP
    
    clearCursor PROC; limpia la posicion en la que esta el cursor                                  
    mov ax, 0600h                             
    mov bh, 07h                               
    mov cx, 0A2Bh
    add cx, si
    mov dx, cx                             
    int 10h                                   
    ret                                       
    clearCursor ENDP
    
    clearScreen PROC; limpia toda la pantalla
    mov ax, 0600h                             
    mov bh, 07h                               
    mov cx, 0000h                             
    mov dx, 184Fh                             
    int 10h                                   
    ret
    clearScreen ENDP

    getch PROC NEAR; lee un caracter                        
    mov ah,10h                                          
    int 16h                       
    ret                                                                      
    getch ENDP
   
    imprimirChar PROC; imrpime un solo char
    add bl, 30H; cambia de bin a ascii
    mov ah, 07H
    mov al, bl
    cld
    stosw
    ret
    imprimirChar ENDP
   
    imprimirResultado PROC
    mov al, resultado
    mov cx, 4
    mov si, 0
formatearNumeros:
    aam; descompone el resultado en sus numeros individuales
    ; en al queda el menor numero
    mov guardarRespuesta[si], al; guarda el numero individual
    mov al, ah; se guarda el resto de los numeros
    inc si
    loop formatearNumeros; se repite hasta que ya no queden numeros
    mov cx, 9
    mov si, 8
imprimirUno:
    mov bl, guardarRespuesta[si]
    call imprimirChar; imprime cada numero individual de la respuesta
    dec si
    loop imprimirUno
    ret
    imprimirResultado ENDP
   
    imprimirString PROC; ocupa de parametros la longitud y el offset de la hilera a imprimir
    mov ah, 07                  
    cld
    
print:                      
    lodsb               
    stosw               
    loop print
        
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
   
    verificarParentesis PROC
    cmp bl, '(' ; es igual a (, 28H
    je esParentesisAbierto
    cmp bl, ')' ; es igual a ), 29H
    jne terminar; si no es abierto ni cerrado, se termina el proc
    inc parentesisCerrados
    jmp terminar
   
esParentesisAbierto:
    inc parentesisAbiertos
    
terminar:
    ret
    verificarParentesis ENDP
   
    compararParentesisIguales PROC
    mov bl, parentesisCerrados
    cmp bl, parentesisAbiertos; Cerrados==Abiertos?
    je esIgual
    jmp noEsIgual
    
esIgual:
    mov al, 1
    jmp cerrar
    
noEsIgual:
    mov al, 0
    
cerrar:
    ret
    compararParentesisIguales ENDP
   
    verificarNumero PROC ; el numero a verificar ocupa estar en al
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
    
    ; si llega hasta aqui es porque no es un operador valido
    jmp noEsOperador
   
siEsOperador:
    add al, -30H; devolverlo a binario
    mov bl, 1
    ret
   
noEsOperador:
    add al, -30H; devolverlo a binario
    mov bl, 0
    ret
   
    verificarOperador ENDP

   prioridad PROC; el operador a analizar ocupa estar en bl
   add bl, 30H; convertirlo a ASCII
   cmp bl, '+'
   je baja
   cmp bl, '('
   je muyBaja
   
   mov bl, 2; cuando no es +, es / o * que es de mas prioridad
   jmp salirPrioridad
   
baja:
   mov bl, 1
   jmp salirPrioridad
   
muyBaja:
   mov bl, 0
   
salirPrioridad:
   ret
   prioridad ENDP; el retorno sobreescribe al operador
   
   ponerEnExpresionPostfija PROC; lo que se pone es al
   mov recorrido, si; preservar si del recorrido original
   mov si, tamanoSubexpresion
   mov expresionPostfija[si], al; se pone al en el vector
   inc tamanoSubexpresion; se actualiza el contador
   mov si, recorrido; devolver el si del recorrido original
   ret
   ponerEnExpresionPostfija ENDP
   
   ordenar PROC; cambia la entrada a una expresion postfija
   mov cx, tamanoEntrada
   mov si, 0
recorrer:
   mov al, entrada[si]
   mov entradaActual, al; preserva el caracter actual en una variable
   
   call verificarNumero
   cmp bl, 1
   je esNumero
   
   call verificarOperador
   cmp bl, 1
   je esOperador
   
   cmp al, -8H; es ( en binario
   je parentesisAbierto
   
   cmp al, -7H; es ) en binario
   je parentesisCerrado
   
   ; si llega hasta aqui es porque es un espacio en blanco u otro caracter
   call imprimirErrorChar; se maneja como error
   
esNumero:
   call ponerEnExpresionPostfija; si es un numero se agrega a la expresion
   jmp continuar
   
saltoTemporal:
   loop recorrer
   jmp salirOrdenar
   
esOperador:
   ;verificar si pila esta vacia
   cmp tamanoPila, 0
   je meterAPila; si la pila esta vacia se mete a la pila
   mov bl, al
   call prioridad
   mov dl, bl; en dl queda la prioridad del operador actual
   pop bx; conseguir el caracter mas arriba de la pila en bl
   push bx; aun no se quiere sacar de la pila, por lo que se agrega de nuevo
   call prioridad; la prioridad del operador anterior queda en bl
   cmp dl, bl; operador actual == operador anterior?
   jg meterAPila; si el operador actual es mayor, se mete a la pila
   ;cuando es menor o igual hay que desapilar los operadores anteriores hasta que se encuentre a uno menor
   
comparar:
   
   mov dh, al; guardar la entrada que se esta leyendo en dh
   
   cmp tamanoPila, 0
   je salirDesapilar; si la pila esta vacia no se desapila mas
   
   pop bx; conseguir el operador de la cima en bl
   push bx; devolverlo por mientras
   call prioridad
   cmp bl, 0; Es parentesis abierto?
   je salirDesapilar; se sale en cuanto se encuentra un parentesis
   cmp bl, dl; prioridad de la cima de la pila contra el simbolo actual
   jl salirDesapilar; si es menor se sale
   
   ; si se llega hasta aqui es porque se tiene que desapilar
   
   pop bx
   mov al, bl
   call ponerEnExpresionPostfija
   dec tamanoPila; se actualiza el contador
   jmp comparar; repetir hasta que encuentre un menor o un parentesis
   
salirDesapilar:
   mov al, entradaActual; devolver a al la entrada
   jmp meterAPila; despues de desapilar, se mete el operador actual en la pila
   
meterAPila:
   push ax
   inc tamanoPila; se actualiza el contador
   jmp continuar
   
parentesisAbierto:
   jmp meterAPila; si es un parentesis abierto se mete directo a la pila
   jmp continuar
   
parentesisCerrado:
   
   ; desapilar hasta encontrar al parentesis abierto (
   
compararCerrado:
   
   cmp tamanoPila, 0; si la pila queda vacia se deja de desapilar
   je salirDesapilarCerrado
   
   pop bx; se guarda la cima de la pila en bl
   push bx; se devuelve a la pila por mientras
   call prioridad; la prioridad de la cima queda en bl
   cmp bl, 0; si es cero es el parentesis abierto (
   je quitarParentesis; se saca el parentesis de la pila y se termina de desapilar
   
   ; si se llega hasta aqui es porque hay que desapilarlo
   
   pop bx; se saca de la pila
   dec tamanoPila; se actualiza el contador
   mov al, bl
   call ponerEnExpresionPostfija; se pone en la expresion
   jmp compararCerrado; repetir hasta que se encuentre al parentesis abierto (
   
quitarParentesis:
   pop bx; se saca el parentesis de la pila
   dec tamanoPila; se actualiza el contador
   jmp salirDesapilarCerrado
   
salirDesapilarCerrado:
   mov al, entradaActual; devolver a al la entrada
   jmp continuar
   
continuar:
   inc si
   jmp saltoTemporal; hacer el loop
   
salirOrdenar:
   ;vaciar la pila
   cmp tamanoPila, 0
   je salirVaciarPila; si no hay nada en la pila, se sale del proc
   
   mov cx, tamanoPila; se usa el contador para saber cuantas iteraciones hacer
quitar:
   pop bx
   dec tamanoPila
   
   ;si son parentesis, no se ponen en la expresion
   cmp bl, -8H; ( en binario
   je continuarQuitar
   cmp bl, -7H; ) en binario
   je continuarQuitar
   
   mov al, bl
   call ponerEnExpresionPostfija
   
continuarQuitar:
   loop quitar
   
salirVaciarPila:
   ret
   ordenar ENDP
   
    postfija PROC
    ;Se limpian los registros que se van a necesitar para realizar las operaciones
    mov cx, 25
    mov si, 0
    loopGeneral:
    mov al, expresionPostfija[si]
        cmp al, 20h
        je saltarPostfija; el espacio vacio indica el final de la expresion postfija
        
        call verificarOperador
        cmp bl, 1; si bl es 1, significa que es un operador
        je armarOperacion
        
    continuarPostfija:
        push ax
            
    saltarPostfija:
        inc si
        loop loopGeneral
        
        ; el resultado final queda en la pila 
        pop ax
        mov resultado, al
        ret
    
    postfija ENDP

    armarOperacion:
        add al, 30H; los operadores se pasan a ascii
        pop bx
        pop dx
        mov operando1, dl
        mov operando2, bl
        mov operador, al
        operacion operando1, operando2, operador; se llama a la macro
        mov al, operando1; en operando1 queda la respuesta de la sub-operacion
        jmp continuarPostfija

salir:
    .EXIT

end Begin
