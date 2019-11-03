; Reading a File and transing low into high

INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 500

.data
buffer BYTE BUFFER_SIZE DUP(?)
filename  BYTE "D:\GithubLocalRepo\Asm_MASM_Lab\Exercise1_IO\Debug\Input1.txt",0
fileHandle  DD ?
ErrorMsg BYTE "error",0
ALREADYREAD DD ?
ConsoleOutHandle DD ?
BytesWritten DD ?

.code
main PROC
	PUSH eax	
	INVOKE CreateFile,
		ADDR filename, GENERIC_READ, 
		DO_NOT_SHARE, NULL, 
		OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0	;调用createfile函数以读模式打开文件
	MOV fileHandle, eax							;保留文件句柄
	cmp eax, INVALID_HANDLE_VALUE				;比较文件句柄是否合法
	JZ FILE_ERROR								;若不合法，跳转报错
	INVOKE ReadFile,							;合法读文件
		fileHandle, OFFSET buffer, BUFFER_SIZE,
		ADDR ALREADYREAD, 0
	MOV ecx, ALREADYREAD						;ecx放入字节数
	MOV esi, OFFSET buffer						;esi放入首地址
CHANGE: 
	MOV bl, [esi]								;循环读取buffer
	cmp bl, 60H
	JB WRITEBACK
	sub bl, 20H									;如果是小写就-20H
	MOV [esi], bl								;写回buffer
WRITEBACK:							
	ADD esi, TYPE buffer						;i++
	LOOP CHANGE									;循环结束
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE		;获取控制台指针
    MOV ConsoleOutHandle, eax 
    PUSHAD										;储存存储器值
    INVOKE WriteConsole, ConsoleOutHandle,		;打印buffer
			ADDR buffer, ALREADYREAD, 
			offset BytesWritten, 0
	POPAD
	JMP SUCCESS
FILE_ERROR:
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE 
    MOV ConsoleOutHandle, eax 
    PUSHAD  
    INVOKE WriteConsole, ConsoleOutHandle,		;打印报错信息
			Offset ErrorMsg, SIZEOF ErrorMsg, 
			offset BytesWritten, 0
	POPAD
	POP eax
	INVOKE ExitProcess, 0
SUCCESS:
	POP eax
	INVOKE ExitProcess, 0
main ENDP
END main