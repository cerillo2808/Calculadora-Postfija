# Primera Tarea Programada de Ensamblador: Evaluador de Expresiones

Universidad de Costa Rica <br />
Escuela de Ciencias de la Computación e Informática <br />
CI-0118 Lenguaje Ensamblador <br />
Profesor: Carlos Vargas <br />
Estudiantes:
- Sebastián Orozco Castillo - C35719
- Liqing Yosery Zheng Lu - C38680

## Descripcion
Este proyecto ha sido programado en ensamblador TASM <br />

El programa evalúa expresiones matemáticas con los operadores '+', '*', '/', y con paréntesis redondos '()'.

## Instrucciones para Ejecutar el Programa
1. Descargar GUI Turbo Assembler disponible en `[https://courses.missouristate.edu/kenvollmar/mars/download.htm](https://sourceforge.net/projects/guitasm8086/)`.
2. Descargar código fuente `calc.asm`.
3. Descargar código fuente `macro.asm`
4. En GUI Turbo Assembler, abrir ambos .asm descargados del paso anterior.
5. Posicionarse en el archivo `calc.asm`.
7. Presione el botón de esamblar.
8. Usar el botón de ejecutar.
9. Seguir instrucciones durante el programa.

## Consideraciones Técnicas
- Cada número separado por un operador sólo podrá ser de un dígito. (0-9)
- Si el usuario se equivoca en la entrada, puede usar backspace para retroceder.
- Se puede salir del programa inmediatamente ingresando `x` o `X`.
- Después de calcular una expresión, se permite calcular otra ingresando cualquier tecla.
- Espacios u otros caracteres no válidos serán manejados como error.
- Paréntesis redondos que no tengan la misma cantidad de abiertos como cerrados serán manejados como error.
- Después de un error, se le pide al usuario que ingrese cualquier tecla para calcular otra expresión.
