TITLE Maze Game
INCLUDE Irvine32.inc   

.data
 ;Wall = 35, Exit = 69, Player = 42, Prize = 80, Blank = 00
 Maze DWORD  35,35,35,35,35,35,35,35,35,35,35,35,69,35,35,35,35,35,35,35
 rowSize = ($ - Maze)
 DWORD      35,35,35,35,35,35,35,35,00,00,00,00,00,35,35,35,35,00,80,35
 DWORD      35,35,35,35,35,35,35,35,00,35,35,35,35,35,35,35,35,00,35,35
 DWORD      35,35,00,00,00,00,00,00,00,35,00,35,35,35,35,35,35,00,35,35
 DWORD      35,35,00,35,35,35,35,35,35,35,00,35,35,35,35,35,35,00,35,35
 DWORD      35,35,00,35,35,35,00,35,35,35,00,00,00,00,00,00,35,00,35,35
 DWORD      35,35,00,00,00,00,00,35,35,35,00,35,35,35,35,00,00,00,35,35
 DWORD      35,35,35,35,35,35,00,00,00,00,00,35,80,00,35,35,35,00,00,35
 DWORD      35,35,35,35,35,35,35,35,35,35,35,35,35,00,35,35,35,35,00,35
 DWORD      35,80,00,00,00,00,00,00,00,35,35,35,35,00,35,35,35,00,00,35
 DWORD      35,35,35,35,35,00,35,35,00,00,00,00,00,00,35,35,35,00,35,35
 DWORD      35,35,35,00,00,00,35,35,00,35,35,35,35,00,35,35,35,00,00,35
 DWORD      35,35,35,00,35,35,35,35,00,35,35,35,35,00,35,35,35,35,00,35
 DWORD      35,00,00,00,35,35,35,35,00,00,35,35,35,00,00,00,00,35,00,35
 DWORD      35,00,35,35,00,00,00,35,35,35,35,35,35,35,35,35,00,35,00,35
 DWORD      35,00,35,35,00,35,00,00,35,35,35,35,35,80,35,35,00,35,00,35
 DWORD      35,00,00,35,00,35,35,00,35,35,35,35,35,00,35,35,00,00,00,35
 DWORD      35,35,00,00,00,35,35,00,00,00,00,00,00,00,35,35,35,00,35,35
 DWORD      35,35,35,35,80,35,35,35,35,35,42,35,35,35,35,35,35,80,35,35
 DWORD      35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35
   
 timer DWORD 100
 score DWORD 100
 playerPosition DWORD 1480
 UPDOWN DWORD 80
 LEFTRIGHT DWORD 4
 messageDirections BYTE "Use the arrow keys to move", 0dh, 0ah, 0
 messageTime BYTE "Time Past", 0dh, 0ah, 0
 messageScore BYTE "Your Score is ", 0dh, 0ah, 0
 startTime DWORD ?
 divisor DWORD ?
 timeTaken DWORD ?
 difference DWORD ?
 scoreStart DWORD ?
 prizeScore DWORD 0
 
.code 
start PROC
    mov edx, 0      ;Register to end game
    INVOKE GetTickCount
    mov startTime, eax
GameLoop:
    cmp edx, 99     ;End game value equals 99
    je EndGame
    call TimerScore ; 依照時間往前走，分數會慢慢變少->分數的計數器
    call ReadKey	; 讀取輸入
    jz GameLoop
    cmp ah, 72      ;Up arrow key
    je Up
    cmp ah, 80      ;Down arrow key
    je Down
    cmp ah, 75      ;Left arrow key
    je Left
    cmp ah, 77      ;Right arrow key
    je Right
Up:
    call UpMove
    call Next
Down:
    call DownMove
    call Next
Left:
    call LeftMove
    call Next
Right:
    call RightMove
    call Next
Next:
    jmp GameLoop
EndGame:
    call TimerCount
    call Crlf
    call WaitMsg
    exit   
start ENDP
;=========================================================================
TimerScore PROC
    call TimerCount
    mov scoreStart, 99 		;預設分數99分
    mov score, eax
    mov ebx, ScoreStart
    mov ecx, timeTaken    	;get incrementing time(TimerCount PROC)
    sub ebx, ecx			;ScoreStart - timeTaken
    mov edx, prizeScore
    add edx, score			;加分的機制
    mov score, ebx
    add ebx, prizeScore
    mov score, ebx
    call Draw
    mov edx,OFFSET MessageScore
    call WriteString        ;Call Write String procdure
    mov eax, score
    call WriteInt
    call Crlf
    ret
TimerScore ENDP
;=========================================================================
UpMove PROC
;向上走，並判斷遇到的是路徑、牆壁、獎勵"P"或者是出口"E"
    mov esi, OFFSET Maze
    add esi, playerPosition
    sub esi, UPDOWN     ;Move up 
    mov eax, [esi]
    cmp eax, 00         ;Open Spot
    je ValidUp
    cmp eax, 35         ;Wall
    je Wall
    cmp eax, 80         ;Prize
    je PrizeJump
    cmp eax, 88         ;Exit
    je ExitGame
ValidUp: ;路徑->有效的上移
    mov eax, playerPosition       ;Move the indirect value of ebx postion 1 into eax
    mov eax, 42         		  ;Move the player charater into eax
    mov [esi], eax 		          ;Move the character into the 2D array
    add esi, UPDOWN               ;Add the constant number 80 to the 2D array
    mov eax, 00                   ;Move the charater into eax
    mov [esi], eax                ;Move the character into the 2D array
    mov eax, playerPosition       ;Move the player position into eax
    sub eax, UPDOWN               ;subtract 80 from the player position
    mov playerPosition, eax       ;Save the new player position
    jmp MoveDone
PrizeJump: ;獎勵->有效的上移+增加獎勵分數
    mov eax, playerPosition       ;Move the indirect value of ebx postion 1 into eax
    mov eax, 42                   ;Move the player charater into eax
    mov [esi], eax                ;Move the character into the 2D array
    add esi, UPDOWN               ;Add the constant number 80 to the 2D array
    mov eax, 00                   ;Move the charater into eax
    mov [esi], eax                ;Move the character into the 2D array
    mov eax, playerPosition       ;Move the player position into eax
    sub eax, UPDOWN               ;Subtract 80 from the player position
    mov playerPosition, eax       ;Save the new player position
    add prizeScore, 25            ;Add 25 to the score
    jmp MoveDone                  ;Move to done
Wall: ;遇到牆壁，無效的移動，直接進MoveDone->return
    jmp MoveDone
ExitGame: ;遇到"E"，edx值等於99，離開遊戲
    mov edx, 99
    ;exit game
MoveDone:
    ret
UpMove ENDP
;=========================================================================
DownMove PROC
    mov esi, OFFSET Maze
    add esi, playerPosition
    add esi, UPDOWN     ;Move up 
    mov eax, [esi]
    cmp eax, 00         ;Open Spot
    je ValidDown
    cmp eax, 35         ;Wall
    je Wall
    cmp eax, 80         ;Prize
    je PrizeJump
    cmp eax, 88         ;Exit
    je ExitGame
ValidDown:
    mov eax, playerPosition       ;Move the indirect value of ebx postion 1 into eax
    mov eax, 42
    mov [esi], eax
    sub esi, UPDOWN         
    mov eax, 00
    mov [esi], eax
    mov eax, playerPosition
    add eax, UPDOWN
    mov PlayerPosition, eax
    jmp MoveDone
PrizeJump:
    mov eax, playerPosition       ;Move the indirect value of ebx postion 1 into eax
    mov eax, 42       			  ;Move the player charater into eax
    mov [esi], eax    		      ;Move the character into the 2D array
    sub esi, UPDOWN         	  ;Add the constant number 80 to the 2D array
    mov eax, 00         		  ;Move the charater into eax
    mov [esi], eax         		  ;Move the character into the 2D array
    mov eax, playerPosition       ;Move the player position into eax
    add eax, UPDOWN         	  ;Subtract 80 from the player position
    mov playerPosition, eax       ;Save the new player position
    mov ebx, prizeScore
    add prizeScore, 25         	  ;Add 25 to the score
    jmp MoveDone         		  ;Move to done
Wall:
    jmp MoveDone
ExitGame:
    mov edx, 99
MoveDone:
    ret
DownMove ENDP
;========================================================================= 
LeftMove PROC 
	mov esi, OFFSET Maze 
	add esi, playerPosition 
	sub esi, LEFTRIGHT ;Move Left 
	mov eax, [esi] 
	cmp eax, 00 ;Open Spot 
	je ValidLeft 
	cmp eax, 35 ;Wall 
	je Wall 
	cmp eax, 80 ;Prize 
	je PrizeJump 
	cmp eax, 88 ;Exit 
	je ExitGame 
ValidLeft: 
	mov eax, playerPosition ;Move the indirect value of ebx postion 1 into eax 
	mov eax, 42 
	mov [esi], eax 
	add esi, LEFTRIGHT 
	mov eax, 00 
	mov [esi], eax 
	mov eax, playerPosition 
	sub eax, LEFTRIGHT 
	mov PlayerPosition, eax 
	jmp MoveDone 
PrizeJump: 
	mov eax, playerPosition ;Move the indirect value of ebx postion 1 into eax 
	mov eax, 42 ;Move the player charater into eax 
	mov [esi], eax ;Move the character into the 2D array 
	add esi, LEFTRIGHT ;Add the constant number 80 to the 2D array 
	mov eax, 00 ;Move the charater into eax 
	mov [esi], eax ;Move the character into the 2D array 
	mov eax, playerPosition ;Move the player position into eax 
	sub eax, LEFTRIGHT ;Subtract 80 from the player position 
	mov playerPosition, eax ;Save the new player position 
	mov ebx, prizeScore 
	add prizeScore, 25 ;Add 25 to the score 
	jmp MoveDone ;Move to done 
Wall: 
	jmp MoveDone 
ExitGame: 
	mov edx, 99 
	MoveDone: 
	ret
LeftMove ENDP 
;========================================================================= 
RightMove PROC 
	mov esi, OFFSET Maze 
	add esi, playerPosition 
	add esi, LEFTRIGHT ;Move Left 
	mov eax, [esi] 
	cmp eax, 00 ;Open Spot 
	je ValidRight 
	cmp eax, 35 ;Wall 
	je Wall 
	cmp eax, 80 ;Prize 
	je PrizeJump 
	cmp eax, 88 ;Exit 
	je ExitGame 
ValidRight: 
	mov eax, playerPosition ;Move the indirect value of ebx postion 1 into eax 
	mov eax, 42 
	mov [esi], eax 
	sub esi, LEFTRIGHT 
	mov eax, 00 
	mov [esi], eax 
	mov eax, playerPosition 
	add eax, LEFTRIGHT 
	mov playerPosition, eax 
	jmp MoveDone 
PrizeJump: 
	mov eax, playerPosition ;Move the indirect value of ebx postion 1 into eax 
	mov eax, 42 ;Move the player charater into eax 
	mov [esi], eax ;Move the character into the 2D array 
	sub esi, LEFTRIGHT ;Add the constant number 80 to the 2D array 
	mov eax, 00 ;Move the charater into eax 
	mov [esi], eax ;Move the character into the 2D array 
	mov eax, playerPosition ;Move the player position into eax 
	add eax, LEFTRIGHT ;Subtract 80 from the player position 
	mov playerPosition, eax ;Save the new player position 
	mov ebx, prizeScore ;Move the score to the register 
	add prizeScore, 25 ;Add 25 to the score 
	jmp MoveDone ;Move to done 
Wall: 
	jmp MoveDone 
ExitGame: 
	mov edx, 99 
MoveDone: 
	ret
RightMove ENDP 
;========================================================================= 
Draw PROC  ;畫迷宮的function
	mov dh, 0 ;Set maze position X 
	mov dl, 0 ;Set maze position Y 
	call Gotoxy ;Call Go to X Y 
	mov ebx, OFFSET Maze ;Move the maze 2D array into ebx 
	mov ecx, 0 ;intialize the counter
PrintLoop: 
	mov eax, [ebx] ;Move the indirect value of ebx postion 1 into eax 
	add ebx, 4 ;Move to the next offset position 
	inc ecx ;Increment the counter 
	call WriteChar ;Write Character 
	cmp ecx, 20 ;Compare for end of row for each 20 positions (因為地圖的每一行都有20個值，印完就跳下一行)
	je NextLine 
	cmp ecx, 40 
	je NextLine 
	cmp ecx, 60 
	je NextLine 
	cmp ecx, 80 
	je NextLine 
	cmp ecx, 100 
	je NextLine 
	cmp ecx, 120 
	je NextLine 
	cmp ecx, 140 
	je NextLine 
	cmp ecx, 160 
	je NextLine 
	cmp ecx, 180 
	je NextLine 
	cmp ecx, 200 
	je NextLine 
	cmp ecx, 220 
	je NextLine 
	cmp ecx, 240 
	je NextLine 
	cmp ecx, 260 
	je NextLine 
	cmp ecx, 280 
	je NextLine 
	cmp ecx, 300 
	je NextLine 
	cmp ecx, 320 
	je NextLine 
	cmp ecx, 340 
	je NextLine 
	cmp ecx, 360 
	je NextLine 
	cmp ecx, 380 
	je NextLine 
	cmp ecx, 400 
	jne PrintLoop 
	jmp Print
NextLine: 
	call Crlf 
	jmp PrintLoop 
Print: 
	call Crlf
	mov edx,OFFSET MessageDirections 
	call WriteString
	ret
Draw ENDP
;========================================================================= 
TimerCount PROC 
	INVOKE GetTickCount 
	sub eax, startTime
	mov edx, 0
	mov ebx, 1000 ;毫秒除以1000=1秒
	div ebx
	mov timeTaken, eax
	mov edx, OFFSET messageTime 
	call WriteString
	call WriteInt ;Call Write String procdure
	ret
TimerCount ENDP 
;=========================================================================
END start