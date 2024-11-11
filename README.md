# Primera Tarea Programada de Ensamblador: Evaluador de Expresiones

Universidad de Costa Rica

Escuela de Ciencias de la Computación e Informática

CI-0118 Lenguaje Ensamblador

Profesor: Carlos Vargas

Estudiantes:

- Sebastián Orozco Castillo - C35719

- Liqing Yosery Zheng Lu - C38680

## Descripcion

Este proyecto ha sido programado en ensamblador TASM

El programa evalúa expresiones matemáticas con los operadores '+', '*', '/', y con paréntesis redondos '()'.

## Instrucciones para Ejecutar el Programa

1. Descargar GUI Turbo Assembler disponible en `[https://courses.missouristate.edu/kenvollmar/mars/download.htm](https://sourceforge.net/projects/guitasm8086/)`.

1. Descargar código fuente `calc.asm`.

1. Descargar código fuente `macro.asm`

1. En GUI Turbo Assembler, abrir ambos .asm descargados del paso anterior.

1. Posicionarse en el archivo `calc.asm`.

1. Presione el botón de esamblar.

1. Usar el botón de ejecutar.

1. Seguir instrucciones durante el programa.

## Consideraciones Técnicas

- Cada número separado por un operador sólo podrá ser de un dígito. (0-9)
- Si el usuario se equivoca en la entrada, puede usar backspace para retroceder.
- Se puede salir del programa inmediatamente ingresando `x` o `X`.
- Después de calcular una expresión, se permite calcular otra ingresando cualquier tecla.
- Espacios u otros caracteres no válidos serán manejados como error.
- Paréntesis redondos que no tengan la misma cantidad de abiertos como cerrados serán manejados como error.
- Después de un error, se le pide al usuario que ingrese cualquier tecla para calcular otra expresión.
