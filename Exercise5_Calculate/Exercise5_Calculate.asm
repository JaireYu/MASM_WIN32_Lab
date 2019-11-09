INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 500

.data
buffer BYTE BUFFER_SIZE DUP(?)
filename  BYTE "D:\GithubLocalRepo\Asm_MASM_Lab\Exercise5_Calculate\Debug\Input5.txt",0
Op BYTE BUFFER_SIZE DUP(?) ;操作符栈
StackBase DD ?
ErrorMsg BYTE "error",0
ConsoleOutHandle DD ?
BytesWritten DD ?

.code
main PROC
	INVOKE CreateFile,
			ADDR filename, GENERIC_READ, 
			DO_NOT_SHARE, NULL, 
			OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0	;调用createfile函数以读模式打开文件
	MOV edx, OFFSET buffer
	MOV ecx, BUFFER_SIZE
	CALL ReadFromFile
	JC File_ERROR
	MOV ecx, eax
	MOV al, 0		
	MOV ah, 0
	MOV bl, 0;读入的byte数移入ecx中
	MOV edi, OFFSET Op
	MOV esi, OFFSET StackBase		;存储op栈的起始位置
	MOV [esi], edi
	MOV esi, OFFSET buffer
	
	.WHILE (ecx > 0)
		MOV bh, BYTE PTR [esi]
		.IF (bh == 2DH)
			.IF (ah == 00H)
				.IF(al == 1 && bl == 1)
					MOV edx, eax
					POP eax
					PUSH ecx
					MOV ecx, -1
					MUL ecx
					POP ecx
					PUSH eax
					MOV eax, edx
				.ENDIF
				MOV edx, OFFSET StackBase
				MOV edx, [edx]
				.IF(edx != edi)
					MOV dl, [edi]
					.IF(dl == 2BH);22
						POP edx
						ADD [esp], edx
						DEC edi
					.ELSEIF(dl == 2DH);30
						POP edx
						SUB [esp], edx
						DEC edi
					.ENDIF
				.ENDIF
				inc edi
				MOV [edi], BYTE PTR 2DH;39
				MOV ah, 1
				MOV bl, 0
				MOV al, 0
			.ELSE 
				MOV bl, 1;45
				MOV ah, 0
				MOV al, 0
			.ENDIF
		.ELSEIF (bh == 2BH)
			.IF (al == 1 && bl == 1)
				MOV edx, eax
				POP eax
				PUSH ecx
				MOV ecx, -1
				MUL ecx
				POP ecx
				PUSH eax
				MOV eax, edx
			.ENDIF
			MOV edx, OFFSET StackBase
			MOV edx, [edx]
			.IF(edx != edi);56
				MOV dl, [edi]
				.IF(dl == 2BH);58
					POP edx
					ADD [esp], edx
					DEC edi
				.ELSEIF(dl == 2DH);66
					POP edx
					SUB [esp], edx
					DEC edi
				.ENDIF
			.ENDIF
			inc edi
			MOV [edi], BYTE PTR 2BH;75
			MOV ah, 1
			MOV bl, 0
			MOV al, 0
		.ELSEIF (bh == 28H)
			INC edi
			MOV [edi], BYTE PTR 28H
			MOV bl, 00H
			MOV ah, 01H
			MOV al, 0
		.ELSEIF (bh == 29H);86
			.IF(al == 1 && bl == 1)
				MOV edx, eax
				POP eax
				PUSH ecx
				MOV ecx, -1
				MUL ecx
				POP ecx
				PUSH eax
				MOV eax, edx
			.ENDIF
			.WHILE 1 LT 2;92
				MOV bh, [edi]
				.IF (bh == 28H);用bh没有问题
					DEC edi
					.BREAK
				.ELSE
					DEC edi
					POP edx
					.IF(bh == 2BH);104
						ADD [esp], edx
					.ELSEIF(bh == 2DH);107
						SUB [esp], edx
					.ENDIF
				.ENDIF
			.ENDW
		.ELSE
			.IF(al == 00H)
				MOVZX edx, BYTE PTR [esi]
				SUB edx, 30H
				PUSH edx
			.ELSE
				MOV edx, eax
				POP eax
				PUSH ecx
				MOV ecx, 10
				MUL ecx
				POP ecx
				ADD al, BYTE PTR [esi]
				SUB eax, 30H
				PUSH eax
				MOV eax, edx
			.ENDIF
			MOV al, 1
			MOV ah, 0
		.ENDIF
		inc esi
		dec ecx
	.ENDW
	MOV edx, OFFSET StackBase
	MOV edx, [edx]
	.WHILE(edi > edx);129
		MOV al, [edi]
		POP ebx
		.IF (al == 2BH);135
			ADD [esp], ebx;
		.ELSE
			SUB [esp], ebx;
		.ENDIF
		DEC edi
	.ENDW
	MOV eax, [esp]
	CALL WriteInt
	INVOKE ExitProcess, 0
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
main ENDP
END main
