;****************************************************************************/
; Author: Hayden Trunkeyking
; Date: 2 May 2026
; Revision: 1.0
; Title: CS155 Hangman Final Project
;
; Description:  LC-3 hangman game. Program chooses one hardcoded word via our wonderful proffesors ingenius keyboard loop random number idea. Gets
;               typed letter, echoes it and checks it against the know hangman word in memory, a copmparrison is then done against the char pushed
;               and every char in the hardcoded word, that comparrison deams wether a char for the display word changes and if the player gets a strike.
;               program accounts for upper case letters by converting them to lower case prior to that check. loop prints a new hangman graphic every
;               loop based on a strike counter which increments the hangman graphic ptr address. Each subsequent address has a full hangman image
;               with the image gaining a limb with every address incrementation. checks for win and lose conditions towards the end of every loop
;               based on whether the display word still contains underscores and the strike counter respectively. loops/picks new random word on game
;               win or lose.
;
; Registers:
; R0: String addresses / typed character / lowercase character / return values / output char
; R1: Word pointer / display word pointer / temp storage
; R2: Counters / selected word index / temporary comparison value
; R3: Temp char storage / constants loaded from memory
; R4: Current word character / comparison result
; R5: Found letter flag / found counter
; R6: Stack pointer for register saving and restoring
; R7: Subroutine return addresses
;****************************************************************************/

    .ORIG x3000

main

    LD  R6, stackPointer            ; loads x5000(start of stack) address into R6 for stack pointer

    LD  R0, ptrMsgTitle             ; Loads address of title message into R0
    PUTS                            ; Prints title message

    LD  R0, ptrMsgStart             ; Loads start/random prompt into R0
    PUTS                            ; Prints start/random prompt

    JSR waitForRandomWordIndex      ; Waits for key press and returns random index betweeen 0 and 29 in R0
    LD  R1, ptrSelectedWordIndex    ; Loads address of selectedWordIndex variable into R1
    STR R0, R1, #0                  ; Stores random selected word index(R0) at previous lines ptrSelectedWordIndex address

    JSR selectWord                  ; Loads address of selected hardcoded word into R0 via the index now in ptrSelectedWordIndexptr address
    LD  R1, ptrSelectedWordPtr      ; Loads address of selectedword variable into R1 
    STR R0, R1, #0                  ; Stores address of selected word(R0) in selectedWordPtr

    JSR buildBlankWord              ; Builds starting display word as "_____" via loops and storing "_" at each address

    AND R0, R0, #0                  ; Clears R0 so strike count starts at zero
    LD  R1, ptrStrikeCount          ; Loads address of strikeCount variable into R1
    STR R0, R1, #0                  ; Stores 0 in strikeCount via above ptrStrikeCount

mainLoop                            ; Main hangman loop that repeats until game ends via a win or a loss

    JSR printHangmanGraphic         ; Prints hangman graphic based on current strike count

    LD  R0, ptrMsgCurrentWord       ; Loads current word message into R0
    PUTS                            ; Prints current word message

    LD  R0, ptrDisplayWord          ; Loads current displayWord address into R0
    PUTS                            ; Prints blanks and correctly guessed letters

    LD  R0, ptrMsgNewLine           ; Loads newline string into R0
    PUTS                            ; Prints newline

    LD  R0, ptrMsgSelectLetter      ; Loads guess prompt into R0
    PUTS                            ; Prints guess prompt

    JSR inputLetter                 ; Gets typed character, echoes it, and makes it lowercase if needed
    LD  R1, ptrCurrentGuess         ; Loads address of currentGuess variable into R1
    STR R0, R1, #0                  ; Saves lowercase guess character in currentGuess via its address (ptrCurrentGuess) in R1. now we can use the saved char
                                    ; for the check in checkGuessInWord

    LD  R0, ptrMsgNewLine           ; Loads newline string into R0
    PUTS                            ; Prints newline after echoed user input

    JSR checkGuessInWord            ; Checks currentGuess against selected word and updates displayWord
                                    ; R0 returns 0 if letter was not found and positive if it was found

    ADD R0, R0, #0                  ; Checks if R0 is zero(will be zero if no correct letter was found in the selected word compared to user input letter)
    BRz wrongGuess                  ; If R0 == 0 the guessed letter was not found in the games chosen word

correctGuess
    LD  R0, ptrMsgGoodGuess         ; Loads correct guess message into R0
    PUTS                            ; Prints correct guess message
    BR  checkWin                    ; Skips wrong guess logic

wrongGuess
    LD  R0, ptrMsgBadGuess          ; Loads wrong guess message into R0
    PUTS                            ; Prints wrong guess message

    LD  R1, ptrStrikeCount          ; Loads address of strikeCount into R1
    LDR R0, R1, #0                  ; Loads current strike count into R0 via above ptr
    ADD R0, R0, #1                  ; Adds 1 strike for wrong guess
    STR R0, R1, #0                  ; Saves updated strike count

    ADD R0, R0, #-6                 ; Checks if strike count has reached 6 via comparison with -6
    BRzp gameLost                   ; If strike count is 6 or more the player lost

checkWin
    JSR displayWordComplete         ; Checks if displayWord still has underscores
                                    ; R0 returns 1 if complete/ 0 if still incomplete

    ADD R0, R0, #0                  ; Checks completion return value
    BRp gameWon                     ; If R0 is positive(1) word is complete (0 if word is not complete)

    LD  R0, ptrMsgNewLine           ; Loads newline string into R0
    PUTS                            ; Prints newline before looping

    BR  mainLoop                    ; Repeats game loop

gameWon
    JSR printHangmanGraphic         ; Prints final hangman graphic before win message for continuity and style/swag

    LD  R0, ptrMsgWin               ; Loads win message into R0
    PUTS                            ; Prints win message

    LD  R0, ptrDisplayWord          ; Loads displayWord into R0
    PUTS                            ; Prints completed word

    LD  R0, ptrMsgNewLine           ; Loads newline string into R0
    PUTS                            ; Prints newline

    BR  main                        ; Starts next randomized round

gameLost
    JSR printHangmanGraphic         ; Prints completed hangman graphic before lose message

    LD  R0, ptrMsgLose              ; Loads losser message into R0
    PUTS                            ; Prints losser message

    LD  R1, ptrSelectedWordPtr      ; Loads address of selectedWordPtr variable into R1
    LDR R0, R1, #0                  ; Loads selected word address into R0
    PUTS                            ; Prints selected word so player knows they werent cheated

    LD  R0, ptrMsgNewLine           ; Loads newline string into R0
    PUTS                            ; Prints newline

    BR  main                        ; Starts next round

; Main constants table
stackPointer        .FILL x5000
ptrMsgTitle         .FILL msgTitle
ptrMsgStart         .FILL msgStart
ptrMsgCurrentWord   .FILL msgCurrentWord
ptrMsgSelectLetter  .FILL msgSelectLetter
ptrMsgGoodGuess     .FILL msgGoodGuess
ptrMsgBadGuess      .FILL msgBadGuess
ptrMsgWin           .FILL msgWin
ptrMsgLose          .FILL msgLose
ptrMsgNewLine       .FILL msgNewLine
ptrDisplayWord      .FILL displayWord
ptrSelectedWordPtr  .FILL selectedWordPtr
ptrSelectedWordIndex .FILL selectedWordIndex
ptrCurrentGuess     .FILL currentGuess
ptrStrikeCount      .FILL strikeCount

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; inputLetter
;
; Description: Gets one character from keyboard then echoes typed character back to the console then converts uppercase letters to lowercase if needed
;              
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

inputLetter

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

    GETC                            ; Gets one character from keyboard and stores it in R0
    OUT                             ; Echoes typed character back to the console

    JSR toLowercase                 ; Converts R0 to lowercase if it was uppercase A-Z

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET                             ; guessed letter is in R0

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; toLowercase
;
; Description: If R0 contains an uppercase ASCII letter from A to Z adds 32 to make it lowercase. If R0 is already lowercase it leaves R0 the same
;              
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

toLowercase

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R2, R6, #0                  ; Saves R2 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

; Actual subroutine logic

    LD  R1, negAsciiA               ; Loads -65 into R1 for comparing against uppercase A
    ADD R2, R0, R1                  ; R2 = typed character - ASCII A
    BRn doneLowercase               ; If character is before A does not convert it

    LD  R1, negAsciiZ               ; Loads -90 into R1 for comparing against uppercase Z
    ADD R2, R0, R1                  ; R2 = typed character - ASCII Z
    BRp doneLowercase               ; If character is after Z does not convert it

    LD  R1, lowercaseOffset         ; Loads 32(lowerCaseOffset) into R1 because lowercase letters are 32 after uppercase letters
    ADD R0, R0, R1                  ; Converts uppercase letter to lowercase letter if char is in the appropriate range (uppercase letters)

doneLowercase

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R2, R6, #0                  ; Loads R2 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R2)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET

negAsciiA       .FILL #-65
negAsciiZ       .FILL #-90
lowercaseOffset .FILL #32

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; waitForRandomWordIndex
;
; Description: Loops until a key is pressed. Each loop increments a counter from 0-29, the counter value when the key is pressed is returned in R0 and used as
;              the selected word index. This picks a random word based on the timing.
;              
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

waitForRandomWordIndex

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R2, R6, #0                  ; Saves R2 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

; Actual subroutine logic

    AND R0, R0, #0                  ; Clears R0 so random index starts at 0
    LD  R2, negThirtyW              ; Loads -30 for making sure counter cant go above 29 

randomWaitLoop
    ADD R0, R0, #1                  ; Adds 1 to random index each time loop runs
    ADD R1, R0, R2                  ; R1 = random index - 30
    BRn randomNoReset               ; If random index is less than 30, skips reset

    AND R0, R0, #0                  ; sets R0 back to 0 if counter got above 29

randomNoReset
    LDI R1, ptrKBSRW                ; Loads keyboard status register value into R1(ptrKBSRW = xFE00 = key has been pressed = top bit = 1)
    BRzp randomWaitLoop             ; If keyboard is not ready, keeps looping and counting

    LDI R1, ptrKBDRW                ; Reads keyboard data register to clear register (not doing this will save the key press and waste the first turn)

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R2, R6, #0                  ; Loads R2 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R2)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET                             ; R0 now has a random number between 0 and 29 that will be used as an index back in main

negThirtyW .FILL #-30
ptrKBSRW   .FILL xFE00
ptrKBDRW   .FILL xFE02

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; selectWord
;
; Description: Uses selectedWordIndex to pick one address from wordList. selectedWordIndex should contain a number from 0 to 29. increments word
;              list ptr and decrements index counter until it reaches 0 then loads the address of that word in R0
;              
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

selectWord

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R2, R6, #0                  ; Saves R2 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

; Actual subroutine logic

    LEA R1, wordList                ; Loads starting address of wordList pointer table into R1
    LD  R2, selectedWordIndex       ; Loads selected word index into R2

wordIndexLoop
    ADD R2, R2, #0                  ; Checks if selected index counter is zero
    BRz wordIndexFound              ; If zero we have the selected word 

    ADD R1, R1, #1                  ; Moves to next word address in wordList 
    ADD R2, R2, #-1                 ; Decrements selected word index counter
    BR  wordIndexLoop               ; Loops until selected word index reaches zero

wordIndexFound
    LDR R0, R1, #0                  ; Loads actual selected word address into R0

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R2, R6, #0                  ; Loads R2 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R2)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET                             

selectedWordIndex .BLKW #1          ; Stores randomized word index between 0 and 29

wordList                            ; Pointers used for each word as the words are each 6 memory address and this seems more intuitive then making a function
    .FILL wordGloop                 ; to navigate the saved STRINGZ themselves
    .FILL wordApple
    .FILL wordChair
    .FILL wordTable
    .FILL wordRiver
    .FILL wordStone
    .FILL wordCloud
    .FILL wordPlant
    .FILL wordBread
    .FILL wordTrain
    .FILL wordHorse
    .FILL wordHouse
    .FILL wordPhone
    .FILL wordLight
    .FILL wordBrush
    .FILL wordClock
    .FILL wordFlame
    .FILL wordSheep
    .FILL wordBeach
    .FILL wordCrown
    .FILL wordSword
    .FILL wordMouse
    .FILL wordWheel
    .FILL wordField
    .FILL wordEarth
    .FILL wordWater
    .FILL wordGrass
    .FILL wordMoney
    .FILL wordPaper
    .FILL wordMusic

wordGloop .STRINGZ "gloop"
wordApple .STRINGZ "apple"
wordChair .STRINGZ "chair"
wordTable .STRINGZ "table"
wordRiver .STRINGZ "river"
wordStone .STRINGZ "stone"
wordCloud .STRINGZ "cloud"
wordPlant .STRINGZ "plant"
wordBread .STRINGZ "bread"
wordTrain .STRINGZ "train"
wordHorse .STRINGZ "horse"
wordHouse .STRINGZ "house"
wordPhone .STRINGZ "phone"
wordLight .STRINGZ "light"
wordBrush .STRINGZ "brush"
wordClock .STRINGZ "clock"
wordFlame .STRINGZ "flame"
wordSheep .STRINGZ "sheep"
wordBeach .STRINGZ "beach"
wordCrown .STRINGZ "crown"
wordSword .STRINGZ "sword"
wordMouse .STRINGZ "mouse"
wordWheel .STRINGZ "wheel"
wordField .STRINGZ "field"
wordEarth .STRINGZ "earth"
wordWater .STRINGZ "water"
wordGrass .STRINGZ "grass"
wordMoney .STRINGZ "money"
wordPaper .STRINGZ "paper"
wordMusic .STRINGZ "music"

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; buildBlankWord
;
; Description: Fills displayWord with five underscores via a loop that uses the word length (5) for counting
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

buildBlankWord

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R2, R6, #0                  ; Saves R2 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R3, R6, #0                  ; Saves R3 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

; Actual subroutine logic

    LD  R1, ptrDisplayWordB         ; Loads address of displayWord (where gameplay word is stored) into R1
    LD  R2, wordLengthB             ; Loads hardcoded word length (5) into R2
    LD  R3, asciiUnderscoreB        ; Loads underscore character (95) into R3

blankLoop
    ADD R2, R2, #0                  ; Checks if blank counter is zero
    BRz doneBlankLoop               ; If zero all blank spaces have been stored appropriately

    STR R3, R1, #0                  ; Stores underscore at current displayWord address
    ADD R1, R1, #1                  ; Moves R1 to next address relative to displayWord
    ADD R2, R2, #-1                 ; Decrements blank counter
    BR  blankLoop                   ; Loops until five underscores/blanks are saved

doneBlankLoop

    LD  R0, ptrDisplayWordB         ; Loads starting address of displayWord into R0 as return value for use for updating throughout game

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R3, R6, #0                  ; Loads R3 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R3)

    LDR R2, R6, #0                  ; Loads R2 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R2)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET

ptrDisplayWordB  .FILL displayWord
wordLengthB      .FILL #5
asciiUnderscoreB .FILL #95

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; checkGuessInWord
;
; Description: Compares currentGuess against each character in selected word. If a character matches, currentGuess(a char) is copied into the matching position in displayWord.
;              Returns 0 in R0 if no match was found and a positive number in R0 if a match was found.
;
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

checkGuessInWord

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R2, R6, #0                  ; Saves R2 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R3, R6, #0                  ; Saves R3 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R4, R6, #0                  ; Saves R4 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R5, R6, #0                  ; Saves R5 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

; Actual subroutine logic

    LD  R1, ptrSelectedWordPtrC     ; Loads address of selectedWordPtr variable into R1
    LDR R1, R1, #0                  ; Loads selected word address into R1 via above pointer
    LD  R2, ptrDisplayWordC         ; Loads displayWord address into R2
    LD  R3, wordLengthC             ; Loads number of letters to check into R3(5)
    AND R5, R5, #0                  ; Clears R5 so it can count the amount of matches

checkLetterLoop
    ADD R3, R3, #0                  ; Checks if all five letters have been checked (starts at 5)
    BRz doneCheckLetter             ; If zero check is complete

    LD  R0, ptrCurrentGuessC        ; Loads address of currentGuess variable into R0 (letter the user pressed)
    LDR R0, R0, #0                  ; Loads currentGuess into R0
    NOT R0, R0                      ; Flips bits in R0 to get -currentGuess - 1
    ADD R0, R0, #1                  ; adds one so R0 = -currentGuess

    LDR R4, R1, #0                  ; Loads current selected word char into R4
    ADD R4, R4, R0                  ; R4 = selected word character - currentGuess
    BRnp noLetterMatch              ; If result is not zero then the characters must be different

    LD  R0, ptrCurrentGuessC        ; Loads address of currentGuess variable into R0
    LDR R0, R0, #0                  ; Loads currentGuess back into R0
    STR R0, R2, #0                  ; Stores currentGuess into matching displayWord position (R2 has ptr to display word)
    ADD R5, R5, #1                  ; Adds 1 to found counter(R5)

noLetterMatch
    ADD R1, R1, #1                  ; Moves selected word pointer to next letter for comparrison
    ADD R2, R2, #1                  ; Moves displayWord pointer to next letter for saving char if applicable
    ADD R3, R3, #-1                 ; Decrements remaining letters counter
    BR  checkLetterLoop             ; Loops until all five letters are checked

doneCheckLetter
    ADD R0, R5, #0                  ; Copies found counter into R0 as return value(upon return code checks if this was zero or not to decide penalty)

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R5, R6, #0                  ; Loads R5 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R5)

    LDR R4, R6, #0                  ; Loads R4 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R4)

    LDR R3, R6, #0                  ; Loads R3 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R3)

    LDR R2, R6, #0                  ; Loads R2 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R2)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET

ptrSelectedWordPtrC .FILL selectedWordPtr
ptrDisplayWordC     .FILL displayWord
ptrCurrentGuessC    .FILL currentGuess
wordLengthC         .FILL #5

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; displayWordComplete
;
; Description: Checks if displayWord still contains underscores bny comparing each char to a negatvie underscore value. Returns 1 in R0 if complete
;              0 if not complete.       
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

displayWordComplete

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R2, R6, #0                  ; Saves R2 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R3, R6, #0                  ; Saves R3 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

; Actual subroutine logic

    LD  R1, ptrDisplayWordD         ; Loads displayWord address into R1
    LD  R2, wordLengthD             ; Loads number of letters to check into R2(5)
    LD  R3, negUnderscoreD          ; Loads negative underscore value for comparison

completeLoop
    ADD R2, R2, #0                  ; Checks if all five letters have been checked(5 on first pass)
    BRz wordIsComplete              ; If zero no underscores were found

    LDR R0, R1, #0                  ; Loads current displayWord character into R0
    ADD R0, R0, R3                  ; R0 = current displayWord character - underscore(R3)
    BRz wordNotComplete             ; If result is zero an underscore was found

    ADD R1, R1, #1                  ; Moves displayWord pointer to next character
    ADD R2, R2, #-1                 ; Decrements letters left to check counter(R2)
    BR  completeLoop                ; Loops until underscore is found or word is complete

wordIsComplete
    AND R0, R0, #0                  ; Clears R0
    ADD R0, R0, #1                  ; Sets R0 to 1 because/meaning displayWord is complete
    BR  doneCompleteCheck           ; Skips not complete return value

wordNotComplete
    AND R0, R0, #0                  ; Sets R0 to 0 because/meaning displayWord is not complete

doneCompleteCheck

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R3, R6, #0                  ; Loads R3 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R3)

    LDR R2, R6, #0                  ; Loads R2 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R2)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET

ptrDisplayWordD .FILL displayWord
wordLengthD     .FILL #5
negUnderscoreD  .FILL #-95

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; printHangmanGraphic
;
; Description: Prints the correct hangman graphic based on strikeCounter. strikeCount 0 prints empty gallows. counter increments to
;              print next full string whihc has the complete next stages hangman image.
;              
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

printHangmanGraphic

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R1, R6, #0                  ; Saves R1 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down again for saving next register
    STR R2, R6, #0                  ; Saves R2 at address of decremented stack pointer(R6)

    ADD R6, R6, #-1                 ; Moves stack pointer(R6) down
    STR R7, R6, #0                  ; Saves R7 at address of decremented stack pointer(R6)

; Actual subroutine logic

    LD  R1, ptrStrikeCountG         ; Loads address of strikeCount into R1
    LDR R2, R1, #0                  ; Loads current strike count into R2

    LD  R1, ptrHangmanStrikeTableG  ; Loads address of hangman graphic table into R1
    ADD R1, R1, R2                  ; Moves to correct graphic pointer based on strike count. saved strike count + starting image table address
    LDR R0, R1, #0                  ; Loads address of selected hangman graphic into R0
    PUTS                            ; Prints selected hangman graphic

    LDR R7, R6, #0                  ; Loads R7 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R7)

    LDR R2, R6, #0                  ; Loads R2 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R2)

    LDR R1, R6, #0                  ; Loads R1 from address of current stack pointer(R6)
    ADD R6, R6, #1                  ; Moves stack pointer(R6) up after restoring register(R1)

    RET

ptrStrikeCountG        .FILL strikeCount
ptrHangmanStrikeTableG .FILL hangmanStrikeTable

;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_
; UI stringz/ hangman graphic/ strike image table and memory
;_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_/^\_

msgTitle         .STRINGZ "\nHangman\n"
msgStart         .STRINGZ "Press any key to start a new word.\n"
msgCurrentWord   .STRINGZ "Current word: "
msgSelectLetter  .STRINGZ "Select the letter by pushing a key on your keyboard: "
msgGoodGuess     .STRINGZ "Good guess.\n"
msgBadGuess      .STRINGZ "Wrong guess.\n"
msgWin           .STRINGZ "You won. The word was: "
msgLose          .STRINGZ "You lost. The word was: "
msgNewLine       .STRINGZ "\n"

hangmanStrikes0 .STRINGZ "\n  +---+\n  |   |\n      |\n      |\n      |\n      |\n=========\n"

hangmanStrikes1 .STRINGZ "\n  +---+\n  |   |\n  O   |\n      |\n      |\n      |\n=========\n"

hangmanStrikes2 .STRINGZ "\n  +---+\n  |   |\n  O   |\n  |   |\n      |\n      |\n=========\n"

hangmanStrikes3 .STRINGZ "\n  +---+\n  |   |\n  O   |\n /|   |\n      |\n      |\n=========\n"

hangmanStrikes4 .STRINGZ "\n  +---+\n  |   |\n  O   |\n /|\\  |\n      |\n      |\n=========\n"

hangmanStrikes5 .STRINGZ "\n  +---+\n  |   |\n  O   |\n /|\\  |\n /    |\n      |\n=========\n"

hangmanStrikes6 .STRINGZ "\n  +---+\n  |   |\n  O   |\n /|\\  |\n / \\  |\n      |\n=========\n"

hangmanStrikeTable
    .FILL hangmanStrikes0
    .FILL hangmanStrikes1
    .FILL hangmanStrikes2
    .FILL hangmanStrikes3
    .FILL hangmanStrikes4
    .FILL hangmanStrikes5
    .FILL hangmanStrikes6

selectedWordPtr .BLKW #1             ; Stores address of selected word
currentGuess    .BLKW #1             ; Stores most recent lowercase guessed character
displayWord     .BLKW #6             ; Stores five guessed correct/blank characters and the null terminator
strikeCount     .BLKW #1             ; Stores number of wrong guesses

    .END