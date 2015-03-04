; Name: Christopher Tam

; Attempts to evaluate a given string with mathematical operations add (+) and multiply (*).

; Main
.orig x3000

				LD R6, STACK			; Initialize the stack

				LEA R0, STRING			; R0 = &str[0]
				ADD R1, R0, 0

	SL_LOOP		LDR R2, R1, 0			; \ R1 = strlen(str)
				BRz SL_END				; |
				ADD R1, R1, 1			; |
				BR SL_LOOP				; |
	SL_END		NOT R2, R0				; |
				ADD R2, R2, 1			; |
				ADD R1, R1, R2			; /

				ADD R6, R6, -2			; \ R0 = eval(str, len)
				STR R0, R6, 0			; |
				STR R1, R6, 1			; |
				LD R2, EVALPTR			; |
				JSRR R2					; |
				LDR R0, R6, 0			; |
				ADD R6, R6, 3			; /

				ST R0, ANS
				HALT

	STACK		.fill xf000
	ANS			.fill -1
	EVALPTR		.fill EVAL
	STRING		.stringz "1*2*3*4*5"
				.blkw 200

	EVAL		STR R7, R6, -2		 	; mem[STACK - 2] = R7 (return address)
				STR R5, R6, -3			; mem[STACK - 3] = R5 (frame pointer)
				STR R0, R6, -4			; mem[STACK - 4] = R0 (local variable)
				STR R1, R6, -5			; mem[STACK - 5] = R1 (local variable)
				STR R2, R6, -6			; mem[STACK - 6] = R2 (local variable)
				STR R3, R6, -7			; mem[STACK - 7] = R3 (local variable)
				STR R4, R6, -8			; mem[STACK - 8] = R4 (local variable)

				ADD R5, R6, -4			; R5 = STACK - 4 (point FP at first local)
				ADD R6, R6, -8			; STACK -= 8 (offset for new stack)

				LDR R0, R5, 4			; R0 = Argument0 = *str

				LDR R1, R5, 5			; R1 = Argument1 = len
				NOT R1, R1				; R1 = -len - 1
				ADD R1, R1, 1			; R1 = -len
				
				AND R2, R2, 0			; R2 = i = 0

	CK_ADD		LD R4, PLUS_NEG			; R4 = PLUS_NEG = -43
	LOOP_ADD	ADD R3, R2, R1			; R3 = i - len
				BRzp CK_MLT				; while (i < len)
				ADD R3, R0, R2			; R3 = str + i
				LDR R3, R3, 0			; R3 = mem[str + i]
				ADD R3, R3, R4			; if (mem[str + i] == '+')
				BRz RC_ADD				; GOTO recursive add and return
				ADD R2, R2, 1			; R2++ = i++
				BR LOOP_ADD				; continue while

	RC_ADD		STR R0, R6, -2			; eval(str...
				STR R2, R6, -1			; ...i)
				ADD R6, R6, -2			; STACK -= 2

				JSR EVAL				; eval(str, i)
				LDR R3, R6, 0			; R3 = left = eval(str, i)
				ADD R6, R6, 3			; STACK += 3 (offset for arguments after return value)

				ADD R0, R0, R2			; R0 = str + i...
				ADD R0, R0, 1			; ...+ 1

				ADD R2, R2, R1			; R2 = i - len
				NOT R2, R2				; R2 = len - i - 1

				STR R0, R6, -2			; eval(str...
				STR R2, R6, -1			; ...i)
				ADD R6, R6, -2			; STACK -= 2

				JSR EVAL				; eval(str, i)
				LDR R2, R6, 0			; R2 = right = eval(str, i)
				ADD R6, R6, 3			; STACK += 3 (offset for arguments after retrieving return value)

				ADD R0, R3, R2			; return left + right
				BR END



	CK_MLT		AND R2, R2, 0			; R2 = i = 0
				LD R4, STAR_NEG			; R4 = STAR_NEG = -42
	LOOP_MLT	ADD R3, R2, R1			; R3 = i - len
				BRzp DEF_RET			; while (i < len)
				ADD R3, R0, R2			; R3 = str + i
				LDR R3, R3, 0			; R3 = mem[str + i]
				ADD R3, R3, R4			; if (mem[str + i] == '*')
				BRz RC_MLT				; GOTO recursive add and return
				ADD R2, R2, 1			; R2++ = i++
				BR LOOP_MLT				; continue while

	RC_MLT		STR R0, R6, -2			; eval(str...
				STR R2, R6, -1			; ...i)
				ADD R6, R6, -2			; STACK -= 2

				JSR EVAL				; eval(str, i)
				LDR R3, R6, 0			; R3 = left = eval(str, i)
				ADD R6, R6, 3			; STACK += 3 (offset for arguments after retrieving return value)

				ADD R0, R0, R2			; R0 = str + i...
				ADD R0, R0, 1			; ...+ 1

				ADD R2, R2, R1			; R2 = i - len
				NOT R2, R2				; R2 = len - i - 1

				STR R0, R6, -2			; eval(str...
				STR R2, R6, -1			; ...i)
				ADD R6, R6, -2			; STACK -= 2

				JSR EVAL				; eval(str, i)
				LDR R2, R6, 0			; R2 = right = eval(str, i)
				ADD R6, R6, 3			; STACK += 3 (offset for arguments after retrieving return value)

				BR MULT					; return left * right

	MULT		AND R0, R0, 0			; R0 = 0 <--> result = 0
	MULT_LOOP	ADD R3, R3, -1			; R3-- <--> y--
				BRn END
				ADD R0, R0, R2			; R0 += R2 <--> result += x
				BR MULT_LOOP

	DEF_RET		LD R4, ZERO_NEG			; R4 = ZERO_NEG = -48
				LDR R0, R0, 0			; R0 = mem[R0] = *str
				ADD R0, R0, R4
				BR END


	END			STR R0, R5, 3			; mem[R5 + 2] = RETURN_VALUE = R0

				LDR R4, R6, 0			; R4 (local variable) = mem[R6 + 0]
				LDR R3, R6, 1			; R3 (local variable) = mem[R6 + 1]
				LDR R2, R6, 2			; R2 (local variable) = mem[R6 + 2]
				LDR R1, R6, 3			; R1 (local variable) = mem[R6 + 3]
				LDR R0, R6, 4			; R0 (local variable) = mem[R6 + 4]
				LDR R5, R6, 5			; R5 (frame pointer) = mem[R6 + 5]
				LDR R7, R6, 6			; R7 (return address) = mem[R6 + 6]
				ADD R6, R6, 7			; Repoint stack pointer at return value
				RET

	PLUS_NEG	.FILL -43
	STAR_NEG	.FILL -42
	ZERO_NEG	.FILL -48

.end
