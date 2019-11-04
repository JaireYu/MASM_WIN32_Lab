;从文件读取[-1024,1024]的少于100个数字，排序之后输出在Console
INCLUDE Irvine32.inc

READ_SIZE = 500
NUM_SIZE = 100

.data 
ReadFileBuffer BYTE READ_SIZE DUP(?)
Filename  BYTE "D:\GithubLocalRepo\Asm_MASM_Lab\Exercise3_Sort\Debug\Input3.txt",0
ReadBytes DD ? 
FileHandle  DD ?
ErrorMsg BYTE "error",0
ConsoleOutHandle DD ?
BytesWritten DD ?
DataBuffer DD NUM_SIZE DUP(?)
SortTotal DD ?
Space DB " ",0


.code
main PROC
	PUSH eax	
	INVOKE CreateFile,
		ADDR filename, GENERIC_READ, 
		DO_NOT_SHARE, NULL, 
		OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0	;调用createfile函数以读模式打开文件
	MOV FileHandle, eax							;保留文件句柄
	cmp eax, INVALID_HANDLE_VALUE				;比较文件句柄是否合法
	JZ FILE_ERROR								;若不合法，跳转报错
	INVOKE ReadFile,							;合法读文件
		fileHandle, OFFSET ReadFileBuffer, READ_SIZE,
		ADDR ReadBytes, 0
	MOV ecx, ReadBytes							;ecx放入字节数
	MOV esi, OFFSET ReadFileBuffer				;esi放入首地址
	JMP NO_ERROR

FILE_ERROR:
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE 
    MOV ConsoleOutHandle, eax 
    PUSHAD  
    INVOKE WriteConsole, ConsoleOutHandle,		;打印报错信息
			Offset ErrorMsg, SIZEOF ErrorMsg, 
			offset BytesWritten, 0
	POPAD
	POP edx
	INVOKE ExitProcess, 0

;读文件没有错误准备加载数字到数组
NO_ERROR:
	MOV ebx, 0									;起始数字是0
	MOV edx, 0									;默认正数
	MOV edi, OFFSET SortTotal
	MOV [edi], ebx								;数字计数置零
	MOV edi, OFFSET DataBuffer					;数组位置
	
;字符转数字进入数组
LOAD_NUM:										;循环置数
	CMP BYTE PTR [esi], 20H
	JNE Judge_Minus								;如果不是空格,去判断符号
	CALL Load_To_Buffer							;否则print到buffer
	JMP END_LOAD
Judge_Minus:
	CMP BYTE PTR [esi], 2DH
	JNE Judge_Plus								;如果不是负号, 去判断正号
	MOV edx, 1									;否则将标志位修改为负
	JMP END_LOAD
Judge_Plus:
	CMP BYTE PTR [esi], 2BH						
	JNE CAL										;如果不是正号当作数字计算
	JMP END_LOAD
CAL:
	CALL Calculate
END_LOAD:
	INC esi
	LOOP LOAD_NUM
	CALL Load_To_Buffer

;BubbleSort
	MOV ecx, OFFSET SortTotal
	MOV ecx, [ecx]
	SUB ecx, 1
	MOV esi, OFFSET DataBuffer
OUTLOOP:										;外层循环记录趟数，11个数就是10趟，前面已经减过1了
	PUSH ecx									;保护外层循环趟数
	PUSH esi
INLOOP:											;相邻两个L>=R, 就交换
	MOV edi, [esi + 4]
	CMP [esi], edi
	JS SKIP										;注意这里应该使用JS(SF)，因为若使用JB为CF标志位，CF针对无符号
	CALL Swap
SKIP:
	ADD esi, TYPE DataBuffer
	LOOP INLOOP
	POP esi										;恢复首位置
	POP ecx										;恢复外循环数
	LOOP OUTLOOP

;print
	MOV esi, OFFSET DataBuffer
	MOV ecx, OFFSET SortTotal
	MOV ecx, [ecx]
PRINT:
	MOV eax, [esi]
	ADD eax, 0
	JNS PRINT_PLUS								;如果是正数，直接打印正数
	PUSH eax									;是负数先打印"-", 再将eax取反得到正数
	MOV al, 2DH
	CALL WriteChar
	POP eax
	NEG eax
PRINT_PLUS:
	CALL WriteDec
	ADD esi, TYPE DataBuffer					;数组下标增1
	MOV al, 20H									;打印空格
	CALL WriteChar
	LOOP PRINT
	INVOKE ExitProcess,0
main ENDP

;将ebx的数据存入buffer，考虑标志位(符号)
Load_To_Buffer proc								
	CMP edx, 0
	JE Load										;如果是正数，就直接LOAD
	NEG ebx										;负数取反
Load:
	MOV [edi], ebx								;ebx数据送入数组 
	ADD edi, TYPE DataBuffer
	MOV ebx, OFFSET SortTotal
	MOV edx, 1 									
	ADD [ebx], edx								;数字计数++
	MOV ebx, 0									;重置起始数字是0
	MOV edx, 0									;默认正数 
	RET
Load_To_Buffer ENDP

;ebx <- ebx*10 + [esi]
Calculate proc
	PUSH edx									;edx存储的是符号位，如果不如栈会被乘积高位覆盖！！！
	MUL ebx
	MOV ebx, eax
	MOVZX eax, BYTE PTR [esi] 
	ADD ebx, eax
	SUB ebx, 30H
	MOV eax, 10
	POP edx
	RET
Calculate ENDP

;swap [esi], [esi + 4]
Swap proc
	MOV eax, [esi]
	MOV ebx, [esi + 4]
	MOV [esi], ebx
	MOV [esi + 4], eax
	RET
SWAP ENDP
END main
