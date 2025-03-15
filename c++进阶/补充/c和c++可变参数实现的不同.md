```
#include <stdarg.h>
#include <stdio.h>

void printNumbers(int count, ...) {
    va_list args;
    va_start(args, count);
    for (int i = 0; i < count; ++i) {
        int num = va_arg(args, int);
        printf("%d ", num);
    }
    va_end(args);
}

int main() {
    printNumbers(3, 1, 2, 3); // 输出：1 2 3
    return 0;
}
```
```
#include <iostream>

// 基础情况：当参数包为空时，递归终止
void print() {
    std::cout << std::endl;
}

// 递归情况：逐个打印参数，然后递归调用打印其余参数
template<typename T, typename... Args>
void print(T first, Args... args) {
    std::cout << first << " ";
    print(args...);
}

int main() {
    print(1, 2.5, "Hello", 'a'); // 输出：1 2.5 Hello a
    return 0;
}
```