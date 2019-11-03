; Read From the Console         (ReadConsole.asm)

; Read a line of input from standard input.

INCLUDE Irvine32.inc

BUFFER_SIZE = 300

.data
ReadBuffer DB 3 DUP(?)
Buffer DB BUFFER_SIZE DUP(?)
stdInHandle DD ?
bytesRead  DD ?
ConsoleOutHandle DD ?
BytesWritten DD ?
Table DB " ",0

.code
main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	MOV	stdInHandle,eax
	INVOKE ReadConsole, stdInHandle, ADDR ReadBuffer,
			01H, ADDR bytesRead, 0
	MOV	ecx, OFFSET ReadBuffer						;取数字填充ecx
	MOVZX ecx, BYTE PTR [ecx]						;一定要注意这里，只有MOVZX才能保证覆盖
	SUB ecx, 30H									;外层循环计数
	MOV eax, ecx									
	MUL ecx											
	MOV ecx, eax									;取平方
	MOV esi, OFFSET Buffer							;偏移地址
	MOV ebx, 01H									;数字
STORE:												;循环放入n^2的buffer
	MOV [esi], ebx
	ADD esi, TYPE Buffer
	INC ebx
	LOOP STORE

	MOV	ecx, OFFSET ReadBuffer						;取数字填充ecx
	MOVZX ecx, BYTE PTR [ecx]
	SUB ecx, 30H
	MOV ebx, ecx									;使用bx暂存cx，方便之后赋值
	MOV esi, OFFSET Buffer							;esi是buffer的地址
PRINT_COLUMN:
	MOV edx, ecx									;edx现在是外层循环数
	PUSH ecx										;保护外层ecx
	MOV ecx, ebx									;对内层循环数赋值6
PRINT_ROW:
	CMP ecx, edx
	JB SKIP											;若是不在下三角就不打印
	MOVZX eax, BYTE PTR [esi]
	call WriteDec
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE			;打印空格
    MOV ConsoleOutHandle, eax 
    PUSHAD										
    INVOKE WriteConsole, ConsoleOutHandle,		
			ADDR Table, 1, 
			offset BytesWritten, 0
	POPAD
SKIP:
	ADD esi, TYPE Buffer							;esi自增
	LOOP PRINT_ROW
	CALL CRLF										;打印回车
	POP ecx											;保存的外层循环数cx出栈
	LOOP PRINT_COLUMN
	INVOKE ExitProcess, 0
main ENDP
END main