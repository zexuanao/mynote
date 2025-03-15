# 认识headers、版本、资源
## 体系结构与内核分析
> 所谓泛型编程，就是使用template为主要工具来编写程序。而STL标准库就是最成功的泛型编程的例子

### 目标：
1. 使用c++标准库
2. 认识c++标准库
3. 良好使用c++标准库
4. 扩充c++标准库
***
Standard Template Library
STL 标准模板库
标准库就是SL

* c++标准库的header files不带副档名
* 新式C header files不带副档名.h，在前面加上c
* 当然旧式C header files还是可以使用的
* 新的headers内的组件都封装在namespzce"std"
->using namespace std;or  using std::cout;
*旧式headers内的组件不封装于namespace "std"
***
### 重要网页
1. CPlusPlus.com
2. CppReference.com
3. gcc.gnu.org
# STL体系结构基础介绍
## STL六大部件
1. 容器（数据结构）
2. 分配器（作用于容器）
3. 算法
4. 迭代器（泛化指针）
5. 适配器（对容器，仿函数，迭代器进行转换）
6. 仿函数
一个程序是由数据结构（容器）和算法组成 
oop中讲究的是所有东西都在一个class，STL和oop是不一样的思想
***
示例：

```cpp
#include<iostream>
#include<vector>
#include<algorithm>
#include<functional>

using namespace std;

int main()
{
    int ia[6]={27,210,12,47,109,83};
    vector<int,allocator<int>>vi(ia,ia+6);
    //vector是容器,aalocator是分配器

    cout<< count_if(vi.begin(),vi.end(),not1(bind2nd(less<int>(),40)));
    //cout_if是算法,not1和bind2nd都是函数适配器,less是仿函数
    //not1表示否定,bind2nd表示绑定第二参数
    //not1(bind2nd(less<int>(),40))是一个条件式,这是cout_if需要的参数
    return 0;
}
```
标准库规定，所有的容器都是“前闭后开”区间——即begin指向开头，end指向容器最后一部分的后一个地址

# 容器之分类与各种分类
## 容器——结构与分类
### Sequence Containers
1. Array-数组
2. Vector-向量，自动扩充
3. Deque-双向队列
4. List-双向链表
5. Forward-List-单向链表
### Associative Containers
1. Set/Multiset-使用红黑树实现的二分树
2. Map/Multimap-key-value对应的item二分树
### Unordered Containers(不定序)
1. Unordered Set/Multiset
2. Unordered Map/Multimap

## 使用array
array.size  数组大小
array.front 第一个数组的内容
array.back  最后一个数组的内容
array.data  数组的地址
## 使用qsort
需要的参数：

1. 数据地址
2. 数据数量
3. 每个数据的大小
4. 比较大小的程序
## 使用bsearch（二分查找）
1. key - 指向要查找的元素的指针 
2. ptr - 指向要检验的数组的指针 
3. count - 数组的元素数目 
4. size - 数组每个元素的字节数 
5. comp - 比较函数。若首个参数小于第二个，则返回负整数值，若首个参数大于第二个，则返回正整数值，若两参数等价，则返回零。 将 key 传给首个参数，数组中的元素传给第二个。

> qsort和bsearch都是放在cstdlib中
 
 示例：
```cpp
namespace np_array
{
    void test_array()
    {
        srand(time(NULL));
        cout<<"\ntest_array().........\n";
    array<long,ASIZE> c;
    clock_t timestart=clock();
        for(long i=0;i<ASIZE;++i)
        {
            c[i]=rand();
        }
        cout<<"m-second:"<<(clock()-timestart)<<endl;
        cout<<c.size()<<endl<<c.front()<<endl<<c.back()<<endl<<c.data()<<endl;
    long target=get_a_target_long();
        timestart=clock();
        qsort(c.data(),ASIZE,sizeof(long),compareLongs);
    long* pItem=(long*)bsearch(&target,c.data(),ASIZE,sizeof(long),compareLongs);
        cout<<"qsort+bsearch:"<<(clock()-timestart)<<endl;
        if(pItem!=NULL)
            cout<<"foud"<<*pItem<<endl;
        else   
            cout<<"not found"<<endl;
    }
    long get_a_target_long()
    {
    long target=0;
        cout<<"target:";
        cin>>target;
        return target;

    }
    string get_a_target_string()
    {
    string target;
        cin>>target;
        return target;
    }   
    int compareLongs(const void*a,const void* b)
    {
        return (*(long*)a-*(long*)b);
    }
}
```
## 使用容器vector
1. c.push_back 在最后的地方的加入元素

` #include<algorithm> `

## 使用算法find
需要：

1. c.begin()
2. c.end()
3. target
## 使用sort
需要：

1. c.begin()
2. c.end(）

```cpp
#include<vector>
#include<algorithm>
namespace np_vector
{
    void test_vector(const long& value)
    {
        srand(time(NULL));
        cout<<"\ntest_vector()......\n";
    vector<string>c;
    clock_t timestart=clock();
        for(long i=0;i<value;i++)
        {
            c.push_back(to_string(rand()));
        }
        cout<<"m-deconds:"<<clock()-timestart<<endl<<"size:"<<c.size()
            <<endl<<"front:"<<c.front()<<endl<<"back"<<c.back()<<endl<<"data"<<c.data()<<endl<<
            "capacity"<<c.capacity()<<endl;
    string target=get_a_target_string();
        timestart=clock();
    auto pItem=::find(c.begin(),c.end(),target);
        cout<<"::find(),m-s:"<<clock()-timestart<<endl;
        if(pItem!=c.end())
            cout<<"found "<<*pItem<<endl;
        else
            cout<<"not found"<<endl;
        
        timestart=clock();
        sort(c.begin(),c.end());
    string* pItem2=(string*)bsearch(&target,c.data(),c.size(),sizeof(string),[](const void* a, const void* b) -> int {
        return (*(string*)a).compare(*(string*)b);
    });
        cout <<"sort()+bsearch(),m-s:"<<(clock()-timestart)<<endl;
        if(pItem2 !=NULL)
            cout<<"found,"<<*pItem2<<endl;
        else
            cout<<"not found!"<<endl;

    }
    string get_a_target_string()
    {
    string target;
        cin>>target;
        return target;
    }
      
}
```
## 使用list
包含的方法：
1. list.size
2. list.max_size
3. list.sort
4. list.front
5. list.back
6. list.push_back

```cpp
void test_list()
    {
        cout<<"\ntest_list()......\n";
    list<string>c;
    clock_t timestart=clock();
        srand(time(NULL));
        for(long i=0;i<ASIZE;i++)
            c.push_back(to_string(rand()));
        cout<<"m-s: "<<(clock()-timestart)<<endl<<"list.size:"<<c.size()<<endl<<"list.max_size:"<<c.max_size()
        <<endl<<"list.front"<<c.front()<<endl<<"list.back:"<<c.back()<<endl;
    string target=np_vector::get_a_target_string();
        timestart=clock();
    auto pItem=::find(c.begin(),c.end(),target);
        cout<<"::find m-s:"<<clock()-timestart<<endl;
        if (pItem != c.end())
        cout << "found " << *pItem << endl;
    else
        cout << "not found" << endl;
    }
```

## 使用forward_list
包含的方法：
1. c.push_front()
2. c.front()
3. c.max_size()
没有
c.back()和c.size()

## 使用slist
` #include<ext\slist>`
和forward_list完全相同

## 使用deque
内存是使用map，然后分配一段一段debuffer以供使用的
包含的方法：
1. c.push_back()
2. c.size()
3. c.back()
4. c.front()
5. c.max_size()

## 使用stack
先进后出
1. c.push()
2. c.size()
3. c.front()
4. c.back()

## 使用queue
先进先出

stack和queue都是使用deque实现的
##  使用multiset
包含方法：

1. c.size()
2. c.max_size()
3. c.find()
注意：红黑树是高度平衡二叉树，安插慢但是查找非常快

## 使用multimap
需要设置key和value两个值，且都要自己设置
包含方法：

1. c.size()
2. c.max_size()
3. c.find()
4. c.insert()需要使用pair
5. 需要得到第二个值需要使用*pItem.second

`c.insert(pair<long,string>(i,buf)); `

## 使用unordered_multiset
包含的方法：

1. c.insert(string(buf))
2. c.size()
3. c.max_size()
4. c.bucket_count()
5. c.load_factor()
6. c.max_load_factor()
7. c.max_bucket_count()

## 使用unordered_multimap
包含方法：

1. c.size()
2. c.max_size()
3. c.find()
4. c.insert()需要使用pair
5. 需要得到第二个值需要使用*pItem.second

## 使用容器set、map
不会保存重复的数据
set和上面没有什么区别
map可以使用[]，这和multimap不一样
c[i]=string(buf),所以value会重复但是key没有重复，所以会放进去key个值
## 包含find函数的容器
```cpp
std::vector: std::vector 提供了 find() 函数，用于在向量中查找特定值的元素。
template< class T, class Alloc >
typename std::vector<T,Alloc>::iterator find( std::vector<T,Alloc>& vec, const T& value );
std::list: std::list 提供了 find() 函数，用于在列表中查找特定值的元素。
template <class T, class Alloc>
typename std::list<T,Alloc>::iterator find (std::list<T,Alloc>& lst, const T& val);
std::deque: std::deque 也提供了 find() 函数。
template <class T, class Alloc>
typename std::deque<T,Alloc>::iterator find (std::deque<T,Alloc>& deq, const T& val);
std::set 和 std::multiset: std::set 和 std::multiset 提供了 find() 函数，但是它们返回的是迭代器，而不是普通的迭代器。
iterator find( const key_type& key );
std::unordered_set 和 std::unordered_multiset: 无序集合也提供了 find() 函数。
iterator find( const key_type& key );
```
# 分配器之测试
默认分配器是 allocator
分配器有两个函数
allocatte和dealloctte，但是没有必要单独去使用它们
在使用容器时使用默认分配器就可以了
而且分配器单独使用的时候不仅在分配时需要写多少内存，de的时候还要写上还多少内存
# 源代码之分布（vcc,gcc）
mingw在c盘中，include\c++\bits或者include\c++\ext（扩展）
# 面向对象vs泛型编程
oop是将data和methods合并
gp是将data和methods分开
## 采用gp的好处
*  容器和算法各自发展，使用迭代器串通即可

* 为什么list不能使用::sort？
因为::sort方法里面对位置硬需求连续（迭代器进行了加减乘除），所以list没有办法使用::sort

所有算法的涉及元素本身的操作无非就是比大小。
# 操作符重载和模板
## 操作符重载注意
::   .    .*    ?=不能被重载
迭代器一定会重载 * -> ++等符合指针观念的符号

## 模板知识在前面笔记中有详细记录
# 分配器
new 先 operator new()然后使用ctor
基本上所有容器都是默认使用allocator分配器

## vc编译器
allocator使用allocate 调用operator new最后使用的是malloc
没有任何特殊设计
但是operator new在单个元素占用较小时，额外开销会较大，这也导致allocator也是如此

## bc和vc设计相同
只是bc的allocator的第二参数有默认值

## gcc2.9<defalloc.h>中也是如此
`但是`:gcc使用的不是这一种allocator
使用的是<stl_alloc.h>中的alloc函数
原本的allocator会为每个元素都记录cookie，但是容器的每个元素大小都是一样的，alloc就是在这一点上下文章
alloc会有一个16个元素的链表，从0－15依次为8的增长的倍数，alloc会使用这个链表进行分配内存

## gcc4.9使用的分配器又变了回去
原本较好的版本变成了扩展库的 __pool_alloc
如果要使用，如下
```cpp
vector<string,__gnu_cxx::__pool_alloc<string>>vec;
```
# 容器之间的实现关系与分类

rb-tree
    ->
1. set
2. map
3. multiset
4. multimap
<br>
array
vector->heap->priority_quene
list--forward_list
slist
<br>
deque
->
1. stack
2. queue
<br>
非标准：
hashtable
->
1. hash_set--unorderdset
2. hash_map--unorderdmap
3. hash_multiset--unorderdmultiset
4. hash_multimap--unorderdmultimap
注意：这里的->不是继承关系，而是复合关系，后面的容器才会出现继承.--表示在c++11后面的改名
# 深度探索list
## 容器list
1. list在2.9中sizeof()是4，里面只有一个指针
2. 这个指针指向节点表，节点表里面保存了向前和向后的两个指针（void*),同时还有一个泛式的指针，这两个指针会发生形态转换，所以性能较差。
3. 类中还有iterator类，他的++应该被重载为指向下一个元素
4. 所有的容器除了array，vector都应该吧iterator设计成类i，这样才能变得智能，同时大家都会吧一个类typedef变成iterator
5. iterator类要被当作指针使用，所以会有大量操作符重载
6. 所有的iterator至少会有5个typedef
7. ++有两种形态，前置和后置，所以会有operator++()前++和operator++(int)后++,这里的int并没有实际含义。
```cpp
//这里有很重要一点要注意
self operator++(int) {
self tmp=*this;
//注意，这里的*并不会调用operator* 因为这里先调用了=即拷贝构造
++*this;
//注意这里将*this作为参数传给了operator++()
return tmp;
//继续调用拷贝构造
```
我们在设计时我们要向整数看齐，整数前++可以两次，但是后++不允许两次。
`以后++为什么返回的是值，而前++返回的是引用？这就是原因`
```cpp
reference operator*() const
{return (*node).data;}

pointer operator->() const
{return  &(operator*());}
```

疑点：
1. 为什么节点表用指向void的指针
2. 为什么迭代器传了三个参数？

G4.9相较于G2.9:
* 模板参数只有一个
* nodelist中的类型变成指向自己，同时data继承自向前向后指针，而不是和他们在一起

list为什么从4->8?
从一个指针变成了两个指针
# 迭代器的设计原则和Iterator Traits的作用与设计

traits：特征   人为设置的萃取机
rotate算法想要知道iterator的什么属性？
1. iterator_category: 迭代器的类型标签，用于标识迭代器的类型（例如，输入迭代器、输出迭代器、前向迭代器、双向迭代器、随机访问迭代器）。
2. value_type: 迭代器指向的元素类型。
3. difference_type: 两个迭代器之间的距离类型。
4. reference: 迭代器所指向元素的引用类型。
5. pointer: 指向迭代器所指向元素的指针类型。
4和5两种type从未被使用过
` std::ptrdiff_t 是一个整数类型，用于表示指针之间的差值（即指针之间的距离）。它通常被用作迭代器的 difference_type 类型，用于表示两个迭代器之间的距离。`
使用举例：
```cpp
template<typename _Tp>
struvt _List_iterator
{
typedef std::bidirectional_iteartor_tag itrator_category;
typedef _Tp value_type;
trpedef _Tp* pointer;
typedef _tp& reference;
typedef ptrdiff_t difference_type;
...
}

```
只有class才能做typedef，那如果iterator不是一个class呢？
native pointer被视为一种退化的iterator
这种时候Iterator traits就该登场了
它使用泛型编程将不同的类型偏特化
算法为了不用考虑迭代器是不是class就可以使用traits
```cpp
template<typename I,...>
void algorithm(...){
    typenameiterator_traits<I>value_type v1;
    }
```

traits是怎么设计的？
```cpp
template <class I>
struct iterator_traits{
typedef typename I::value_type value_type;
};
//class进入这里

template <class T>
struct iterator_traits<T*>{
typedef T value_type;
};
//指针进入这里

template <class T>
struct iterator_traits<const T*>
{typedef T value_type;};
//注意是T而不是const T
```
* typename 关键字的作用是告诉编译器 I::value_type 是一个类型名字，而不是其他实体，这样编译器就能正确地解析模板代码。

***
* 为什么const T*是T而不是const T？
因为value_type的主要目的是用来声明，而声明一个无法被赋值的变量没什么用。


*** 
完整的iterator_traits
```cpp
template <class I>
struct iterator_traits {
    // 提取迭代器的类别
    typedef typename I::iterator_category iterator_category;

    // 提取迭代器的值类型
    typedef typename I::value_type value_type;

    // 提取迭代器的差值类型
    typedef typename I::difference_type difference_type;

    // 提取迭代器的指针类型
    typedef typename I::pointer pointer;

    // 提取迭代器的引用类型
    typedef typename I::reference reference;
};

// partial specialization for regular pointers
template <class T>
struct iterator_traits<T*> {
    // 提取迭代器的类别
    typedef std::random_access_iterator_tag iterator_category;

    // 提取迭代器的值类型
    typedef T value_type;

    // 提取迭代器的差值类型
    typedef std::ptrdiff_t difference_type;

    // 提取迭代器的指针类型
    typedef T* pointer;

    // 提取迭代器的引用类型
    typedef T& reference;
};

// partial specialization for regular pointers
template <class T>
struct iterator_traits<const T*> {
    // 提取迭代器的类别
    typedef std::random_access_iterator_tag iterator_category;

    // 提取迭代器的值类型
    typedef T value_type;

    // 提取迭代器的差值类型
    typedef std::ptrdiff_t difference_type;

    // 提取迭代器的指针类型
    typedef const T* pointer;

    // 提取迭代器的引用类型
    typedef const T& reference;
};

```
# vector深度探索
特点：
当空间不够时，会找到一块空闲空间存储原来的两倍大小的数据
```cpp
template <class T, class Alloc = std::allocator<T>>
class vector {
public:
    // 类型别名
    typedef T value_type;
    typedef T* iterator;
    typedef T& reference;
    typedef size_t size_type;

protected:
    // 数据成员
    size_type size;
    iterator start;
    iterator finish;
    iterator end_of_storage;

public:
    // 构造函数
    iterator begin() { return start; }
    iterator end() { return finish; }

    // 返回数组大小
    size_type size() const { return static_cast<size_type>(end() - begin()); }

    // 返回数组容量
    size_type capacity() const { return static_cast<size_type>(end_of_storage - begin()); }

    // 判断数组是否为空
    bool empty() const { return begin() == end(); }

    // 访问元素
    reference operator[](size_type n) { return *(begin() + n); }
    reference front() { return *begin(); }
    reference back() { return *(end() - 1); }
};
```
他的空间是连续的所以就不需要重新定义一个类了

上面的是2.9的版本，但是在4.9中他将迭代器放在了成员模板中，这样她走的就是直接的class T，为了一致性却放弃了美观。
# array、forward_list深度探索

把array变成容器的目的是让她能够享受到算法，要不然新的特性他都不能使用。
连续空间的容器的迭代器都可以直接使用指针
# deque,quene,stack的深入了解
deque的扩容方式是分段式的。
他的iterator有四个元素：
1. cur
2. first
3. last
4. node
first 和node是一个node的开始和结束
因为内存不是连续的，所以迭代器就没有直接写在容器里面，使用typedef起一个别名。
deque会判断insert的点靠近前面还是最后
deque模拟连续空间靠的是iterator
```cpp
difference
operator-(const self& x) const
{
    return difference_type(buffer_size())*(node-x.node-1)+(cur-first)+(x.last-v.cur);
}

self&
operator++()
{
    ++cur;
    if(cur == last){
    set_node(node+1);
    cur=first;
    }
    return *this;
}

self&
operator++(int)
{
    self temp=this*;
    ++*this;
    return tmp;
}

self& operator--(){
    if (cur==first){
        set_node(node-1);
        cur=last;
    }
    --cur;
    return *this;
}

seld operator--(int){
    selftmp =*this;
    --*this;
    return tmp;
}

void set_node(map_pointer new_node){
    node=new_node;
    first=*new_node;
    last=first+difference_type(buffer_size());
}

self& operator+=(difference_type n) {
    difference_type offset = n + (cur - first);
    if (offset >= 0 && offset < difference_type(buffer_size())) {
        // 目标位置在同一缓冲区内
        cur += n;
    } else {
        // 目标位置不在同一缓冲区内
        difference_type node_offset = offset > 0 ?
                                      offset / difference_type(buffer_size()) :
                                      -difference_type((-offset - 1) / buffer_size()) - 1;
        // 切换至正确的缓冲区
        set_node(node + node_offset);
        // 切换至正确的元素
        cur = first + (offset - node_offset * difference_type(buffer_size()));
    }
    return *this;
}

self operator+(difference_type n) const {
    self tmp = *this;
    return tmp += n;
}

self& operator-=(difference_type n) {
    return *this += -n;
}

self operator-(difference_type n) const {
    self tmp = *this;
    return tmp -= n;
}

reference operator[](difference_type n) const {
    return *(*this + n);
}

```

quene和stack就是把deque的某些功能给封闭就可以了
他们可以选择deque或者list作为底部支撑
quene不可选择vector，但是stack可以选择vector
他们都不可以选择set和map作为底层支撑
# RB_tree深度探索
红黑树是平衡二分搜索树中常被使用的一种。
他是关联容器中重要的一种，另一个是哈希表。
re_tree有两种insert操作：insert_unique()和insert_equal(),
前者key一定要独一无二，第二种则表示可重复。
key加data一起才是value
需要的参数：
1. key的类型
2. value的类型
3. 怎么取得key
4. 比较方法
5. Alloc
# 容器set，multiset深度探索
set/multiset的value和key合一
我们无法使用iterator去改变元素值，因为他的迭代器调用的是红黑树的const-iterator
set不可以重复，insert用的是unique
multiset可以重复，insert用的是equal
需要三个参数：
1. class key
2. class Compare=less<Key>
3. class Alloc=alloc 

这里的less<key>使用的是仿函数方面的知识
set的所有操作，都是让t去操作，所以也可以称呼set为红黑树的适配器

# map,multimap的深度探索
map无法使用ietrator来修改key，但是可以用来改data
需要的参数：
1. class Key
2. class data
3. class Compare =less<Key>
4. class Alloc=alloc

相当于红黑树收到参数：
1. int 
2. pair<const int,string>
3. select1st<pair<const int,string>
4. less<int>
5. alloc

map有独特的operator[]:
传回中括号内对应key的data，如果不存在的话，那么就会创建那个元素
# hashtable深度探索
另一个和rb_tree差不多的容器是hashtable，他也分出了不同的set和map
空间不足时，大家都同时除以同一个数，看余数来放置，但这样会发生碰撞，后来大家把碰撞的数据直接串在一起就行了
但是一个链表也有可能会非常长，这时候就需要打散
什么时候判断为长：当链表比表的长度还要长时。
大家一般使用素数作为元素初值长度
可以使用迭代器改变data但是不能改变key
需要的模板参数：
1. value
2. key
3. HashFcn     元素怎么改成编号     hash
4. ExtractKey  怎么取出key  identity
5. EqualKey    什么情况算相等
6. Alloc
hashfcn有专门的hash泛化方法，字符串都会进行特殊的够乱的转化，得出hashcode
但是标准库没有对string提供专门的hash 方法
# hash表和红黑树
哈希表
主要作用：加快查找速度。时间复杂度可以近似看成O（1）.

了解哈希表首先得明白哈希函数。

1.哈希函数特点：

1.其输入无限，输出有限。

2.每次相同的输入一定得到相同的输出。不同的输入也可能产生相同的输出。（哈希碰撞）

3.输出分布是绝对离散的，不会受输入的影响，即同样的面积在任何地方框点都是差不多的。（最重要，哈希函数主要利用这个性质）

4.任何值模上一个数，最后一定得到0-该数的一个范围值。比如任何数模（或者说取余）上100，最后得到的值一定在0-99范围内。并且是绝对均匀分布。



哈希函数不害怕多个重复数字，因为他可以把多个数字都压缩在同一个值上。



哈希函数的目的是用于哈希表的第一步数组查询，直接通过取模（哈希函数）就得到哈希表对应的位置。这一步的时间复杂度是O（1）。


当出现数组的每个链表过长的时候，需要扩容。扩容之后全部每一条数据都得重新计算。


时间复杂度：

哈希表每次增删改查的代价可以说是O（1），虽然每次扩容的代价是O（logn）。一个原因是现实使用的工程数据量都是非常低的，另一个原因是离线技术，不占用用户使用的时候的时间。



2.哈希函数的缺点：

1.当更多的数插入时，哈希表冲突的可能性就更大。对于冲突，哈希表通常有两种解决方案：第一种是线性探索，相当于在冲突的地方后建立一个单链表，这种情况下，插入和查找以及删除操作消耗的时间会达到O(n)，且该哈希表需要更多的空间进行储存。第二种方法是开放寻址，他不需要更多的空间，但是在最坏的情况下（例如所有输入数据都被map到了一个index上）的时间复杂度也会达到O(n)。



2.在决定建立哈希表之前，最好可以估计输入的数据的size。否则，resize哈希表的过程将会是一个非常消耗时间的过程。例如，如果现在你的哈希表的长度是100，但是现在有第101个数要插入。这时，不仅哈希表的长度可能要扩展到150，且扩展之后所有的数都需要重新rehash。



3.哈希表中的元素是没有被排序的。然而，有些情况下，我们希望储存的数据是有序的。



哈希表的应用场景：

C++中如unordered_map和unordered_set。

哈希表适用于那种查找性能要求高，数据元素之间无逻辑关系要求的情况。例如做文件校验或数字签名。当然还有快速查询功能的实现。



红黑树
主要目的：主要是用它来存储有序的数据，它增删改查的时间复杂度都是O(logn)。

采用迭代器遍历一棵红黑树的时间复杂度是多少呢？ 是O(N)。

红黑树首先是平衡二叉树（AVL）的一种，所以他一定满足根节点小于左子树大于右子树。再然后才是它特有的属性。



二分查找法———二分查找树———AVL树———红黑树

二分查找法不能处理大数据和非数字情况，有了二分查找树；二分查找树会出现单链表情况，所以有了AVL树通过旋转实现绝对平衡；但是AVL树为了维护绝对平衡，几乎每次插入删除都要进行旋转操作；删除节点的时候，需要要维护从被删除节点到根节点这几个节点的平衡，旋转的时间复杂度是O（logn）,所以有了红黑树，在牺牲一定的查找效率的情况下，提升了删除效率。



RB-Tree是功能、性能、空间开销的折中结果。

总结：实际应用中，若搜索的次数远远大于插入和删除，那么选择AVL，如果搜索，插入删除次数几乎差不多，应该选择RB。



应用场景：C++中如map和set都是用红黑树实现的。



红黑树和哈希表的比较
map的底层是红黑树，unordered_map底层是哈希表，明明哈希表的查询效率更高，为什么还需要红黑树？

hashmap有unordered_map，map其实就是很明确的红黑树。map比起unordered_map的优势主要有：

1.map始终保证遍历的时候是按key的大小顺序的，这是一个主要的功能上的差异。（有序无序）

2.时间复杂度上，红黑树的插入删除查找性能都是O(logN)而哈希表的插入删除查找性能理论上都是O(1)，他是相对于稳定的，最差情况下都是高效的。哈希表的插入删除操作的理论上时间复杂度是常数时间的，这有个前提就是哈希表不发生数据碰撞。在发生碰撞的最坏的情况下，哈希表的插入和删除时间复杂度最坏能达到O(n)。

3.map可以做范围查找，而unordered_map不可以。

4. 扩容导致迭代器失效。 map的iterator除非指向元素被删除，否则永远不会失效。unordered_map的iterator在对unordered_map修改时有时会失效。



5.因为3，所以对map的遍历可以和修改map在一定程度上并行（一定程度上的不一致通常可以接受），而对unordered_map的遍历必须防止修改map的iterator可以双向遍历，这样可以很容易查找到当前map中刚好大于这个key的值，或者刚好小于这个key的值这些都是map特有而unordered_map不具备的功能。（这个不太明白，先放一放）



对第二点的参考

时间复杂度

红黑树的插入删除查找性能都是O(logN)而哈希表的插入删除查找性能理论上都是O(1)，在这个对比上来看，红黑树性能远没有哈希表优秀。但是值得一提的是红黑树从上面介绍的资料来看，**他是相对于稳定的，最差情况下都是高效的。**而相对于哈希表这个数据结构来讲，哈希表的插入删除操作的理论上时间复杂度是常数时间的，这有个前提就是哈希表不发生数据碰撞。**在发生碰撞的最坏的情况下，哈希表的插入和删除时间复杂度最坏能达到O(n)。**而在一般情况下，如果在实际应用中，当然一个相对稳定且快速的数据结构是比较理想的选择。



红黑树基本特征，avl和红黑树的优缺点

红黑树的基本特征就那5个，234这三个类似，记下第5个和第1个就好了：红黑树

两者的优缺点比较：AVL树和红黑树比较

因为avl树是高度平衡，而红黑树通过增加节点颜色从而实现部分平衡，即从根到叶子的最长的可能路径不多于最短的可能路径的两倍长，这就导致，插入节点两者都可以最多两次实现复衡，而删除节点，红黑树最多三次旋转即可实现复衡，旋转的量级是O（1），而avl树需要维护从被删除节点到根节点这几个节点的平衡，旋转的量级是O（logn）,所以红黑树效率更高，开销更小，但是因为红黑树是非严格平衡，所以它的查找效率比avl树低。

平衡性方面（查找效率）， 插入节点方面，删除节点方面。



RB-Tree是功能、性能、空间开销的折中结果。

总结：实际应用中，若搜索的次数远远大于插入和删除，那么选择AVL，如果搜索，插入删除次数几乎差不多，应该选择RB。
# unordered容器
hash开头的容器都变成了unordered容器
篮子一定大于元素个数
# 算法的形式
算法时STL中唯一的function template
一般会有不同版本，最后一个参数用来传递比较标准
算法通过迭代得到很多信息
# 迭代器的分类以及对算法的影响
算法用的比较方法一般是仿函数
迭代器的category：
1. list rb-tree这种不能跳的双向-bidirectional_iterator_tag
2. forward_list hash_table 这种不能跳的单项链表是farward_itaretor_tag
3. array,vector,deque 这种是能跳的双向就是random 
五种category：
input(istream_it...)->farward->bidirectional->random_access
ouput(ostream_it...)

使用#inlcued<typeinfo>可以使用typeid(itr).name()可以直接得到它的类型名字
***
istream为了接口一样后面版本新增的模板参数有默认值
最新的迭代器继承自一个父类，这个父类定义了迭代器必须有的五种属性

写算法时要注意返回的类型为
```cpp
template<class InputIterator>
iterator_traits<InputIterator>::difference_type
distance(...){...}
```
然后他们会根据category去调用不同的函数
前面有提到过，前面的category有继承关系，所以子函数不用写全部的种类，可以直接写input_iterator
除了iterator traits还有type traits也会对算法有影响
# 算法源代码剖析
qsort和bsearch时c函数
c++定义的标准库algorithms都是两个指针开头的
算法需要的仿函数：
1. 直接就是函数 
```cpp
int myfunc(int x,int y){return ...}

```
2.也可以是类似函数的东西
```cpp
struct myclass{
 int operator()(int x,int y){}
 }myobj;
```
算法举例：

1. accumulate
2. for_each
3. replace(I,I,ld,new)
4. replace_if,replace_copy
5. count,count_if(array,vector,list,forward_list,deque不带count)相当于关联式容器（相当于小数据库）有自己的count
6. sort（只有list,forward_list自带sort）记得不要对自带排序的容器进行排序
7. find，和count一样，关联式容器都有自己的find
8. binary_search必须要先排序，使用的是lower_bound

关于reverse iterator,rbegin(),rend()
reverse iterator是一个适配器
# 仿函数和函数对象
既然是仿函数，那就要有函数的基本功能，所以它作为一个类他一定要重载（）。
identity，select1st,select2nd是gnu独有的
4.9之后名称前要加下划线
std::plus、std::minus、std::multiplies、std::less、std::greater都在functional库中
注意一般的仿函数要创建一个临时对象，所以要在类名后面加上括号
当仿函数没有继承binary_function就相当于没有融入STL
```cpp
// 定义一元函数对象模板
template <class Arg, class Result>
struct unary_function {
    typedef Arg argument_type;   // 参数类型
    typedef Result result_type;  // 返回值类型
};

// 定义二元函数对象模板
template <class Arg1, class Arg2, class Result>
struct binary_function {
    typedef Arg1 first_argument_type;   // 第一个参数类型
    typedef Arg2 second_argument_type;  // 第二个参数类型
    typedef Result result_type;         // 返回值类型
};

``` 
作用就是接受一个名字然后换一个名字
如果要让仿函数可适配，那么就要继承适合的父类，即上面两个类

# adapter和Binder2nd
a改造了b，虽然大家用的都是a，但是都是交给b。
所以a可以继承或者复合
但是普通的适配器都是复合
```cpp
template <class Operation>
inline binder2nd<Operation> bind2nd(const Operation& op, const T& x) {
    typedef typename Operation::second_argument_type arg2_type;  // 获取二元操作符的第二个参数类型
    return binder2nd<Operation>(op, arg2_type(x));  // 返回一个 binder2nd 对象，将操作符 op 和参数 x 绑定在一起
}
template <class Operation>
class binder2nd : public unary_function<typename Operation::first_argument_type,typename Operation::result_type> {
protected:
    // 内部成员，分别用以记算式和第二参
    Operation op;
    typename Operation::second_argument_type value;

public:
    // constructor，用于初始化成员变量 op 和 value
    binder2nd(const Operation& x, const typename Operation::second_argument_type& y)
        : op(x), value(y) {
    }

    // 重载函数调用运算符，用于调用算式并传入第二参
    typename Operation::result_type
    operator()(const typename Operation::first_argument_type& x) const {
        // 调用算式并传入第二参
        return op(x, value);
    }
};

```

注意，在bind2nd中返回的是一个临时对象，operator（）是在算法中通过对象调用的。

> 为什么需要这个辅助函数？

这个辅助函数的作用就是为了避免重复写一遍返回值的类型。

在使用模板编程时，有时候我们需要显式地指定模板参数的类型，但是如果我们可以从其他地方推导出这个类型，就可以避免显式指定。

在这个函数模板中，Operation 是一个模板参数，表示一个二元操作符的类型。而 Operation::second_argument_type 是 Operation 类中定义的一个类型别名，表示这个二元操作符的第二个参数的类型。通过使用 typename Operation::second_argument_type，我们可以从 Operation 类中获取到这个类型。

而在函数模板的返回语句中，使用了 arg2_type 类型来包装参数 x。这样一来，不管 Operation::second_argument_type 是什么类型，都可以使用 arg2_type 类型来包装参数 x，从而创建一个新的 binder2nd 对象。

这样一来，我们不必再手动指定返回值的类型，而是使用模板参数推导出来的类型，从而使代码更加简洁和通用。

> 为什么类不能自己推导模板参数，但是函数可以？

函数模板可以通过参数类型推导直接确定模板参数，是因为函数模板在调用时提供了实际的参数，编译器可以根据这些参数推导出模板参数的类型。

例如，对于下面的函数模板：

```cpp
Copy code
template <typename T>
void foo(T x) {
    // 函数体
}
```
当你调用 foo 函数时，传递给函数的参数 x 的类型是明确的，编译器可以根据参数 x 的类型来推导模板参数 T 的类型。例如：

```cpp
Copy code
foo(42);          // T 被推导为 int
foo(3.14);        // T 被推导为 double
foo("hello");     // T 被推导为 const char*
```
在这些情况下，编译器能够根据参数的类型来确定模板参数的类型，因此不需要显式地指定模板参数。

而对于类模板来说，它们的模板参数通常是与类的成员函数无关的类型，因此不能从成员函数的参数类型中推导出来。这就是为什么类模板通常需要显式指定模板参数的原因。

` 在C++中，类模板的实例化是在编译时完成的，而函数模板的实例化是在调用时完成的。编译器在实例化函数模板时可以根据函数调用的参数推断模板参数的类型，但是对于类模板，编译器无法根据类的成员或构造函数的参数来推断模板参数的类型。`
编译时完成：

对于类模板，编译器在编译时会根据模板参数的类型生成具体的类定义。这意味着在编译时，编译器会检查模板的语法和语义，以及模板参数的类型，然后生成相应的代码。
对于函数模板，编译器在编译时会根据函数调用的参数推断模板参数的类型，并生成相应的函数定义。这意味着在编译时，编译器会检查模板的语法和语义，以及函数调用的参数类型，然后生成相应的函数定义。
调用时完成：

对于函数模板，函数模板的实例化是在函数调用时完成的。这意味着在函数调用时，编译器会根据函数调用的参数类型推断模板参数的类型，并生成相应的函数定义。
对于类模板，类模板的实例化是在类对象创建时完成的。这意味着在类对象创建时，编译器会根据模板参数的类型生成具体的类定义
# not1和bind
和bind2nd差不多，就是取反的意思

## bind
c++11之后才提供的适配器
他可以绑定：
1. functions
2. function objects
3. member functions
4. data members

他需要占位符（在std::placeholders中)
如何使用？
1.binding functions
```cpp
auto fn=bind(my_divide,_1,_2);
cout<<fn(10,2)<<endl;
//注意这里的返回值类型是my_divide的返回值，可以加上模板参数，改变返回类型
bind<int>(my_divide,_1,_2);
```
2.binding members
```cpp
struct Mypair{
    double a,b;
    double multiply(){return a*b;}
};

MyPair ten_two{10,2};
auto bound_memfn=bind(&MyPair::multiply,_1);
cout<<bound_memfn(ten_two)<<endl;
//这里是普通的将参数放进去

auto bound_memfn=bind(&MyPair::multiply,ten_two);
//成员函数有一个默认的参数this，所以这里可以直接将对象放入成员函数中
```
binding data
```cpp
auto bound_memdata = bind(&MyPair::a, ten_two);
cout << bound_memdata() << endl;

auto bound_memdata2 = bind(&MyPair::b, _1);
cout << bound_memdata2(ten_two) << "in" << endl;

```
# 迭代器适配器reverse_iterator和inserter
reverse_iterator
```cpp
template <class Iterator>
class reverse_iterator {
protected:
    Iterator current; // 指向正向迭代器
public:
    // 逆向迭代器的 5 个关联类型与其封装的正向迭代器相同
    typedef typename iterator_traits<Iterator>::iterator_category iterator_category;
    typedef typename iterator_traits<Iterator>::value_type value_type;
    typedef Iterator iterator_type;
    typedef reverse_iterator<Iterator> self;

public:
    explicit reverse_iterator(iterator_type x) : current(x) {}
    reverse_iterator(const self& x) : current(x.current) {}

    iterator_type base() const { return current; } // 获取正向迭代器

    reference operator*() const { Iterator tmp = current; return *--tmp; }
    // 逆向迭代器取值，就是将其封装的正向迭代器退一位取值。

    pointer operator->() const { return &(operator*()); } // 通过箭头获取

    // 前置递减，退一步
    self& operator++() { --current; return *this; }
    self& operator--() { ++current; return *this; }

    // 后置加减
    self operator+(difference_type n) const { return self(current - n); }
    self operator-(difference_type n) const { return self(current + n); }

    bool operator==(const self& x) const { return current == x.current; }
    bool operator!=(const self& x) const { return current != x.current; }
    // 还有其他比较运算符等
};

```
注意，因为end指向的是最后一个数据的后面一个，所以operator*指向的是--current

## inserter
目的是希望插入的时候使用的不是赋值，而是insert
```cpp
template<class InputIterator, class OutputIterator>
OutputIterator copy(InputIterator first, InputIterator last, OutputIterator result) {
    while (first != last) {
        *result = *first;
        ++result;
        ++first;
    }
    return result;
}

// adapter 将 iterator 的赋值 (assign) 操作改为插入 (insert) 操作，将 iterator 右移一位置
// 如此便可在速度上欺骗行为。表面上是 assign，实际上是 insert 的行为。
template <class Container>
class insert_iterator {
protected:
    Container* container; // 底层容器
    typename Container::iterator iter;

public:
    typedef std::output_iterator_tag iterator_category; // 注意

    insert_iterator(Container& x, typename Container::iterator i) : container(&x), iter(i) {}

    insert_iterator<Container>& operator=(const typename Container::value_type& value) {
        iter = container->insert(iter, value); // 调用 insert()
        ++iter; // 令 insert iterator 跟随其 target 贴身移动
        return *this;
    }
};

// 辅助函数，帮助用户使用
template <class Container, class Iterator>
inline insert_iterator<Container> inserter(Container& x, Iterator i) {
    return insert_iterator<Container>(x, i);
}

```
这里使用的是操作符重载的魅力，copy的内容已经写好，但是可以通过重载等于号，改变copy中赋值的含义
# x适配器ostream_iterator和istream_iterator

## ostream_uterator
```cpp
template <class T, class charT = char, class traits = std::char_traits<charT>>
class ostream_iterator : public std::iterator<std::output_iterator_tag, void, void, void, void> {
    std::basic_ostream<charT, traits>* ostream;
    const charT* delim;

public:
    typedef charT char_type;
    typedef traits traits_type;
    typedef std::basic_ostream<charT, traits> ostream_type;

    ostream_iterator(ostream_type& s) : ostream(&s), delim(0) {}
    ostream_iterator(ostream_type& s, const charT* delimiter) : ostream(&s), delim(delimiter) {}
    ostream_iterator(const ostream_iterator<T, charT, traits>& x) : ostream(x.ostream), delim(x.delim) {}

    ~ostream_iterator() {}

    ostream_iterator<T, charT, traits>& operator=(const T& value) {
        *ostream << value;
        if (delim != 0)
            *ostream << delim;
        return *this;
    }

    ostream_iterator<T, charT, traits>& operator*() { return *this; }
    ostream_iterator<T, charT, traits>& operator++() { return *this; }
    ostream_iterator<T, charT, traits>& operator++(int) { return *this; }
};

```
和inserter一样通过重载operator=来改变copy的含义
同时这里还重载了operator*改变了copy中*result的含义


##  istream_iterator
```cpp
template <class T, class charT = char, class traits = std::char_traits<charT>, class Distance = std::ptrdiff_t>
class istream_iterator : public std::iterator<std::input_iterator_tag, T, Distance, const T*, const T&> {
    std::basic_istream<charT, traits>* instream;
    T value;

public:
    typedef charT char_type;
    typedef traits traits_type;
    typedef std::basic_istream<charT, traits> istream_type;

    istream_iterator() : instream(0) {}
    istream_iterator(istream_type& s) : instream(&s) { ++*this; }
    istream_iterator(const istream_iterator<T, charT, traits, Distance>& x) : instream(x.instream), value(x.value) {}

    const T& operator*() const { return value; }
    const T* operator->() const { return &value; }

    istream_iterator<T, charT, traits, Distance>& operator++() {
        if (instream && !(*instream >> value))
            instream = 0;
        return *this;
    }

    istream_iterator<T, charT, traits, Distance> operator++(int) {
        istream_iterator<T, charT, traits, Distance> tmp = *this;
        ++*this;
        return tmp;
    }
};
```
注意当这个类开始创建对象的时候就已经开始采集数据了
# 一个万用的hash function
形式上：
设计hash function如果设计成类成员函数，那么使用时可以直接
unordered_set<Customer,CustomerHash>custest;

设计成函数形式的话比如
```cpp
size_t customer_hash_func （）{}
```
之类，在使用时不仅模板参数要设置，函数是什么类型，还要使用构造函数时指定使用的是什么特定函数
比如
```cpp
unordered_set<Customer,size_t(*)(const Customer&)>custsrt(20,customer_hash_func);
```

关键是怎么设计这个function
hash类有很多特化版本，可以直接调用，但是这个方法会生成很多碰撞
所以编译器的处理方法是使用seed之类的东西定义了hashfunc
```cpp
class CustomerHash {
public:
    std::size_t operator()(const Customer& c) const {
        return hash_val(c.fname, c.lname, c.no);
    }
};
template <typename... Types>
inline size_t hash_val(const Types&... args) {
    size_t seed = 0;
    hash_val(seed, args...);
    return seed;
}

template <typename T, typename... Types>
inline void hash_val(size_t& seed, const T& val, const Types&... args) {
    // 计算当前参数的哈希值并合并到 seed 中
    hash_combine(seed, val);
    // 递归调用 hash_val 处理剩余的参数
    hash_val(seed, args...);
}
//这是一个特化版本，第一个参数是size_t
template <typename T>
inline void hash_val(size_t& seed, const T& val) {
    // 计算当前参数的哈希值并合并到 seed 中
    hash_combine(seed, val);
}
#include <functional>

template <typename T>
inline void hash_combine(size_t& seed, const T& val) {
    seed ^= std::hash<T>{}(val) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
}
//0x9e3779b9又被称为黄金比例
```
# tuple，用例
可以包含任意个数据
如何使用：
```
tuple<int,float,string>t1(41,6.3,"nico");

```
如何取出？
get<0>(t1)
使用也可以auto t2=make_tuple(...);
取出也可以：
```cpp
int i1;
float f1;
string s1;
tie(i1,l1,s1)=t3;
```
tuple如何实现：
```cpp
template <typename... Values>
class tuple;

template <>
class tuple<> {
    // 空元组，没有任何成员
};

template <typename Head, typename... Tail>
class tuple<Head, Tail...> : private tuple<Tail...> {
private:
    using inherited = tuple<Tail...>;

public:
    // 构造函数，初始化成员变量 m_head 和继承类 inherited
    tuple(Head v, Tail... vtail) : m_head(v), inherited(vtail...) {}

    // 返回头部元素
    typename Head::type head() const { return m_head; }

    // 返回尾部元组
    const inherited& tail() const { return *this; }

protected:
    Head m_head; // 头部元素
};

```
自己继承自己
这里的tail是怎么实现return*this但是返回的的尾部呢？
构造是由内到外，所以后面的在前面先构造，这里的数据就是有m_head，然后传回使用*this返回类型是inherited&，这样的话就因为this指向这个类，但是inherited这个类型只有被继承的大小，所以就可以准确去取出需要的数据了。
# type traits
```cpp
template <class type>
struct type_traits {
    typedef false_type has_trivial_default_constructor;
    typedef false_type has_trivial_copy_constructor;
    typedef false_type has_trivial_assignment_operator;
    typedef false_type has_trivial_destructor;
    typedef false_type is_POD_type;

};

```
注意，这里false是指重要的意思
这是2.9的版本
c++2.0之后变得很多很多
但是可以自动知道你的类的各种属性是什么样的

他是如何实现的？
```cpp
template<typename _tp>
struct remova_const
{typedef _tp type;};

template<typename _tp>
struct remobe_const<_tp const>
{typedef _tp type;};
```
使用偏特化来去除前缀
判断是不是void
就是先去掉const和volatile，然后使用相同的偏特化来判断是不是void


怎么实现is_class,is_union...?
他们都是交给辅助函数去做
这些没有官方代码，编译器的做法应该是在编译时就能知道是不是类，然后写出判断

# cout
cout是对象，父类是ostream，ostream虚继承自ios
为什么任何类型都能cout<<,就是使用了重载

# moveable元素对于性能的影响
普通的拷贝构造
```cpp
M c1;
M c11(c1);
Mc12(std::moce(c1));

``` 
move 版本和浅拷贝差不多，但是会在运动时设置原来为NULL
