# MASM_WIN32_Lab
------------------Codes for mcps(微机原理) course lab---------------------
### LAB1
lab1是关于I/O的文件读取，输出在控制台
### LAB2
注意以字节读取进入32bit寄存器时，注意使用0扩展--MOVZX
使用了Irvinelib的WriteDec函数，和CRLF函数，不知道是不是符合要求
### LAB3
* 注意MUL指令，会改变EDX的值，要入栈保存
* CMP就是比较补码大小，原理是左右相减，程序员根据JE/JS/....来定义有符号还是无符号
### LAB4
* 注意双层嵌套的循环内层ecx到达0时，外层首先会自减ecx为fffffffe，意味着不会停止循环
* 注意大数运算的处理
