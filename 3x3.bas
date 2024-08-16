'+-------------------------------------------------------------------------+
'|                                 3x3                                     |
'| Autor: German Theler                                                    |
'|                                                                         |
'| Fecha: Dec '97                                                          |
'|                                                                         |
'| Notas: Las imagenes son simples archivos bin, con otra extension.       |
'|        Cada casillero tiene una letra y un numero asignados.            |
'|            Una letra como nombre de variable conteniendo:               |
'|                0 - si no hay nada en el casillero                       |
'|                1 - si hay una ficha del jugador 1                       |
'|                2 - si hay una ficha del jugador 2                       |
'|            Un numero correspondiente a cada digito del teclado numerico |
'|        Cada jugador (1 o 2) tiene asignado cruz o circulo               |
'|                                                                         |
'+-------------------------------------------------------------------------+


'Declaracion de subfunciones

DECLARE SUB Circulo ()
DECLARE SUB Fondo ()
DECLARE SUB Cruz ()
DECLARE SUB Pause ()
DECLARE SUB Espera1 ()
DECLARE SUB Espera2 ()
DECLARE SUB GrabPalette ()
DECLARE SUB FadeDown ()
DECLARE SUB FadeSt ()
DECLARE SUB RestorePalette ()

'Dimensionar variables

DIM SHARED x AS INTEGER, y AS INTEGER, imagen AS STRING
DIM a AS INTEGER, b AS INTEGER, c AS INTEGER, d AS INTEGER, e AS INTEGER
DIM F AS INTEGER, g AS INTEGER, h AS INTEGER, i AS INTEGER, lugar AS INTEGER
DIM jugadas AS INTEGER, z AS INTEGER
DIM juegos AS INTEGER, circulos AS INTEGER, cruces AS INTEGER
DIM texto$(14), jugadores AS INTEGER, computer AS INTEGER, empate AS INTEGER
DIM match AS INTEGER, cont AS INTEGER, numero AS INTEGER, frases AS INTEGER
DIM SHARED pausa AS SINGLE


DIM SHARED r(64) AS INTEGER, g(64) AS INTEGER, b(64) AS INTEGER
DIM SHARED cuent AS SINGLE, rorig(64) AS INTEGER
DIM SHARED gorig(64) AS INTEGER, borig(64) AS INTEGER

' ------------------------ KEYs---------------------
ON ERROR GOTO nokey

PRINT " Searching for key file                  ";

OPEN "3x3.key" FOR INPUT AS #1

    INPUT #1, linea$

CLOSE #1

    DO
    
        cont = cont + 1
        nombre$ = nombre$ + MID$(linea$, cont, 1)
    LOOP WHILE RIGHT$(nombre$, 1) <> CHR$(8)

    nombre$ = LEFT$(nombre$, LEN(nombre$) - 1)
   
    FOR x = 1 TO LEN(nombre$)
        caracter$ = MID$(nombre$, x, 1)
        digito$ = STR$((ASC(caracter$) * 3) - 143)
        total = total + VAL(digito$)
    NEXT x

    pass$ = RIGHT$(linea$, LEN(linea$) - cont)
  
IF total = (VAL(pass$) / 2) - 54 THEN GOTO bien ELSE GOTO nokey

bien:
IF nombre$ = "UNREGISTERED!" THEN PRINT "unregistered version" ELSE PRINT "registered to "; nombre$

' ------------------------ CONFIGURACION ------------------

PRINT " Searching for configuration file        ";

compute$ = " "
matc$ = " "
empat$ = " "

OPEN "config.cfg" FOR BINARY AS #1

    GET #1, 1, compute$
    IF ASC(compute$) <> 1 AND ASC(compute$) <> 2 THEN
                                                    PRINT "invalid cfg file"
                                                    PRINT "   No puedo correr sin la configuracion... ";
                                                    COLOR 15, 0
                                                    PRINT "-L-A-M-M-!-!-!-"
                                                    PRINT
                                                    END
    END IF
   
    GET #1, 2, matc$
    GET #1, 3, empat$

CLOSE #1

computer = ASC(compute$)
match = ASC(matc$)
empate = ASC(empat$)

PRINT "Ok"

' ------------------------ BENCHMARK ------------------

PRINT " Testing CPU speed                       ";

cuenta = 0

comienzo = TIMER
DO
    cuenta = cuenta + 1
LOOP WHILE TIMER - comienzo < 1

PRINT "Ok"


PRINT
PRINT " Now entering 3x3..."

' ----------------------- Empezar la intro -------------------
ON ERROR GOTO nofile

GrabPalette

FadeDown

imagen = "image1.dat"
Fondo

FadeSt

' -------------------------- Muestra Registrado a ......

IF nombre$ = "UNREGISTERED!" THEN
                                    COLOR 14, 0
                                    LOCATE 1, 68
                                    PRINT "UNREGISTERED!"
ELSE

                                    COLOR 15, 0
                                    LOCATE 1, 66 - LEN(nombre$)
                                    PRINT "Registered to: ";
                                    COLOR 14, 0
                                    PRINT nombre$;
END IF

'------------------------------------------------------------

pausa = 1
Pause

COLOR 2, 0
LOCATE 24, 29

PRINT "* Presiona cualquier tecla *";

DO
    entrada$ = INKEY$
    IF entrada$ <> "" THEN GOTO menu
LOOP

' --------------------------- Muestra el menu --------------

menu:

FadeDown

imagen = "image3.dat"
Fondo

FadeSt

x = 0
z = 0
texto$(8) = "Empezar un partido contra la PC"
texto$(10) = "Entrar a un juego de dos jugadores"
texto$(12) = "Cambiar las opciones"
texto$(14) = "Volver al bendito DOS"

COLOR 1, 7

LOCATE 8, 33
PRINT "1 player game"

LOCATE 10, 33
PRINT "2 player game"

LOCATE 12, 33
PRINT "Game options"

LOCATE 14, 33
PRINT "Just quit"

a = 8

DO
   
    entrada$ = INKEY$
    rentrada$ = RIGHT$(entrada$, 1)
      
        IF rentrada$ = RIGHT$(CHR$(72), 1) THEN
                                        a = a - 2
                                        LOCATE 24, 1
                                        PRINT SPACE$(79);
        END IF

        IF rentrada$ = RIGHT$(CHR$(80), 1) THEN
                                        a = a + 2
                                        LOCATE 24, 1
                                        PRINT SPACE$(79);
        END IF

    IF a = 6 THEN a = 14
    IF a = 16 THEN a = 8
   
    COLOR 0, 7
   
    IF NOT a = 8 THEN
                LOCATE a - 2, 29
                PRINT "  "
                LOCATE 8, 29
                PRINT "  "
    END IF
   
    IF NOT a = 14 THEN
                LOCATE 14, 29
                PRINT "  "
                LOCATE a + 2, 29
                PRINT "  "
    END IF

    LOCATE a, 29
    PRINT "Ä>"

    COLOR 14, 0
    centro1 = 40 - (LEN(texto$(a)) \ 2)
    LOCATE 24, centro1
    PRINT texto$(a);
    IF entrada$ = CHR$(27) GOTO sale

LOOP WHILE NOT entrada$ = CHR$(13)

IF a = 8 THEN GOTO UnPlayer
IF a = 10 THEN GOTO DosPlayer
IF a = 12 THEN GOTO opciones
IF a = 14 THEN GOTO sale


'-------------------------EMPIEZA EL JUEGO!!! 1 Jugador -------------

UnPlayer:

juegos = 0
jugadores = 1
circulos = 0
cruces = 0
empatados = 0

empieza:
juegos = juegos + 1

FadeDown

imagen = "image2.dat"            ' Muestra el fondo
Fondo

FadeSt

' ---------------------- Muestra el registered -------------

IF nombre$ = "UNREGISTERED!" THEN
                                    COLOR 14, 0
                                    LOCATE 24, 1
                                    PRINT "UNREGISTERED!";
ELSE

                                    COLOR 15, 0
                                    LOCATE 24, 1
                                    PRINT "Registered to: ";
                                    COLOR 14, 0
                                    PRINT nombre$;
END IF

' ----------------------- Resetea las variables ----------

a = 0
b = 0
c = 0
d = 0
e = 0
F = 0
g = 0
h = 0
i = 0
jugadas = 0

' ---------- Imprime las estadisticas -----------

COLOR 0, 7

LOCATE 14, 75
PRINT juegos

LOCATE 15, 75
PRINT empatados

LOCATE 19, 75
PRINT cruces
                    
LOCATE 21, 75
PRINT circulos

'------- Si la cantidad de juegos jugados es par, empieza el usuario ---

IF juegos \ 2 = juegos / 2 THEN GOTO usuario

LOCATE 5, 63
COLOR 3, 0
PRINT "Juego yo..."

x = 23
y = 10                                     ' juega en el centro
e = 1

IF computer = 1 THEN Circulo ELSE Cruz     ' empieza la computadora

' ---------------- Juega el usuario ---------------------

usuario:

numero = 40          ' busca la frase
frases = 5
GOSUB frase

COLOR 3, 0           ' borra lo que habia antes
LOCATE 5, 61
PRINT "                    "

LOCATE 5, centro     ' imprime la frase
PRINT frase$

numero = 45
frases = 5

LOCATE 7, 61
PRINT "                    "
LOCATE 8, 61
PRINT "                    "

GOSUB frase

LOCATE 7, centro
COLOR 7, 0
PRINT frase$

' --------------------- donde va a jugar?? -------
jugadas = jugadas + 1

' ----------------- Se fija si el juego esta trabado ---------
IF juegos \ 2 <> juegos / 2 THEN IF jugadas = 5 THEN GOTO trabado

donde:
DO
    entrada$ = INKEY$
    lugar = VAL(entrada$)
    IF entrada$ = CHR$(27) THEN GOTO escape
LOOP WHILE lugar <= 0 AND NOT lugar >= 10

GOSUB lugar                            ' Se fija donde jugo el usuario

IF computer = 1 THEN Cruz ELSE Circulo

IF a = 2 AND b = 2 AND c = 2 THEN GOTO ganousr      ' comprueba si el usuario
IF a = 2 AND d = 2 AND g = 2 THEN GOTO ganousr      ' ganousr
IF a = 2 AND e = 2 AND i = 2 THEN GOTO ganousr
IF b = 2 AND e = 2 AND h = 2 THEN GOTO ganousr
IF d = 2 AND e = 2 AND F = 2 THEN GOTO ganousr
IF g = 2 AND h = 2 AND i = 2 THEN GOTO ganousr
IF c = 2 AND F = 2 AND i = 2 THEN GOTO ganousr
IF c = 2 AND e = 2 AND g = 2 THEN GOTO ganousr

' --------------- Juega la maquina ------------
LOCATE 5, 61
COLOR 2, 0
PRINT "  Juego yo...     "

LOCATE 7, 61
PRINT "                   "

piensa:

' ----------------- Se fija si el juego esta trabado ---------
IF juegos \ 2 = juegos / 2 THEN IF jugadas = 5 THEN GOTO trabado

' ------------------ Si el medio esta libre, juega ahi -------

IF e = 0 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF


' --------------------Puedo hacer tateti??

' ------------ A B C --------

IF a = 1 AND b = 1 AND c = 0 THEN
                                x = 41
                                y = 3
                                c = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF a = 1 AND b = 0 AND c = 1 THEN
                                x = 23
                                y = 3
                                b = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF a = 0 AND b = 1 AND c = 1 THEN
                                x = 5
                                y = 3
                                a = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

' ------------ A E I --------

IF a = 1 AND e = 1 AND i = 0 THEN
                                x = 41
                                y = 17
                                i = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF a = 1 AND e = 0 AND i = 1 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF a = 0 AND e = 1 AND i = 1 THEN
                                x = 5
                                y = 3
                                a = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

' ------------ G H I ----------

IF g = 1 AND h = 1 AND i = 0 THEN
                                x = 41
                                y = 17
                                i = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF g = 1 AND h = 0 AND i = 1 THEN
                                x = 23
                                y = 17
                                h = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF g = 0 AND h = 1 AND i = 1 THEN
                                x = 5
                                y = 17
                                g = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF


' -------------- A D G ---------------

IF a = 1 AND d = 1 AND g = 0 THEN
                                x = 5
                                y = 17
                                g = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF a = 1 AND d = 0 AND g = 1 THEN
                                x = 5
                                y = 10
                                d = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF a = 0 AND d = 1 AND g = 1 THEN
                                x = 5
                                y = 3
                                a = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

' -------------- B E H ---------------

IF b = 1 AND e = 1 AND h = 0 THEN
                                x = 23
                                y = 17
                                h = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF b = 1 AND e = 0 AND h = 1 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF b = 0 AND e = 1 AND h = 1 THEN
                                x = 23
                                y = 3
                                b = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

' ------------ D E F ----------

IF d = 1 AND e = 1 AND F = 0 THEN
                                x = 41
                                y = 10
                                F = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF d = 1 AND e = 0 AND F = 1 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF d = 0 AND e = 1 AND F = 1 THEN
                                x = 5
                                y = 10
                                d = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

' -------------- C F I ---------------

IF c = 1 AND F = 1 AND i = 0 THEN
                                x = 41
                                y = 17
                                i = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF c = 1 AND F = 0 AND i = 1 THEN
                                x = 41
                                y = 10
                                F = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF c = 0 AND F = 1 AND i = 1 THEN
                                x = 41
                                y = 3
                                c = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

' --------- C E G ----------

IF c = 1 AND e = 1 AND g = 0 THEN
                                x = 5
                                y = 17
                                g = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF c = 1 AND e = 0 AND g = 1 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

IF c = 0 AND e = 1 AND g = 1 THEN
                                x = 41
                                y = 3
                                c = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO gane
END IF

'--------------------------- No, no puedo ----------------


'------------------------- El jugador .. puede hacer tateti?--------------

'------------- A B C --------

IF a = 2 AND b = 2 AND c = 0 THEN
                                x = 41
                                y = 3
                                c = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF a = 2 AND b = 0 AND c = 2 THEN
                                x = 23
                                y = 3
                                b = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF a = 0 AND b = 2 AND c = 2 THEN
                                x = 5
                                y = 3
                                a = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

' ------------ A E I --------

IF a = 2 AND e = 2 AND i = 0 THEN
                                x = 41
                                y = 17
                                i = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF a = 2 AND e = 0 AND i = 2 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF a = 0 AND e = 2 AND i = 2 THEN
                                x = 5
                                y = 3
                                a = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

' ------------ G H I ----------

IF g = 2 AND h = 2 AND i = 0 THEN
                                x = 41
                                y = 17
                                i = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF g = 2 AND h = 0 AND i = 2 THEN
                                x = 23
                                y = 17
                                h = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF g = 0 AND h = 2 AND i = 2 THEN
                                x = 5
                                y = 17
                                g = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF


' -------------- A D G ---------------

IF a = 2 AND d = 2 AND g = 0 THEN
                                x = 5
                                y = 17
                                g = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF a = 2 AND d = 0 AND g = 2 THEN
                                x = 5
                                y = 10
                                d = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF a = 0 AND d = 2 AND g = 2 THEN
                                x = 5
                                y = 3
                                a = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

' -------------- B E H ---------------

IF b = 2 AND e = 2 AND h = 0 THEN
                                x = 23
                                y = 17
                                h = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF b = 2 AND e = 0 AND h = 2 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF b = 0 AND e = 2 AND h = 2 THEN
                                x = 23
                                y = 3
                                b = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

' ------------ D E F ----------

IF d = 2 AND e = 2 AND F = 0 THEN
                                x = 41
                                y = 10
                                F = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF d = 2 AND e = 0 AND F = 2 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF d = 0 AND e = 2 AND F = 2 THEN
                                x = 5
                                y = 10
                                d = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

' -------------- C F I ---------------

IF c = 2 AND F = 2 AND i = 0 THEN
                                x = 41
                                y = 17
                                i = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF c = 2 AND F = 0 AND i = 2 THEN
                                x = 41
                                y = 10
                                F = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF c = 0 AND F = 2 AND i = 2 THEN
                                x = 41
                                y = 3
                                c = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

' --------- C E G ----------

IF c = 2 AND e = 2 AND g = 0 THEN
                                x = 5
                                y = 17
                                g = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF c = 2 AND e = 0 AND g = 2 THEN
                                x = 23
                                y = 10
                                e = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF

IF c = 0 AND e = 2 AND g = 2 THEN
                                x = 41
                                y = 3
                                c = 1
                                IF computer = 1 THEN Circulo ELSE Cruz
                                GOTO usuario
END IF


' -------------------------No, no  puede -------------------------

' ==================================================================
' ------TODO SE BASA EN ESTO ---------------------------------------
RANDOMIZE TIMER
decision = RND
' ==================================================================

' --Preparar una jugada, cuando tengo el centro y el no juega en las puntas--

IF jugadas = 1 AND e = 1 AND decision < 1 / 2 THEN

    IF b = 2 AND d = 0 THEN
                                    x = 5
                                    y = 10
                                    d = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF
   
    IF d = 2 AND b = 0 THEN
                                    x = 23
                                    y = 3
                                    b = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF

    IF h = 2 AND F = 0 THEN
                                    x = 41
                                    y = 10
                                    F = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF

    IF F = 2 AND h = 0 THEN
                                    x = 23
                                    y = 17
                                    h = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF

ELSE
    GOTO cualquiera
END IF



IF jugadas = 2 AND e = 1 THEN
   
    IF d = 1 AND a = 0 THEN
                                    x = 5
                                    y = 3
                                    a = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF
    IF b = 1 AND a = 0 THEN
                                    x = 5
                                    y = 3
                                    a = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF
    IF F = 1 AND i = 0 THEN
                                    x = 41
                                    y = 17
                                    i = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF
    IF h = 1 AND i = 0 THEN
                                    x = 41
                                    y = 17
                                    i = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF
END IF

' --- Preparar una jugada, cuando tengo el centro y el juega en las puntas ----
IF decision <= 1 / 2 AND jugadas = 1 THEN

    IF e = 1 AND a = 2 THEN
                                    x = 41
                                    y = 17
                                    i = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF

    IF e = 1 AND c = 2 THEN
                                    x = 5
                                    y = 17
                                    g = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF

    IF e = 1 AND g = 2 THEN
                                    x = 41
                                    y = 3
                                    c = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF

    IF e = 1 AND i = 2 THEN
                                    x = 5
                                    y = 3
                                    a = 1
                                    IF computer = 1 THEN Circulo ELSE Cruz
                                    GOTO usuario
    END IF

ELSE
    
    GOTO cualquiera

END IF


' ------ Si no tengo el centro, la primera jugada va en las puntas ---------

IF jugadas = 1 AND e = 2 AND decision < 1 / 2 THEN

    IF decision <= 1 / 5 THEN
                            x = 5
                            y = 3
                            IF NOT a = 0 THEN GOTO piensa
                            a = 1
                            IF computer = 1 THEN Circulo ELSE Cruz
                            GOTO usuario
    END IF

    IF decision > 1 / 5 AND decision <= 2 / 5 THEN
                            x = 41
                            y = 3
                            IF NOT c = 0 THEN GOTO piensa
                            c = 1
                            IF computer = 1 THEN Circulo ELSE Cruz
                            GOTO usuario
    END IF

    IF decision > 2 / 5 AND decision <= 3 / 5 THEN
                            x = 5
                            y = 17
                            IF computer = 1 THEN Circulo ELSE Cruz
                            g = 1
                            IF NOT a = 0 THEN GOTO piensa
                            GOTO usuario
    END IF

    IF decision > 3 / 5 AND decision <= 9 / 10 THEN
                            x = 41
                            y = 17
                            IF NOT i = 0 THEN GOTO piensa
                            i = 1
                            IF computer = 1 THEN Circulo ELSE Cruz
                            GOTO usuario
    END IF

    IF decision > 9 / 10 AND decision < 1 THEN
                            x = 23
                            y = 3
                            IF NOT b = 0 THEN GOTO piensa
                            b = 1
                            IF computer = 1 THEN Circulo ELSE Cruz
                            GOTO usuario
    END IF

ELSE
    GOTO cualquiera
END IF

'------ Juego preferiblemente en las puntas, si no, donde haya lugar -----
cualquiera:

IF decision <= 1.95 / 8 THEN
                        x = 5
                        y = 3
                        IF NOT a = 0 THEN GOTO piensa
                        a = 1
END IF

IF decision > 1.95 / 8 AND decision <= 2 / 8 THEN
                        x = 23
                        y = 3
                        IF NOT b = 0 THEN GOTO piensa
                        b = 1
END IF

IF decision > 2 / 8 AND decision <= 3.95 / 8 THEN
                        x = 41
                        y = 3
                        IF NOT c = 0 THEN GOTO piensa
                        c = 1
END IF

IF decision > 3.95 / 8 AND decision <= 4 / 8 THEN
                        x = 5
                        y = 10
                        IF NOT d = 0 THEN GOTO piensa
                        d = 1
END IF

IF decision > 4 / 8 AND decision <= 4.95 / 8 THEN
                        x = 41
                        y = 10
                        IF NOT F = 0 THEN GOTO piensa
                        F = 1
END IF

IF decision > 4.95 / 8 AND decision <= 6 / 8 THEN
                        x = 5
                        y = 17
                        IF NOT g = 0 THEN GOTO piensa
                        g = 1
END IF

IF decision > 6 / 8 AND decision <= 6.95 / 8 THEN
                        x = 23
                        y = 17
                        IF NOT h = 0 THEN GOTO piensa
                        h = 1
END IF

IF decision > 6.95 / 8 AND decision <= 8 / 8 THEN
                        x = 41
                        y = 17
                        IF NOT i = 0 THEN GOTO piensa
                        i = 1
END IF

IF computer = 1 THEN Circulo ELSE Cruz

GOTO usuario


' ------------------- EMPIEZA EL JUEGO! 2 players ---------

DosPlayer:

juegos = 0
jugadores = 2
circulos = 0
cruces = 0
empatados = 0

empieza2:

juegos = juegos + 1

FadeDown

imagen = "image2.dat"            ' Muestra el fondo
Fondo

FadeSt

'---------------Muestra el Registered ---------------------------------

IF nombre$ = "UNREGISTERED!" THEN
                                    COLOR 14, 0
                                    LOCATE 24, 1
                                    PRINT "UNREGISTERED!";
ELSE

                                    COLOR 15, 0
                                    LOCATE 24, 1
                                    PRINT "Registered to: ";
                                    COLOR 14, 0
                                    PRINT nombre$;
END IF

' ----------------------- Resetea las variables ----------

a = 0
b = 0
c = 0
d = 0
e = 0
F = 0
g = 0
h = 0
i = 0
jugadas = 0

' ---------- Imprime las estadisticas -----------

COLOR 0, 7

LOCATE 14, 75
PRINT juegos

LOCATE 15, 75
PRINT empatados

LOCATE 19, 75
PRINT cruces
                   
LOCATE 21, 75
PRINT circulos

pregunta:
' --------------------- donde va a jugar?? -------
jugadas = jugadas + 1

' ----------------- Se fija si el juego esta trabado ---------
IF jugadas = 10 THEN GOTO trabado

' ------------------------------------------------
COLOR 7, 0

LOCATE 5, 61
PRINT "                    "
LOCATE 7, 61
PRINT "En que lugar jugas? "
LOCATE 8, 61
PRINT "                    "

LOCATE 5, 61
PRINT "                    "

' ------------- Imprime quien juega-----------

IF juegos \ 2 = juegos / 2 THEN
                        IF jugadas / 2 = jugadas \ 2 THEN
                                            COLOR 3, 0
                                            numero = 55
                                            frases = 5

                                            GOSUB frase

                                            LOCATE 5, centro
                                            PRINT frase$
                        ELSE
                                            COLOR 2, 0
                                            numero = 50
                                            frases = 5
                                          
                                            GOSUB frase

                                            LOCATE 5, centro
                                            PRINT frase$
                        END IF
END IF

IF juegos \ 2 <> juegos / 2 THEN
                        IF jugadas / 2 = jugadas \ 2 THEN
                                            COLOR 2, 0
                                            numero = 50
                                            frases = 5
                                         
                                            GOSUB frase

                                            LOCATE 5, centro
                                            PRINT frase$
                       
                        ELSE
                                            COLOR 3, 0
                                            numero = 55
                                            frases = 5

                                            GOSUB frase

                                            LOCATE 5, centro
                                            PRINT frase$
                        END IF
END IF

donde2:
DO
    entrada$ = INKEY$
    lugar = VAL(entrada$)
    IF entrada$ = CHR$(27) THEN GOTO escape
LOOP WHILE lugar <= 0 AND NOT lugar >= 10

GOSUB lugar                            ' Se fija donde jugo uno

IF juegos \ 2 = juegos / 2 THEN
                        IF jugadas / 2 = jugadas \ 2 THEN Cruz ELSE Circulo
ELSE
                        IF jugadas / 2 = jugadas \ 2 THEN Circulo ELSE Cruz
END IF


' -------------- Se fija si ganaron las cruces --------
IF a = 2 AND b = 2 AND c = 2 THEN GOTO gano2
IF a = 2 AND d = 2 AND g = 2 THEN GOTO gano2
IF a = 2 AND e = 2 AND i = 2 THEN GOTO gano2
IF b = 2 AND e = 2 AND h = 2 THEN GOTO gano2
IF d = 2 AND e = 2 AND F = 2 THEN GOTO gano2
IF g = 2 AND h = 2 AND i = 2 THEN GOTO gano2
IF c = 2 AND F = 2 AND i = 2 THEN GOTO gano2
IF c = 2 AND e = 2 AND g = 2 THEN GOTO gano2
                                          
' ---------------- Se fija si ganaron los circulos ------
IF a = 1 AND b = 1 AND c = 1 THEN GOTO gano1
IF a = 1 AND d = 1 AND g = 1 THEN GOTO gano1
IF a = 1 AND e = 1 AND i = 1 THEN GOTO gano1
IF b = 1 AND e = 1 AND h = 1 THEN GOTO gano1
IF d = 1 AND e = 1 AND F = 1 THEN GOTO gano1
IF g = 1 AND h = 1 AND i = 1 THEN GOTO gano1
IF c = 1 AND F = 1 AND i = 1 THEN GOTO gano1
IF c = 1 AND e = 1 AND g = 1 THEN GOTO gano1
       
GOTO pregunta

lugar:
IF jugadores = 1 THEN

    SELECT CASE lugar

        CASE IS = 1
                        IF g <> 0 THEN GOTO ocupado
                        x = 5
                        y = 17
                        g = 2
        CASE IS = 2
                        IF h <> 0 THEN GOTO ocupado
                        x = 23
                        y = 17
                        h = 2
        CASE IS = 3
                        IF i <> 0 THEN GOTO ocupado
                        x = 41
                        y = 17
                        i = 2
        CASE IS = 4
                        IF d <> 0 THEN GOTO ocupado
                        x = 5
                        y = 10
                        d = 2
        CASE IS = 5
                        IF e <> 0 THEN GOTO ocupado
                        x = 23
                        y = 10
                        e = 2
        CASE IS = 6
                        IF F <> 0 THEN GOTO ocupado
                        x = 41
                        y = 10
                        F = 2
        CASE IS = 7
                        IF a <> 0 THEN GOTO ocupado
                        x = 5
                        y = 3
                        a = 2
        CASE IS = 8
                        IF b <> 0 THEN GOTO ocupado
                        x = 23
                        y = 3
                        b = 2
        CASE IS = 9
                        IF c <> 0 THEN GOTO ocupado
                        x = 41
                        y = 3
                        c = 2

    END SELECT
END IF

IF jugadores = 2 THEN
   
    SELECT CASE lugar

        CASE IS = 1
                        IF g <> 0 THEN GOTO ocupado
                        x = 5
                        y = 17
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN g = 2 ELSE g = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN g = 1 ELSE g = 2
        CASE IS = 2
                        IF h <> 0 THEN GOTO ocupado
                        x = 23
                        y = 17
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN h = 2 ELSE h = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN h = 1 ELSE h = 2
       
        CASE IS = 3
                        IF i <> 0 THEN GOTO ocupado
                        x = 41
                        y = 17
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN i = 2 ELSE i = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN i = 1 ELSE i = 2
        CASE IS = 4
                        IF d <> 0 THEN GOTO ocupado
                        x = 5
                        y = 10
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN d = 2 ELSE d = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN d = 1 ELSE d = 2
                       
        CASE IS = 5
                        IF e <> 0 THEN GOTO ocupado
                        x = 23
                        y = 10
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN e = 2 ELSE e = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN e = 1 ELSE e = 2
        CASE IS = 6
                        IF F <> 0 THEN GOTO ocupado
                        x = 41
                        y = 10
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN F = 2 ELSE F = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN F = 1 ELSE F = 2
                       
        CASE IS = 7
                        IF a <> 0 THEN GOTO ocupado
                        x = 5
                        y = 3
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN a = 2 ELSE a = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN a = 1 ELSE a = 2
        CASE IS = 8
                        IF b <> 0 THEN GOTO ocupado
                        x = 23
                        y = 3
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN b = 2 ELSE b = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN b = 1 ELSE b = 2
        CASE IS = 9
                        IF c <> 0 THEN GOTO ocupado
                        x = 41
                        y = 3
                        IF juegos \ 2 = juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN c = 2 ELSE c = 1
                        IF juegos \ 2 <> juegos / 2 THEN IF jugadas / 2 = jugadas \ 2 THEN c = 1 ELSE c = 2

    END SELECT

END IF

RETURN


' ------------------------------ JUEGO TRABADO ------------------
trabado:
COLOR 7, 0
LOCATE 5, 61
PRINT "                   "

numero = 20
frases = 10

GOSUB frase

LOCATE 5, centro
PRINT frase$

LOCATE 7, 61
PRINT "                   "
LOCATE 8, 61
PRINT "                   "

empatados = empatados + 1

IF juegos = empate THEN GOTO muchosjuegos

pausa = 2
Pause

LOCATE 1, 1
COLOR 7, 0

IF jugadores = 1 THEN GOTO empieza ELSE GOTO empieza2

' ------------------------ Casillero ya ocupado --------------
ocupado:

LOCATE 5, 61
COLOR 11, 0
PRINT "                   "

numero = 30
frases = 10

GOSUB frase

LOCATE 5, centro
PRINT frase$

LOCATE 7, 61
COLOR 10, 0
PRINT "  Lugar ocupado!!  "
LOCATE 8, 61
COLOR 2, 0
PRINT "  Juga de nuevo.   "

IF jugadores = 1 THEN GOTO donde ELSE GOTO donde2

' -------------------------- GANO LA COMPUTER -----------------

gane:

COLOR 10, 0
LOCATE 5, 61
PRINT "                   "

numero = 0
frases = 10

GOSUB frase

LOCATE 5, centro
PRINT frase$

IF computer = 1 THEN circulos = circulos + 1 ELSE cruces = cruces + 1

IF computer = 1 AND circulos = match OR computer = 2 AND cruces = match THEN

                    LOCATE 7, 61
                    COLOR 11, 0
                    PRINT "   Te gane todo!   "
                  
                    LOCATE 8, 61
                    COLOR 3, 0
                    PRINT " Che, queres jugar "
                    LOCATE 9, 61
                    PRINT "     otro? (S/N)   "
                   
                    DO
                        entrada$ = INKEY$
                        IF entrada$ = "S" OR entrada$ = "s" THEN
                                                                empatados = 0
                                                                juegos = 0
                                                                circulos = 0
                                                                cruces = 0
                                                                GOTO empieza
                        END IF
                        IF entrada$ = "N" OR entrada$ = "n" THEN GOTO menu

                    LOOP

ELSE

                    LOCATE 7, 61
                    PRINT "                   "
                    LOCATE 8, 61
                    PRINT "                   "
END IF

IF juegos = empate THEN GOTO muchosjuegos

pausa = 3
Pause

GOTO empieza

' -------------------------- GANO EL USER --------------------

ganousr:

COLOR 12, 0
LOCATE 5, 61
PRINT "                  "

numero = 10
frases = 10

GOSUB frase

LOCATE 5, centro
PRINT frase$

IF computer = 1 THEN cruces = cruces + 1 ELSE circulos = circulos + 1

IF computer = 1 AND cruces = match OR computer = 2 AND circulos = match THEN

                    LOCATE 7, 61
                    COLOR 11, 0
                    PRINT "Me ganaste el match!"
                   
                    LOCATE 8, 60
                    COLOR 3, 0
                    PRINT "Supongo que me daras"
                    LOCATE 9, 61
                    PRINT " la revancha (S/N)"
                    DO
                        entrada$ = INKEY$
                        IF entrada$ = "S" OR entrada$ = "s" THEN
                                                            empatados = 0
                                                            juegos = 0
                                                            circulos = 0
                                                            cruces = 0
                                                            GOTO empieza
                        END IF
                        IF entrada$ = "N" OR entrada$ = "n" THEN GOTO menu

                    LOOP

ELSE

                    LOCATE 7, 61
                    PRINT "                   "
                    LOCATE 8, 61
                    PRINT "                   "
END IF

IF juegos = empate THEN GOTO muchosjuegos

pausa = 3
Pause

GOTO empieza

' ---------------------- Ganaron los circulos -----------------
gano1:
LOCATE 10, 5

COLOR 14, 0
LOCATE 5, 61
PRINT "                    "

numero = 62
frases = 2

GOSUB frase

LOCATE 5, centro
PRINT frase$

circulos = circulos + 1

IF circulos = match THEN

                    LOCATE 7, 61
                    COLOR 11, 0
                    PRINT "Ganaron los circulos! "
                 
                    LOCATE 8, 61
                    COLOR 3, 0
                    PRINT " Che, quieren jugar "
                    LOCATE 9, 61
                    PRINT "     otro? (S/N)    "
                  
                    DO
                        entrada$ = INKEY$
                        IF entrada$ = "S" OR entrada$ = "s" THEN
                                                                empatados = 0
                                                                juegos = 0
                                                                circulos = 0
                                                                cruces = 0
                                                                GOTO empieza2
                        END IF
                        IF entrada$ = "N" OR entrada$ = "n" THEN GOTO menu

                    LOOP

ELSE

                    LOCATE 7, 61
                    PRINT "                   "
                    LOCATE 8, 61
                    PRINT "                   "
END IF

IF juegos = empate THEN GOTO muchosjuegos

pausa = 3
Pause

GOTO empieza2

' ------------------- Gano Player 2 --------------
gano2:

LOCATE 10, 5

COLOR 15, 0
LOCATE 5, 61
PRINT "                    "

numero = 60
frases = 2

GOSUB frase

LOCATE 5, centro
PRINT frase$

cruces = cruces + 1

IF cruces = match THEN

                    LOCATE 7, 61
                    COLOR 11, 0
                    PRINT " Las cruces ganaron "
                 
                    LOCATE 8, 61
                    COLOR 3, 0
                    PRINT "  el match. Juegan  "
                    LOCATE 9, 61
                    PRINT "    otro? (S/N)     "
                  
                    DO
                        entrada$ = INKEY$
                        IF entrada$ = "S" OR entrada$ = "s" THEN
                                                                empatados = 0
                                                                juegos = 0
                                                                circulos = 0
                                                                cruces = 0
                                                                GOTO empieza2
                        END IF
                        IF entrada$ = "N" OR entrada$ = "n" THEN GOTO menu

                    LOOP

ELSE

                    LOCATE 7, 61
                    PRINT "                   "
                    LOCATE 8, 61
                    PRINT "                   "
END IF

IF juegos = empate THEN GOTO muchosjuegos

pausa = 3
Pause

GOTO empieza2


' -------------------- El usuario apreto ESCAPE ----------------
escape:

COLOR 7, 0

LOCATE 5, 61
PRINT "                   "

numero = 64
frases = 5

GOSUB frase

LOCATE 5, centro
PRINT frase$

jugadas = jugadas - 1

LOCATE 7, 61
PRINT "                   "
LOCATE 8, 61
PRINT "                   "

DO
    entrada$ = INKEY$
    IF entrada$ = "S" OR entrada$ = "s" THEN GOTO menu
    IF entrada$ = "N" OR entrada$ = "n" THEN IF jugadores = 1 THEN GOTO usuario ELSE GOTO pregunta
LOOP

muchosjuegos:
COLOR 3, 0

LOCATE 5, 61
PRINT "   Pasaron muchos  "

LOCATE 6, 61
PRINT "juegos. Nadie gano."
COLOR 2, 0
LOCATE 8, 61
PRINT "Quedaron empatados."

WHILE INKEY$ = ""
WEND
GOTO menu


' ---------------------------------------------------
opciones:

FadeDown
imagen = "image3.dat"
Fondo

COLOR 1, 7

FOR x = 7 TO 15
    LOCATE x, 25
    PRINT SPACE$(30)
NEXT x

LOCATE 8, 31
PRINT "La computer usa ";

IF computer = 1 THEN
                    COLOR 10, 7
                    PRINT "O"
END IF

IF computer = 2 THEN
                    COLOR 14, 7
                    PRINT "X"
END IF

COLOR 1, 7

LOCATE 10, 31
PRINT "Los match son a"; match

LOCATE 12, 31
PRINT "Se declara empate a"; empate

LOCATE 14, 31
PRINT "Grabar y volver"

x = 0
z = 0
texto$(8) = "Elegir con que piezas juega la PC en un juego de 1 player"
texto$(10) = "Numero de partidos ganados necesarios para ganar el match"
texto$(12) = "Numero de partidos que se tienen que jugar para que sea empate"
texto$(14) = "Grabar la configuracion y volver al menu"

FadeSt

    OUT &HF388, &HB0
    Espera1
 
    OUT &HF389, &H0
    Espera2

a = 8

DO
  
    entrada$ = INKEY$
    rentrada$ = RIGHT$(entrada$, 1)
     
        IF rentrada$ = RIGHT$(CHR$(72), 1) THEN
                                        a = a - 2
                                        LOCATE 24, 1
                                        PRINT SPACE$(79);
        END IF

        IF rentrada$ = RIGHT$(CHR$(80), 1) THEN
                                        a = a + 2
                                        LOCATE 24, 1
                                        PRINT SPACE$(79);
        END IF

    IF a = 6 THEN a = 14
    IF a = 16 THEN a = 8
  
    COLOR 0, 7
  
    IF NOT a = 8 THEN
                LOCATE a - 2, 27
                PRINT "  "
                LOCATE 8, 27
                PRINT "  "
    END IF
  
    IF NOT a = 14 THEN
                LOCATE 14, 27
                PRINT "  "
                LOCATE a + 2, 27
                PRINT "  "
    END IF

    LOCATE a, 27
    PRINT "Ä>"

    COLOR 14, 0
    centro1 = 40 - (LEN(texto$(a)) \ 2)
    LOCATE 24, centro1
    PRINT texto$(a);
    IF entrada$ = CHR$(27) GOTO menu

LOOP WHILE NOT entrada$ = CHR$(13)

IF a = 8 THEN

            IF computer = 1 THEN
                                computer = 2
                                GOTO opciones
            END IF
            IF computer = 2 THEN
                                computer = 1
                                GOTO opciones
            END IF
END IF

sigue:

IF a = 10 THEN
                LOCATE 24, 1
                PRINT SPACE$(79);
                LOCATE 24, 10
                COLOR 14, 0
                INPUT "Con cuantos partidos ganados queres que se gane el match? ", matc$
               
                IF VAL(matc$) < 1 OR VAL(matc$) > 255 THEN
                                                LOCATE 24, 1
                                                PRINT SPACE$(79)
                                                LOCATE 24, 25
                                                COLOR 14, 0
                                                PRINT "Ese valor tiene que ser > 0 y < 255!!"

                                                WHILE INKEY$ = ""
                                                WEND
                ELSE match = VAL(matc$)

                END IF

END IF

IF a = 12 THEN
                LOCATE 24, 1
                PRINT SPACE$(79);
                LOCATE 24, 10
                COLOR 14, 0
                INPUT "Con cuantos partidos queres que se declare empate? ", empat$
              
                IF VAL(empat$) < 1 OR VAL(empat$) > 255 THEN
                                                LOCATE 24, 1
                                                PRINT SPACE$(79)
                                                LOCATE 24, 25
                                                COLOR 14, 0
                                                PRINT "Ese valor tiene que ser > 0 y < 255!!"

                                                WHILE INKEY$ = ""
                                                WEND
                ELSE empate = VAL(empat$)

                END IF

END IF

IF a = 14 THEN

                OPEN "config.cfg" FOR BINARY AS #1

                    PUT #1, 1, computer
                    PUT #1, 2, match
                    PUT #1, 3, empate
               
                CLOSE #1
                GOTO menu
END IF

GOTO opciones

frase:
RANDOMIZE TIMER

frase$ = ""

OPEN "frases.dat" FOR INPUT AS #1
   
    FOR x = 1 TO numero + INT(RND * frases) + 1
    
        INPUT #1, linea$

    NEXT x
           
            FOR y = 1 TO LEN(linea$)

                caracter$ = MID$(linea$, y, 1)

                newcar$ = CHR$(ASC(caracter$) - 102)

                frase$ = frase$ + newcar$

            NEXT y
       
CLOSE #1

centro = 70 - (LEN(frase$) \ 2)

RETURN

nokey:
COLOR 4, 0
PRINT
PRINT "invalid key file"
COLOR 7, 0
PRINT "   Trata de crackearlo bien, please..."
PRINT
END

nofile:
CLS
COLOR 4, 0
PRINT
PRINT "File not found"
COLOR 7, 0
PRINT "   Se termina el programa"
PRINT
END


sale:
FadeDown

COLOR 7, 0
CLS

FadeSt

OUT &HF388, &HB0
Espera1

OUT &HF389, &H0
Espera2

RestorePalette

IF nombre$ = "UNREGISTERED!" THEN

    PRINT "REGISTRATE!! NO SEAS ASI!! Si total es gratis... lee la documentacion para"
    PRINT "ver como... o crackealo..."

ELSE

    PRINT "Espero que te hayas divertido, "; nombre$; "."
    PRINT "Y volve que te espero practicando!"

END IF

END

SUB Circulo

COLOR 10, 0

LOCATE y, x
PRINT "    ÜÜÜ    "
LOCATE y + 1, x
PRINT "       ßßÜ "

pausa = .1
Pause

LOCATE y + 2, x
PRINT "         ßÜ"
LOCATE y + 3, x
PRINT "         Üß"

pausa = .1
Pause

LOCATE y + 4, x
PRINT "       ÜÜß "
LOCATE y + 5, x
PRINT "    ßßß    "

pausa = .1
Pause

LOCATE y + 4, x
PRINT " ßÜÜ"
LOCATE y + 3, x
PRINT "ßÜ"

pausa = .1
Pause

LOCATE y + 2, x
PRINT "Üß"
LOCATE y + 1, x
PRINT " Üßß"

END SUB

SUB Cruz

COLOR 14, 0

LOCATE y, x
PRINT "ßÜ         "
LOCATE y + 1, x
PRINT "  ßÜ       "

pausa = .1
Pause

LOCATE y + 2, x
PRINT "    ßÜ     "
LOCATE y + 3, x
PRINT "      ßÜ   "

pausa = .1
Pause


LOCATE y + 4, x
PRINT "        ßÜ "
LOCATE y + 5, x
PRINT "          ß"

pausa = .1
Pause

LOCATE y, x
PRINT "ßÜ       Üß"
LOCATE y + 1, x
PRINT "  ßÜ   Üß  "

pausa = .1
Pause

LOCATE y + 2, x
PRINT "    ßÜß    "
LOCATE y + 3, x
PRINT "   Üß ßÜ   "

pausa = .1
Pause

LOCATE y + 4, x
PRINT " Üß     ßÜ "
LOCATE y + 5, x
PRINT "ß         ß"


END SUB

SUB Espera1

    FOR i = 1 TO 6
        a = INP(&H388)
    NEXT i

END SUB

SUB Espera2

    FOR i = 1 TO 35
        a = INP(&H388)
    NEXT i

END SUB

SUB FadeDown

'------------------------- Fade down ----------------------------

    OUT &HF388, &HB0
    Espera1
  
    OUT &HF389, &H0
    Espera2

fadecuenta = 0

FOR x = 63 TO 1 STEP -1

fadecuenta = fadecuenta + 1
IF fadecuenta = 4 THEN fadecuenta = 1

    FOR i = 0 TO 63

        OUT &H3C8, i
   
        IF rorig(i) = 63 THEN r(i) = r(i) - 1
        IF rorig(i) = 42 THEN IF fadecuenta = 1 OR fadecuenta - 2 THEN r(i) = r(i) - 1
        IF rorig(i) = 21 THEN IF fadecuenta = 2 THEN r(i) = r(i) - 1

        IF gorig(i) = 63 THEN g(i) = g(i) - 1
        IF gorig(i) = 42 THEN IF fadecuenta = 1 OR fadecuenta - 2 THEN g(i) = g(i) - 1
        IF gorig(i) = 21 THEN IF fadecuenta = 2 THEN g(i) = g(i) - 1
   
        IF borig(i) = 63 THEN b(i) = b(i) - 1
        IF borig(i) = 42 THEN IF fadecuenta = 1 OR fadecuenta - 2 THEN b(i) = b(i) - 1
        IF borig(i) = 21 THEN IF fadecuenta = 2 THEN b(i) = b(i) - 1

        OUT &H3C9, r(i)
        OUT &H3C9, g(i)
        OUT &H3C9, b(i)

        DO
            a = INP(&H3DA)
        LOOP WHILE a AND 8 = 1

    NEXT i

NEXT x

END SUB

SUB FadeSt

'------------------------- Fade up hasta standar ----------------------------

fadecuenta = 0

FOR x = 1 TO 63

fadecuenta = fadecuenta + 1
IF fadecuenta = 4 THEN fadecuenta = 1

    FOR i = 0 TO 63

        OUT &H3C8, i
   
        IF r(i) < rorig(i) THEN
            IF rorig(i) = 63 THEN r(i) = r(i) + 1
            IF rorig(i) = 42 THEN IF fadecuenta = 1 OR fadecuenta - 2 THEN r(i) = r(i) + 1
            IF rorig(i) = 21 THEN IF fadecuenta = 2 THEN r(i) = r(i) + 1
        END IF

        IF g(i) < gorig(i) THEN
            IF gorig(i) = 63 THEN g(i) = g(i) + 1
            IF gorig(i) = 42 THEN IF fadecuenta = 1 OR fadecuenta - 2 THEN g(i) = g(i) + 1
            IF gorig(i) = 21 THEN IF fadecuenta = 2 THEN g(i) = g(i) + 1
        END IF

        IF b(i) < borig(i) THEN
            IF borig(i) = 63 THEN b(i) = b(i) + 1
            IF borig(i) = 42 THEN IF fadecuenta = 1 OR fadecuenta - 2 THEN b(i) = b(i) + 1
            IF borig(i) = 21 THEN IF fadecuenta = 2 THEN b(i) = b(i) + 1
        END IF

        OUT &H3C9, r(i)
        OUT &H3C9, g(i)
        OUT &H3C9, b(i)
   
        DO
            a = INP(&H3DA)
        LOOP WHILE a AND 8 = 1

    NEXT i

NEXT x

END SUB

SUB Fondo

COLOR 7, 0
CLS

OPEN imagen FOR BINARY AS #1
       
        colr$ = " "
        caracter$ = " "
       
    x = 1
    y = 1

    FOR z = 1 TO 1920
  
        cont = cont + 1
        GET #1, cont, caracter$
        cont = cont + 1
        GET #1, cont, colr$
     
        colr = ASC(colr$)

        colr$ = "&H" + HEX$(colr)
        IF LEN(colr$) = 3 THEN
                                back = 0
                                plano = VAL(colr$)
        ELSE

                                back = VAL(MID$(colr$, 3, 1))
                                plano = VAL("&H" + RIGHT$(colr$, 1))
        END IF
      
        IF x = 81 THEN
                        IF NOT y = 25 THEN
                                    y = y + 1
                                    x = 1
                        END IF
      
        END IF
     
        caracter = ASC(caracter$)

        COLOR plano, back
        PRINT CHR$(caracter);

        x = x + 1

   NEXT z

CLOSE #1

END SUB

SUB GrabPalette

'----------------------------- Grabar la paleta --------------------------

FOR i = 0 TO 63

    OUT &H3C7, i

    r(i) = INP(&H3C9)
    g(i) = INP(&H3C9)
    b(i) = INP(&H3C9)

    rorig(i) = r(i)
    gorig(i) = g(i)
    borig(i) = b(i)

NEXT i


END SUB

SUB Pause

comienzo = TIMER
DO
LOOP WHILE TIMER - comienzo < pausa

END SUB

SUB RestorePalette

'----------------------------- Restaurar Paleta ----------------------------

FOR i = 0 TO 15

    OUT &H3C7, i - 1

    clr = INP(&H3C8)

    OUT &H3C9, rorig(i)
    OUT &H3C9, gorig(i)
    OUT &H3C9, borig(i)

NEXT i

END SUB

