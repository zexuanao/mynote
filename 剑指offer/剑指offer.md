# 1: 赋值运算符函数
#c++
```
CMyString& CMyString::operator = (const CMyString &str)
{
    if(this ==&str)
        return *this;
    
    delete [] m_pData;
    m_pData=NULL;
    m_pData=new char[strlen(str.m_pData)+1];
    strcpy(m_pData,str.m_pData);
    
    return* this;
}
```
1. 返回值需要是自身的引用，因为需要考虑到连续赋值
2. 传入的参数需要是常量引用
3. 释放自身已有的内存
4. 判断是否和自身是否是同一个实例

如果内存不足导致new char抛出异常，m_pData将是一个空指针
可以先new再delete
```
CMyString& CMyString::operator =const CMyString & str)
{
    if(this!=&str)
    {
        CMyString strTemp(str);
        
        char* pTemp= strTemp.m_pDtata;
        strTemp.m_pData=m_pData;
        m_pData=pTemp;
    }
    
    return *this;
}
```
# 2: 数组

```
int GetSize(int data[])
{
    return sizeof(data);
}

int _tmain(int argc,_TCHAR* argv[])
{
    int data[]={1,2,3,4,5};
    int size1=sizeof(data1);
    
    int *data2=data1;
    int size2=sizeof(data2);
    
    int size3=GetSize(data1);
    
}
```
c\c++中，当数组作为函数的参数进行传递时，数组就自动退化为同类型的指针
因此data1会输出4（32位系统中指针的大小）
# 3: 二维数组的查找
条件：
    二维数组的一行中左边小于右边
    下面大于上面
    
1   2   8   9
2   4   9   12
4   7   10  13
6   8   11  15

首先选取数组中右上角的数字。如果该数字等于要查找的数字，查找过程结束；如果该数字大于要查找的数字，剔除这个数字所在的列；如果该数字小于要查找的数字，剔除这个数字所在的行。也就是说如果要查找的数字不在数组的右上角，则每一次都在数组的查找范围中剔除一行或者一列，这样每一步都可以缩小查找的范围，直到找到要查找的数字，或者查找范围为空。

既可以是右上，也可以是左下
```
bool Find(int* matrix, int rows, int columns, int number)
{
    bool found = false;
    
    if (matrix != nullptr && rows > 0 && columns > 0) // 使用nullptr代替NULL
    {
        int row = 0;
        int column = columns - 1;
        
        while (row < rows && column >= 0)
        {
            if (matrix[row * columns + column] == number) // 修正为 == 比较
            {
                found = true;
                break;
            }
            else if (matrix[row * columns + column] > number) // 修正为 > 比较
            {
                --column;
            }
            else
            {
                ++row;
            }
        }
    }
    
    return found;
}
```
# 4: 字符串
当几个指针赋值给相同的常量字符串时，它们实际上会指向相同的内存地址。但用常量内存初始化数组，情况却有所不同。
使用字符串数组（a[])来赋值字符串时，都是分别创建一部分内存来保存
但是直接使用指针的化，指向的就是同一块常亮字符串地址


字符串替换
我们可以先遍历一次字符串，这样就能统计出字符串中空格的总数，并可以由此计算出替换之后的字符串的总长度。每替换一个空格，长度增加2，因此替换以后字符串的长度等于原来的长度加上2乘以空格数目。我们还是以前面的字符串"We are happy."为例，"We are happy."这个字符串的长度是14（包括结尾符号'\0'），里面有两个空格，因此替换之后字符串的长度是18。
我们从字符串的后面开始复制和替换。首先准备两个指针，P1和P2。P1指向原始字符串的末尾，而P2指向替换之后的字符串的末尾（如图2.4（a）所示）。接下来我们向前移动指针P1，逐个把它指向的字符复制到P2指向的位置，直到碰到第一个空格为止。此时字符串包含如图2.4（b）所示，灰色背景的区域是做了字符拷贝（移动）的区域。碰到第一个空格之后，把P1向前移动1格，在P2之前插入字符串"%20"。由于"%20"的长度为3，同时也要把P2向前移动3格如图2.4（c）所示。
我们接着向前复制，直到碰到第二个空格（如图2.4（d）所示）。和上一次一样，我们再把P1向前移动1格，并把P2向前移动3格插入"%20"（如图2.4（e）所示）。此时P1和P2指向同一位置，表明所有空格都已经替换完毕。[字符串.png](/api/file/getAttach?fileId=66062ac1dc7b10001300008d)

```
/* length 为字符数组 string 的总容量 */
void ReplaceBlank(char string[], int length) {
    if (string == NULL || length <= 0)
        return;
    
    /* originalLength 为字符串 string 的实际长度 */
    int originalLength = 0;
    int numberOfBlank = 0;
    int i = 0;
    
    while (string[i] != '\0') {
        ++originalLength;
        if (string[i] == ' ')
            ++numberOfBlank;
        ++i;
    }
    
    /* newLength 为把空格替换成'%20'之后的长度 */
    int newLength = originalLength + numberOfBlank * 2;
    if (newLength > length)
        return;
    
    int indexOfOriginal = originalLength;
    int indexOfNew = newLength;
    
    while (indexOfOriginal >= 0 && indexOfOriginal < indexOfNew) {
        if (string[indexOfOriginal] == ' ') {
            string[indexOfNew--] = '0';
            string[indexOfNew--] = '2';
            string[indexOfNew--] = '%';
        } else {
            string[indexOfNew--] = string[indexOfOriginal];
        }
        --indexOfOriginal;
    }
}
```
# 5: 通过前序和中序确定二叉树
由于在中序遍历序列中，有3个数字是左子树结点的值，因此左子树总共有3个左子结点。同样，在前序遍历的序列中，根结点后面的3个数字就是3个左子树结点的值，再后面的所有数字都是右子树结点的值。这样我们就在前序遍历和中序遍历两个序列中，分别找到了左右子树对应的子序列。既然我们已经分别找到了左、右子树的前序遍历序列和中序遍历序列，我们可以用同样的方法分别去构建左右子树。也就是说，接下来的事情可以用递归的方法去完成。

[屏幕截图 2024-03-29 151515.png](/api/file/getAttach?fileId=66066c57dc7b100013000090)
# 6 :数值的整数次方
如果输入的指数exponent为32，我们在函数PowerWithUnsignedExponent的循环中需要做31次乘法。但我们可以换一种思路考虑：我们的目标是求出一个数字的32次方，如果我们已经知道了它的16次方，那么只要在16次方的基础上再平方一次就可以了。而16次方是8次方的平方。这样以此类推，我们求32次方只需要做5次乘法：先求平方，在平方的基础上求4次方，在4次方的基础上求8次方，在8次方的基础上求16次方，最后在16次方的基础上求32次方。
```
double pow(double base,unsigned int exp)
{
    if(exp==0)
        return 1;
    if(exp==1)
        return base;
    double result=pow(base,exp>>1)
    result*= result;
    if(exp&0x1)
        result* =base;
    return result;
}
```
# 7: 在O（1）时间内删除链表节点
普通时候需要在找到目标节点之后还需要之前的节点，把上一个节点的next point指向目标节点的后一个节点
但是可以把目标节点的后一个节点复制到目标节点，并删除下一节点
```
BinaryTreeNode* Construct(int* preorder, int* inorder, int length) {
    if (preorder == NULL || inorder == NULL || length <= 0)
        return NULL;
    return ConstructCore(preorder, preorder + length - 1, inorder, inorder + length - 1);
}

BinaryTreeNode* ConstructCore(int* startPreorder, int* endPreorder, int* startInorder, int* endInorder) {
    // 前序遍历序列的第一个数字是根结点的值
    int rootValue = *startPreorder;
    BinaryTreeNode* root = new BinaryTreeNode();
    root->m_nValue = rootValue;
    root->m_pLeft = root->m_pRight = NULL;

    if (startPreorder == endPreorder) {
        if (startInorder == endInorder && *startPreorder == *startInorder)
            return root;
        else
            throw std::exception("Invalid input.");
    }

    // 在中序遍历中找到根结点的值
    int* rootInorder = startInorder;
    while (rootInorder <= endInorder && *rootInorder != rootValue)
        ++rootInorder;

    if (rootInorder == endInorder && *rootInorder != rootValue)
        throw std::exception("Invalid input.");

    int leftLength = rootInorder - startInorder;
    int* leftPreorderEnd = startPreorder + leftLength;

    if (leftLength > 0) {
        // 构建左子树
        root->m_pLeft = ConstructCore(startPreorder + 1, leftPreorderEnd, startInorder, rootInorder - 1);
    }

    if (leftLength < endPreorder - startPreorder) {
        // 构建右子树
        root->m_pRight = ConstructCore(leftPreorderEnd + 1, endPreorder, rootInorder + 1, endInorder);
    }

    return root;
}
```
# 8: 将数组中所有奇数放在偶数前面
因此我们可以维护两个指针，第一个指针初始化时指向数组的第一个数字，它只向后移动；第二个指针初始化时指向数组的最后一个数字，它只向前移动。在两个指针相遇之前，第一个指针总是位于第二个指针的前面。如果第一个指针指向的数字是偶数，并且第二个指针指向的数字是奇数，我们就交换这两个数字。
```
void swapint(int* pdata ,int length)
{
    if(pdata==NULL||length==0}
        return;
    int* pbegin=pdata;
    int* pend=pdata+length-1;
    while(pbegin<pend)
    {
        while(pbegin<pend&&(pbegin&0x01)==1)
            pbegin++;
        while(pbegin<pend&&(pend&0x01)==0)
            pend++;
        if(pbegin<pend)
        {
            int temp=*pbegin;
            *pbegin=*pend;
            *pend=temp;
        }
    }
}
```
也可以把判断函数单独坐成一个函数指针，方便后面进行拓展

# 9: 找出数组中的倒数第n个数
普通的只需要两个指针，第一个指针向后移动n-1个距离
第二个指针指向开头就可以了
但是需要保证这个数组至少有n个数，即指针都不能指向空指针
而且因为是n-1所以输入的n不能小于1
因为给n设定的是无符号整型数


注： 
●　求链表的中间结点。如果链表中结点总数为奇数，返回中间结点；如果结点总数是偶数，返回中间两个结点的任意一个。为了解决这个问题，我们也可以定义两个指针，同时从链表的头结点出发，一个指针一次走一步，另一个指针一次走两步。当走得快的指针走到链表的末尾时，走得慢的指针正好在链表的中间。
●　判断一个单向链表是否形成了环形结构。和前面的问题一样，定义两个指针，同时从链表的头结点出发，一个指针一次走一步，另一个指针一次走两步。如果走得快的指针追上了走得慢的指针，那么链表就是环形链表；如果走得快的指针走到了链表的末尾（m_pNext指向NULL）都没有追上第一个指针，那么链表就不是环形链表。
举一反三：
当我们用一个指针遍历链表不能解决问题的时候，可以尝试用两个指针来遍历链表。可以让其中一个指针遍历的速度快一些（比如一次在链表上走两步），或者让它先在链表上走若干步。
# 10: 合并两个排序的链表数组
比较两个链表的第一个数据，谁小谁就是头指针，后序谁小，谁就加在头指针的后面
需要考虑的特殊情况是，是否有链表为空链表
# 11: 二叉树的镜像

我们先前序遍历这棵树的每个结点，如果遍历到的结点有子结点，就交换它的两个子结点。当交换完所有非叶子结点的左右子结点之后，就得到了树的镜像。
# 12: 顺时针打印矩阵
将矩阵看成一圈一圈的进行循环的话，那向内一圈就相当于两行两列，所以每向内一圈就将计数器加一，乘2的结果如果小于总行数和总列数
```
void printmatrix(int ** numbers,int columns,int rows)
{
    if(numbers==NULL||columns<=0||rows<=0)
        return;
    int start =0;
    while(columns>start*2&&rows>start*2)
    {
        printincircl(numbers,columnx,rows,start);
        ++start;
    }
}

void PrintMatrixInCircle(int** numbers, int columns, int rows, int start) {
    int endX = columns - 1 - start;
    int endY = rows - 1 - start;

    // 从左到右打印一行
    for (int i = start; i <= endX; ++i) {
        int number = numbers[start][i];
        printNumber(number);
    }

    // 从上到下打印一列
    if (start < endY) {
        for (int i = start + 1; i <= endY; ++i) {
            int number = numbers[i][endX];
            printNumber(number);
        }
    }

    // 从右到左打印一行
    if (start < endX && start < endY) {
        for (int i = endX - 1; i >= start; --i) {
            int number = numbers[endY][i];
            printNumber(number);
        }
    }

    // 从下到上打印一列
    if (start < endX && start < endY - 1) {
        for (int i = endY - 1; i > start; --i) {
            int number = numbers[i][start];
            printNumber(number);
        }
    }
}

```
# 13: 包含min函数的栈
要求：O(1)时间内输出最小数据，能一直保存次小数据，而且不破坏栈本身的结构
先使用数据栈保存，然后创建辅助栈
每次都将最小的数值压入辅助栈，这样的话虽然辅助栈和数据栈一起弹出，但是永远都能输出最小的数值
```
template <typename T>
void StackWithMin<T>::push(const T& value) {
    m_data.push(value);
    if (m_min.empty() || value < m_min.top())
        m_min.push(value);
    else
        m_min.push(m_min.top());
}

template <typename T>
void StackWithMin<T>::pop() {
    assert(!m_data.empty() && !m_min.empty());
    m_data.pop();
    m_min.pop();
}

template <typename T>
const T& StackWithMin<T>::min() const {
    assert(!m_data.empty() && !m_min.empty());
    return m_min.top();
}
```
# 14: 栈的压入、弹出序列
如果下一个弹出的数字刚好是栈顶数字，那么直接弹出。如果下一个弹出的数字不在栈顶，我们把压栈序列中还没有入栈的数字压入辅助栈，直到把下一个需要弹出的数字压入栈顶为止。如果所有的数字都压入栈了仍然没有找到下一个弹出的数字，那么该序列不可能是一个弹出序列。
```
bool IsPopOrder(const int* pPush, const int* pPop, int nLength) {
    bool bPossible = false;

    // 检查输入指针是否有效以及长度是否大于0
    if (pPush != nullptr && pPop != nullptr && nLength > 0) {
        const int* pNextPush = pPush;
        const int* pNextPop = pPop;
        std::stack<int> stackData;

        // 当 pop 序列未遍历完时进行循环
        while (pNextPop - pPop < nLength) {
            // 当栈为空或栈顶元素不等于当前 pop 序列的元素时，将 push 序列入栈
            while (stackData.empty() || stackData.top() != *pNextPop) {
                // 如果 push 序列已经全部入栈，跳出循环
                if (pNextPush - pPush == nLength)
                    break;
                stackData.push(*pNextPush);
                pNextPush++;
            }

            // 如果栈顶元素仍不等于当前 pop 序列的元素，则序列不合法，跳出循环
            if (stackData.top() != *pNextPop)
                break;

            // 栈顶元素等于当前 pop 序列的元素，则出栈并将 pop 序列指针后移
            stackData.pop();
            pNextPop++;
        }

        // 如果栈为空且 pop 序列已全部遍历，则说明是合法序列
        if (stackData.empty() && pNextPop - pPop == nLength)
            bPossible = true;
    }

    return bPossible;
}
```

# 15: 从上到下输出二叉树
因为得到一个节点有两个子节点后，立马将他们输出，所以很容易想到使用队列
注意：队列保存的是指向二叉树的指针，所以可以直接通过队列内容内的，二叉树的指针，找到下一个节点

```
#include <cstdio>
#include <deque>

struct BinaryTreeNode {
    int m_nValue;
    BinaryTreeNode* m_pLeft;
    BinaryTreeNode* m_pRight;
};

void PrintFromTopToBottom(BinaryTreeNode* pTreeRoot) {
    if (!pTreeRoot)
        return;

    std::deque<BinaryTreeNode*> dequeTreeNode;
    dequeTreeNode.push_back(pTreeRoot);

    while (dequeTreeNode.size()) {
        BinaryTreeNode* pNode = dequeTreeNode.front();
        dequeTreeNode.pop_front();

        printf("%d ", pNode->m_nValue);

        if (pNode->m_pLeft)
            dequeTreeNode.push_back(pNode->m_pLeft);

        if (pNode->m_pRight)
            dequeTreeNode.push_back(pNode->m_pRight);
    }
}
```

# 16: 复杂链表的复制
1. 可以创建一个哈希表，分别对应原值和复制值，然后原值有指向信息，那么复制值也指向对应值
2. 直接在每个节点后面复制自己，然后分别对应应该指向的位置，即前一个节点（自己）指向的位置加一，最后将奇偶节点分开即可

# 17: 二叉搜索树与双向链表
把二叉搜索树堪称三部分
根节点，左子树，右子树
每次递归都将根节点的右指针指向右子树最小的节点，左节点指向左子树最大的节点
这样的话，一直递归就可以完成不创建新节点的把二叉搜索树变成双向链表
```
#include<bits/stdc++.h>

// 定义二叉树结点结构
struct BinaryTreeNode {
    int value; // 值
    BinaryTreeNode* m_pLeft; // 左子树指针
    BinaryTreeNode* m_pRight; // 右子树指针
};

// 将二叉搜索树转换为双向链表的函数
BinaryTreeNode* Convert(BinaryTreeNode* pRootOfTree) {
    BinaryTreeNode* pLastNodeInList = NULL;
    // 调用辅助函数进行转换
    ConvertNode(pRootOfTree, &pLastNodeInList);
    // 找到双向链表的头结点
    BinaryTreeNode* pHeadOfList = pLastNodeInList;
    while (pHeadOfList != NULL && pHeadOfList->m_pLeft != NULL)
        pHeadOfList = pHeadOfList->m_pLeft;
    // 返回双向链表的头结点
    return pHeadOfList;
}

// 辅助函数，用于递归转换二叉搜索树为双向链表
void ConvertNode(BinaryTreeNode* pNode, BinaryTreeNode** pLastNodeInList) {
    // 如果结点为空，直接返回
    if (pNode == NULL)
        return;
    BinaryTreeNode* pCurrent = pNode;
    // 递归处理左子树
    if (pCurrent->m_pLeft != NULL)
        ConvertNode(pCurrent->m_pLeft, pLastNodeInList);
    // 将当前结点连接到双向链表中
    pCurrent->m_pLeft = *pLastNodeInList;
    if (*pLastNodeInList != NULL)
        (*pLastNodeInList)->m_pRight = pCurrent;
    // 更新双向链表的尾结点为当前结点
    *pLastNodeInList = pCurrent;
    // 递归处理右子树
    if (pCurrent->m_pRight != NULL)
        ConvertNode(pCurrent->m_pRight, pLastNodeInList);
}

```

# 18: 字符串的排列
首先求所有可能出现在第一个位置的字符，即把第一个字符和后面所有的字符交换。图4.14就是分别把第一个字符a和后面的b、c等字符交换的情形。首先固定第一个字符，求后面所有字符的排列。这个时候我们仍把后面的所有字符分成两部分：后面字符的第一个字符，以及这个字符之后的所有字符。然后把第一个字符逐一和它后面的字符交换
```
#include <stdio.h>

void Permutation(char* pStr);

void PermutationHelper(char* pStr, char* pBegin);

int main() {
    char str[] = "charx";
    Permutation(str);
    return 0;
}

void Permutation(char* pStr) {
    if (pStr == NULL)
        return;
    PermutationHelper(pStr, pStr);
}

void PermutationHelper(char* pStr, char* pBegin) {
    if (*pBegin == '\0')
        printf("%s\n", pStr);
    else {
        for (char* pCh = pBegin; *pCh != '\0'; ++pCh) {
            char temp = *pCh;
            *pCh = *pBegin;
            *pBegin = temp;

            PermutationHelper(pStr, pBegin + 1);

            temp = *pCh;
            *pCh = *pBegin;
            *pBegin = temp;
        }
    }
}
```
# 19: 数组中出现次数超过一半的数字
解法1：
数组中有一个数字出现的次数超过了数组长度的一半。如果把这个数组排序，那么排序之后位于数组中间的数字一定就是那个出现次数超过数组长度一半的数字。也就是说，这个数字就是统计学上的中位数，即长度为n的数组中第n/2大的数字
解法2：
数组中有一个数字出现的次数超过数组长度的一半，也就是说它出现的次数比其他所有数字出现次数的和还要多。因此我们可以考虑在遍历数组的时候保存两个值：一个是数组中的一个数字，一个是次数。当我们遍历到下一个数字的时候，如果下一个数字和我们之前保存的数字相同，则次数加1；如果下一个数字和我们之前保存的数字不同，则次数减1。如果次数为零，我们需要保存下一个数字，并把次数设为1。由于我们要找的数字出现的次数比其他所有数字出现的次数之和还要多，那么要找的数字肯定是最后一次把次数设为1时对应的数字。
# 20: 最小的k个数
解法1：
从“数组中出现次数超过一半的数字”得到了启发，我们同样可以基于Partition函数来解决这个问题。如果基于数组的第k个数字来调整，使得比第k个数字小的所有数字都位于数组的左边，比第k个数字大的所有数字都位于数组的右边。这样调整之后，位于数组中左边的k个数字就是最小的k个数字（这k个数字不一定是排序的）
解法2：
一是在k个整数中找到最大数；二是有可能在这个容器中删除最大数；三是有可能要插入一个新的数字。如果用一个二叉树来实现这个数据容器，那么我们能在O（logk）时间内实现这三步操作。因此对于n个输入数字而言，总的时间效率就是O（nlogk）。
因为自己写最大堆有点困难，所以直接用stl中的红黑树就可以了

# 21: 连续子数组的最大和
解法一：举例分析数组的规律
如果一个子数组和小于0，那么就直接从数组后一个数字开始重新计算
解法二：应用动态规划法
当以第i－1个数字结尾的子数组中所有数字的和小于0时，如果把这个负数与第i个数累加，得到的结果比第i个数字本身还要小，所以这种情况下以第i个数字结尾的子数组就是第i个数字本身（如表5.2的第3步）。如果以第i－1个数字结尾的子数组中所有数字的和大于0，与第i个数字累加就得到以第i个数字结尾的子数组中所有数字的和。
# 22: 两个链表的第一个公共结点
两条链表交汇，会造成两个链表有公共结点
将两条链表压入两个栈，那么就是后入先出，从后向前对比，是否一致相同
第一个不同的就是第一个公共结点前一个结点
# 23: 数字在排序数组中出现的次数
排序数组第一时间要想到二分查找法
如果中间数小于目标，那么一定在后半找
需要找到第一个目标数，和最后一个目标数
这两个使用的函数不一样
找第一个，如果相同，那么向前看是否相等，然后继续二分
找最后一个则是和后面一个相比

# 24: 二叉树的深度
根节点的深度等于左子树和右子树中深度较大的一方加一
那么可以直接使用递归

判断一棵树是不是平衡的
如果使用后序遍历，那么遍历一个结点之前就已经遍历了他的左右子树
只需要遍历的时候记录他的深度，就可以一边遍历一边判断每个节点是不是平衡的
如果不记录深度的话，那么就会重复遍历
# 25: 数组中只出现一次的数字
我们试着把原数组分成两个子数组，使得每个子数组包含一个只出现一次的数字，而其他数字都成对出现两次。如果能够这样拆分成两个数组，我们就可以按照前面的办法分别找出两个只出现一次的数字了。我们还是从头到尾依次异或数组中的每一个数字，那么最终得到的结果就是两个只出现一次的数字的异或结果。因为其他数字都出现了两次，在异或中全部抵消了。由于这两个数字肯定不一样，那么异或的结果肯定不为0，也就是说在这个结果数字的二进制表示中至少就有一位为1。我们在结果数字中找到第一个为1的位的位置，记为第n位。现在我们以第n位是不是1为标准把原数组中的数字分成两个子数组，第一个子数组中每个数字的第n位都是1，而第二个子数组中每个数字的第n位都是0。由于我们分组的标准是数字中的某一位是1还是0，那么出现了两次的数字肯定被分配到同一个子数组。因为两个相同的数字的任意一位都是相同的，我们不可能把两个相同的数字分配到两个子数组中去，于是我们已经把原数组分成了两个子数组，每个子数组都包含一个只出现一次的数字，而其他数字都出现了两次。我们已经知道如何在数组中找出唯一一个只出现一次数字，因此到此为止所有的问题都已经解决了。    
# 26: 翻转单词顺序&左旋转字符串

翻转字符串只需要把所有字符反转之后，再翻转其中的每个单词就可以了

左旋转字符串相当于把目标字符的前后分为两部分，然后把这两部分当做两个单词，像翻转字符串一样反转他们就可以了

# 27: n个骰子的点数
可以把所有骰子分成一个和另外一份，这样的话就是需要计算从1到6的每一种点数和剩下的n－1个骰子来计算点数和。接下来把剩下的n－1个骰子还是分成两堆，第一堆只有一个，第二堆有n－2个
但是使用递归的话会有很多重复的数据计算，一般不使用


因为骰子只有六个面，所以上一次骰的点数和，只有可能是这次骰的点数减1-6，所以和为n的骰子出现的次数应该等于上一次循环中骰子点数和为n－1、n－2、n－3、n－4、n－5与n－6的次数的总和

# 28: 求1+...+n
可以用构造函数来来代替循环
使用数组构造n个实例，在使用静态变量来表示循环n次

也可以使用虚函数
递归无非就是要判断的时候无法使用
那么就用！！表示true和false，让虚函数表来选择使用哪个重载 

如果不能用虚函数的话，函数指针是一样的

