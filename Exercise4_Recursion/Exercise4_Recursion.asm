;递归求阶乘 数字存储与大数乘法相同，即以BCD码的形式存储在外部数组

INCLUDE Irvine32.inc

.data
Buffer DD 40 DUP(0)


.code
main PROC
	MOV esi, OFFSET Buffer
	ADD esi, 39 * TYPE Buffer
	MOV edi, [esi]
	MOV edi, 1						
	MOV [esi], edi			;对存储数组初始化, 
	CALL ReadInt			;读入数字
	CALL Recursion			;调用递归函数			
	MOV esi, OFFSET Buffer	;获得数组起始位置
	MOV ecx, 40				;循环40次
PRINT:
	MOV eax, [esi]
	CMP eax, 00H
	JZ SKIP					;是0空转
PRINT_NUM:
	MOV eax, [esi]			;不是0陷入打印循环
	ADD esi, TYPE Buffer	;i++
	CALL WriteDec
	LOOP PRINT_NUM
	INVOKE ExitProcess, 0	;注意这里必须退出程序，因为如果不退出的话就会造成ecx=0，执行到外层会自减1导致ecx=fffffffe
SKIP:
	ADD esi, TYPE Buffer	;i++
	LOOP PRINT
	INVOKE ExitProcess, 0
	main ENDP

Recursion PROC
	PUSH eax				;eax入栈
	SUB eax, 1				;eax-1
	CMP eax, 0				
	JZ END_RECURE			;若eax = 0,不入栈开始出栈计算
	CALL Recursion 
END_RECURE:
	POP eax					;eax出栈
	MOV ecx, 40  
	MOV esi, OFFSET Buffer
	ADD esi, 39 * TYPE Buffer
MULTI:						;每次两个循环使得eax*存储数组
	PUSH ecx				;MULTI: 每一位分别乘eax
	PUSH eax
	MOV ecx, [esi]
	MUL ecx
	MOV [esi], eax
	SUB esi, TYPE Buffer
	POP eax
	POP ecx
	LOOP MULTI
	MOV ecx, 39  
	MOV esi, OFFSET Buffer
	ADD esi, 39 * TYPE Buffer
DIVSION:					;每一位mod10取余，并处理进位
	MOV eax, [esi]
	MOV edx, 0
	MOV ebx, 0AH
	DIV ebx
	MOV [esi], edx
	SUB esi, TYPE Buffer
	ADD [esi], eax
	LOOP DIVSION
	RET
	Recursion ENDP

END main
