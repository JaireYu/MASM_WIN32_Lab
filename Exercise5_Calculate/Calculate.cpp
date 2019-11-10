#include<iostream>
#include<stack>
#include<string>
using namespace std;
int main() {
	string expr("24+(-9+(-29+(68+69))+8-2+(36+-69)");
	stack<int> num;
	stack<char> op;
	int al = 0;   //al标注前一项是不是数字, 更新时指示当前项是不是数字
	int ah = 1;      //ah标注当前字符是负号：1还是减号：0， 更新时指示下一项应该使负号还是减号
	int bl = 0;   //bl当前处理的数字是负数，更新时指示之后的数字是不是负数
	for (int i = 0; i != expr.size(); i++) {
		if (expr[i] == '-') {
			if (ah == 0) {     //当前的‘-’是减号，如果前面是数字对其取反
				if (al == 1 && bl == 1) {	//如果前面是数字且符号位是1，对其取负数
					int temp = num.top();
					num.pop();
					num.push(-1 * temp);
				}
				if (op.size() != 0) {	//如果符号栈中有其他字符，对其弹栈计算
					char OP = op.top();
					if (OP == '+') {
						int t1 = num.top();
						num.pop();
						int t2 = num.top();
						num.pop();
						num.push(t1 + t2);
						op.pop();
					}
					else if (OP == '-') {
						int t1 = num.top();
						num.pop();
						int t2 = num.top();
						num.pop();
						num.push(t2 - t1);
						op.pop();
					}
				}
				op.push('-');			//符号入栈
				ah = 1;
				bl = 0;
				al = 0;
			}
			else {              //当前的‘-’负号，不用理会，只要将相应的标志位更新即可
				bl = 1;
				ah = 0;
				al = 0;
			}
		}
		else if (expr[i] == '+') {
			if (al == 1 && bl == 1) { //如果前面是num，且是负数
				int temp = num.top();
				num.pop();
				num.push(-1 * temp);
			}
			if (op.size() != 0) {	//弹栈计算
				char OP = op.top();
				if (OP == '+') {
					int t1 = num.top();
					num.pop();
					int t2 = num.top();
					num.pop();
					num.push(t1 + t2);
					op.pop();
				}
				else if (OP == '-') {
					int t1 = num.top();
					num.pop();
					int t2 = num.top();
					num.pop();
					num.push(t2 - t1);
					op.pop();
				}
			}
			op.push('+');
			ah = 1;
			bl = 0;   //正数
			al = 0;   //当前项不是数字
		}
		else if (expr[i] == '(') {		//入栈更新标志位
			op.push('(');
			bl = 0;
			ah = 1;
			al = 0;
		}
		else if (expr[i] == ')') {
			if (al == 1 && bl == 1) { //如果前面是num，且是负数
				int temp = num.top();
				num.pop();
				num.push(-1 * temp);
			}
			while (1) {					//弹栈计算直至“（”
				char OP = op.top();
				if (OP == '(') {
					op.pop();
					break;
				}
				else {
					op.pop();
					int t1 = num.top();
					num.pop();
					int t2 = num.top();
					num.pop();
					if (OP == '+') {
						num.push(t1 + t2);
					}
					else {
						num.push(t2 - t1);
					}
				}

			}
		}
		else {								//是数字，入栈，如果原来栈顶是数字就合并
			if (al == 0) {
				num.push(expr[i] - 48);
			}
			else {
				int temp = num.top();
				num.pop();
				num.push(temp * 10 + expr[i] - 48);
			}
			al = 1;
			ah = 0;
		}
	}
	int n = op.size();			//对剩余字符出栈计算
	while (n) {
		char OP = op.top();
		op.pop();
		int t1 = num.top();
		num.pop();
		int t2 = num.top();
		num.pop();
		if (OP == '+') {
			num.push(t1 + t2);
		}
		else {
			num.push(t2 - t1);
		}
		n--;
	}
	cout << num.top() << endl;
	system("pause");
}