; 注：此代码是在模拟环境中跑的，如果要连接硬件的话请将地址改为从8255实际首地址开始 (0600H -> 唐都仪器)
; 还有数码管的码型 对应 0到9 第 13行代码， 需要自己结合硬件的码型系列去修改 
; 右什么问题可以提issue
IOYO EQU 0000H
_A  EQU 0000H
_B  EQU 0002H
_C  EQU 0004H
_MODE  EQU 0006H
STACK   SEGMENT
    DB 128 DUP(?)
STACK   ENDS
DATA    SEGMENT
    NUMS    DB  3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH
    SCORE   DW  0, 0
DATA    ENDS
CODE    SEGMENT
    ASSUME  CS: CODE,  SS: STACK, DS: DAA
START:

    MOV AX, STACK
    MOV SS, AX          ;;绑定堆栈
    MOV SP, 128         ;;设置栈顶指针

    MOV AX, DATA
    MOV DS, AX          ;;绑定数据 

    MOV DX, _MODE
    MOV AX, 81H       
    OUT DX, AX 

    MOV AL, 00H       
MAIN_LOOP:
    CALL PRINT_SCORE
    MOV DX, _C
    IN  AL, DX
    SHL AL, 1
    SHL AL, 1
    SHL AL, 1
    SHL AL, 1
    CMP AL, 40H
    JE  LEFT_INIT
    CMP AL, 10H
    JE  RIGHT_INIT
    JMP MAIN_LOOP
LEFT_INIT:
    MOV AL, 01H
    MOV CX, 01H
    JMP RUN_LEFT
RIGHT_INIT:
    MOV AL, 80H
    MOV CX, 80H
    JMP RUN_RIGHT
RUN_LEFT:
    MOV DX, _A
    OUT DX, AL
    CALL DELAY
    ROL AL, 1
    JMP RUN_LEFT
RUN_RIGHT:
    MOV DX, _A
    OUT DX, AL
    CALL DELAY
    ROR AL, 1
    JMP Run_RIGHT
DELAY:
    MOV BX, 1111H
    CMP AL, 80H
    JE  SELECT_RIGHT
    CMP AL, 01H
    JE  SELECT_LEFT
D_L:
    CALL PRINT_SCORE
    DEC BX
    JNZ D_L
    JMP D_END
SELECT_RIGHT:
   
    CMP CX, 01H
    JE  DL_LEFT
    JMP D_L
SELECT_LEFT:
    CMP CX, 80H
    JE  DL_RIGHT
    JMP D_L
DL_LEFT:
    CALL PRINT_SCORE
    PUSH AX
    MOV DX, _C
    IN  Al, DX

    SHL AL, 1
    SHL AL, 1
    SHL AL, 1
    SHL AL, 1

    CMP AX, 20H
    JE  RIGHT_INIT
    POP AX

    
    DEC BX
    JNZ DL_LEFT
    CALL RIGHT_WIN

    JMP D_END_1
DL_RIGHT:
    CALL PRINT_SCORE
    PUSH AX
    MOV DX, _C
    IN  AX, DX

    SHL AL, 1
    SHL AL, 1
    SHL AL, 1
    SHL AL, 1

    CMP AL, 80H
    JE  LEFT_INIT
    POP AX

    DEC BX
    JNZ DL_RIGHT
    CALL LEFT_WIN

    JMP D_END_1
D_END:
    RET
D_END_1:
    JMP DELAY_END
    RET
DELAY_END:
    DEC BX
    JNZ DELAY_END
    MOV DX, _A
    MOV AL, 0FFH
    OUT DX, AL
    MOV BX, 0FFFFH
D_S:
    DEC BX
    JNZ D_S
    MOV AL, 00H
    OUT DX, AL
    JMP MAIN_LOOP
PRINT_SCORE:
    PUSH AX

    MOV DX, _C
    MOV AL, 00100000B
    OUT DX, AL

    PUSH BX
    MOV DX, _B
    MOV BX, SCORE[0]
    MOV AX, [BX]        ;;拿分数
    OUT DX, AL
   
   
    MOV AL, 00H
    OUT DX, AL
    CALL PRINT_DELAY    

    MOV DX, _C
    MOV AL, 00010000B
    OUT DX, AL

    MOV DX, _B
    MOV BX, SCORE[2]
    MOV AL, [BX]        ;;拿分数
    OUT DX, AL
    
    MOV AL, 00H
    OUT DX, AL
    
    POP BX
    POP AX

    RET
PRINT_DELAY:
    PUSH CX
    MOV  CX, 10H
MY_DELAY:
    LOOP MY_DELAY
    POP CX
    RET
LEFT_WIN:
    ADD WORD PTR SCORE[0], 1
    CMP SCORE[0], 0AH
    JE SCORE_RE_INIT 
    RET
RIGHT_WIN:
    ADD WORD PTR SCORE[2], 1
    CMP SCORE[2], 0AH
    JE SCORE_RE_INIT
    RET
SCORE_RE_INIT:
    MOV SCORE[0], 0
    MOV SCORE[2], 0
    JMP D_END_1
CODE ENDS
    END START
    