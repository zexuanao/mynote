# c++编程简介
## 目标：

- Object Based(基于对象）
- Object Oriented(面向对象)

## C++的历史
new C->C with Class->C++
java、c#
演化：	c++ 98(1.0)->03->11(2.0)->14
## 需要学习的：
c++语言、c++标准库
# 头文件与类的声明
## c++与c的不同：·
c的数据是全局的，c++提供了更多的关键字让数据和函数抱在一起，更方便处理（面向对象）
## class经典分类：

- Class without pointer member(s)
    complex
- Class with pointer member(s)
    string

## c++代码基本形式

- #include<标准库>
- #include"自己写的东西"

### output
c使用stdio库 cstdio   
c++使用iostream.h
iostream
### Header(头文件)中的防卫式声明
```cpp
#ifndef __COMPLEX__
#define __COMPLEX__

//Header的布局

#include <cmath>
class ostream;
class complex;
complex& __doapl (complex* ths,const complex& r)
//前置声明

class complex
{
...
}
//类的声明

complex::function ...
//类的定义

#endif
```
### class的声明
```cpp
class complex
//class head
{
//class body
public:
complex (double r=0,double i=0):re(r),im(i){}
complex& operator +=(const complex&);
double real() const {return re;}
double imag() const {return im;}
private:
double re,im;
friend complex& __doapl (complex*, const complex&);
};

{
    complex c1(2.5,1.5);
    complex c2(2,6);
    ...
}
```
### class template(模板)简介
```cpp
template<typename T>
class complex
//class head
{
//class body
public:
complex (T r=0,T i=0):re(r),im(i){}
complex& operator +=(const complex&);
double real() const {return re;}
double imag() const {return im;}
private:
T re,im;
friend complex& __doapl (complex*, const complex&);
}

{
    complex<double> c1(2.5,1.5);
    complex<int> c2(2,6);
    ...
}
```
# 构造函数
## inline(内联)函数
```cpp
class complex
//class head
{
//class body
public:
complex (double r=0,double i=0):re(r),im(i){}
complex& operator +=(const complex&);
double real() const {return re;}
double imag() const {return im;}
private:
double re,im;
friend complex& __doapl (complex*, const complex&);
}

{
    complex c1(2.5,1.5);
    complex c2(2,6);
    ...
}
```
函数若在class内定义为完成，便自动变成inline候选人
```cpp
inline double
img(const complex& x)
{
    return x.imag ();
}
```
也可以直接在函数前面加上inline ,也会变成内联函数
## access level访问级别
private :数据部分(封装),一些不希望被调用的函数
public  :函数
protect
## constructor构造函数
`complex (double r=0,double i=0):re(r),im(i){}`
     确认实参				                初值列，初始化

- 构造函数不需要有返回值
- 初值列，初始化的意义：在初始化的时候就赋值，效率更高

创建对象;
```cpp
{
    complex c1(2,1);
    complex c2;
    complex* p=new complex(4);
    ...
        }
```

- 构造函数有对应的析构函数：

一般只有包含指针的类需要析构函数
构造函数可以有很多个——**overloading重载**(常常用在构造函数上）
`void real (double r) {re=r;}`
虽然名称看起来相同，但是编译之后编译器看起来并不同
`complex() :re(0),im(0){}`
`complex (double r=0,double i=0):re(r),im(i){}`
这两个虽然看起来不一样，但是第一个没有参数，第二个虽然有参数的同时但也有默认值，编译器不知道选择哪一个，所以不可以
# 参数传递与返回值
## 构造函数可以放在private中
```cpp
class A{
public:
	static A& getInstance();
	setup() {...}
private:
	A();
	A(const A& rhs);
...
};

A& A::getInstance()
{
    static A a;
    return a;
}

//外界调用
A：：getInstance().setup();
//相当于A类自己创建了一个自己的对象，且只允许外界调用这一个对象
//这种方法被称为Singleton
```
## 常量成员函数
`double real() const {return re;}`
在写一个函数的时候就会想好这个函数会不会改变值，而不会改变的就一定要写const
例如
```cpp
double real() {return re;}
//没有写const，说明这个函数可能会改变值
｛
const complex c(1,2);
//使用者不希望函数改变它的值
cout << c.real();
//不希望改变和可能会改变这两个思想产生了矛盾，这并不好
｝
```
## 参数传递：pass by value & pass by reference

- pass by value	:传统的按值传递
- pass by reference:c++的引用(底层就像指针一样，所以速度非常快)

所以最好使用引用，但也有特殊情况，毕竟指针是四个字节，有些情况例如char－－只有一个字节。
`complex& operator += (const complex&);`
这就是使用引用的例子，const complex&说明我很快的同时，你也不能更改我的内容
## 返回值传递

- return by value
- return by reference

一般也是推荐使用引用，但是也有特殊情况。比如我在函数内创建了一个临时变量，如果传递引用，则会传递一个不知道是什么的地址，编译器会报错。
## friend友元
private的作用就是我不希望外部的人使用我的数据，而friend的作用就是‘在class的外部函数‘也可以使用我的数据。
`friend complex& __doapl (complex*,const complex&);`
```cpp
inline complex&
__doapl (complex* ths, const complex& r)
{
    ths->re+=r.re;
    ths->im+=r.im;
    return *ths;
}
//自由取得friend的private成员
```
	注意：相同class的各个objects互为friends(友元)。即public里面的函数可以直接使用类的数据。
# 操作符重载与临时对象
## operator overloading操作符重载-成员函数 
```cpp
inline complex&
complex::operator +=(const complex& r)
//注意所有的成员函数一定带着一个隐藏的参数this,代表作用者。
{
return __doapl(this ,r);
}
```
* 这里__doapl的意思是做一个赋值加法

>通过返回reference可以使用形似c3+=c2+=c1的操作 

## operator overloading操作符重载-非成员函数
"+"的可能用法：
1. c2=c1+c3;
2. c2=c1+1;
3. c2=1+c1;
为了应付上面的的三中可能用法，需要写出三个函数
```cpp
inline complex
operator + (const complex&, const complex& y)
{
return complex (real (x)+real(y),img(x)+img(y));
}

inline complex
operator +(const complex& x,double y)
{
...
}

inline complex
operator +(double x,const complex& y)
{
...
｝
//注意这里绝对不能返回reference,因为返回的一定是一个local object
//同时这里使用了typename()语法，这是使用临时对象的意思，存在时间只到下一行，普通人一般不用，但是标准库用的很多
```

### 当然，也有只有一个参数的情况

```cpp
inline complex
operator +(const complex& x)
{
 return x;
 }
 //这是标准库的情况，但是这里使用inline complex&更好
 inline complex
 operator - (const complex& x)
 {
 return complex(-real (x),-real(y));
 }
 //注意这里的real函数并不是局部定义的real,是global函数
 //template<class T>
 //T real(const std ::complex<T>& z);
``` 
>同理，相等和不相等符号返回bool在语法上并无差异

```cpp
inline complex
conj (const complex&x)
{
return complex(real(x),-img(x));
}
//共轭复数,这里是全局函数

## include<iostream.h>
ostream&
operator << (ostream& os,const complex& x)
{
return os <<'('<<real(x)<<','<<imag(x)<<')';
}
//特殊的符号不能写成成员函数，因为操作符号只能作用在左边。
//为了满足cout<< c1<< conj(c1);所以只能只能返回reference。
{
complex c1(2,1);
cout<< conj(c1);
cout<< c1<< conj(c1);
}
```
# 复习complex类的实现过程
1. 防卫式的定义
2. 先写出头，然后考虑这个类需要什么数据，写在private中。
3. 考虑需要什么函数，放在public中，首先，考虑构造函数（时刻考虑按值传送还是直接引用）。
4. 在构造函数中如果要赋值，首先想到使用新的更快的语法（complex(...):re().im(){}),然后考虑构造函数还需要什么操作。
5. 考虑哪些如要的操作函数，在声明这些函数时需要考虑使用成员函数还是非成员函数。当然，要考虑参数和返回值是引用还是value。
6. 当这个函数不会修改函数的时候要在函数名后面加上const
7. 当在后面函数中需要使用到类中的private数据时，需要用到friend。
8. 在编写需要用的类函数时也要考虑使用的参数是否会改变，当传出的东西不是local object时，优先考虑的一定是reference。
9. 函数最好的一定是inline函数。
10. 当然，考虑到＋函数并不是只有类内部会进行，所以也有非成员函数(global函数)的使用。tip:如果用成员函数就没办法实现double加复数的操作。同时因为+=被设计为了成员函数，所以是没有办法实现double+=复数这样的操作的。
# 拷贝构造，拷贝赋值，析构
## Class with pointer member(s)
    string

 - 首先当然需要防卫式声明

```cpp
#ifndef __MYSTRING__
#define __MYSTRING__

class String
{
...
}:

String::function(...)...

Global_function(...)...

#endif
```


- 然后考虑需要的功能

```cpp
int main ()
{
String s1();
//默认的初始化
String s2("hello");
//带字符串的初始化
String s3(s1);
//拷贝构造
cout<<s3<<endl;
//使用友元函数实现与cout的联动
s3=s2;
//拷贝赋值
cout<<s3<<endl;
}
```

 > 这些函数编译器都会有默认函数，但是如果类中有指针的话，使用拷贝构造和拷贝赋值时会让指针指向同一个东西，是浅复制，并不是真正的复制，这样的话析构函数就会把同一块地址释放两次，这是未定义的行为。不仅如此，默认的拷贝赋值时（例如b=a),b指向的东西就会丢失，（找不到原来的内容在哪里）造成内存泄漏。
 
 ---
 
 > 同时，如果没有重新定义析构函数，他就只会把指针指向的内容即数组的头部释放掉，delete不知道这是一个数组，这样就会造成内存泄漏。详情看“堆，栈与内存管理的最后一行”

``注意：上面两个内存泄漏并不是一个含义,一个是拷贝赋值造成的内存泄漏，一个是析构函数造成的内存泄漏，并没有重复。``

字符串一般都是使用地址，因为一般不知道字符串需要多大
这是string类的声明
```cpp
class String 
{
public:
    String (const char * cstr =0);
//    
    String (const String& str);
    String& operator = (const String& str);
    ~String();
//这三个函数（拷贝构造，拷贝赋值，析构函数）被称为big three
    char* get_c_str() const (return m_data;}
//这是一个inline函数，注意函数名后的const
private:
    char* m_data;
};

```
```cpp
inline
String::String(const char* cstr=0)
{
    if(cstr){
        m_data=new char[strlen(cstr)+1];
        strcpy(m_data,cstr);
    }
    else {
        m_data= new char[1];
        *m_data='/0';
    }
}

inline 
String::~String()
{
    delete [] m_data;
}
```    

 - 拷贝构造函数
```cpp
inline String::String(const String& str)
{
    m_data=new char[strlen(str.m_data)+1];
    strcpy(m_data,str.m_data);
}
{
    String s1("hello");
    String s2(s1);
//String s2=s1和String s2(s1)是一摸一样的，因为这时候s2都没有创建，所以使用的不是拷贝赋值而都是拷贝构造。

```

 - 拷贝赋值函数
 
``` cpp
 inline 
 String& String::operator=(const String& str)
 {
    if(this == &str)
        return *this;
//检测自我赋值，当一块地址有alias(别名)时有可能会不小心自我赋值。
    delete [] m_data;
    m_data= new char[strlen(str.m_data)+1];
    strcpy(m_data,str.m_data);
    return *this;
}
```

## output函数
```cpp
#include<iostream.h>
ostream& operator<<(ostream& os, const String& str)
{
	os<<str.get_c_str();
	returnos;
}

{
String s1("hello");
cout<<s1;
}

```
# 堆，栈与内存管理
**Stack 栈** 是存在于某作用域的一块内存空间，当你调用函数，函数本省就会生成一块space用来放置他所接受的参数。
> Complex c1(1,2);

**Heap  堆** 是指有操作系统提供的一块global内存空间，程序可自由分配。
> Complex c2=new Complex(3);

c1便是stack object ,其生命在作用域结束之后便会结束，又称auto object。
> static Complex c2(1,2);

c2生命一直持续到程序结束。

```cpp
class Complex{...};
...
Complex c3(1,2);
 int main()
 {
 ..
 }
```
这里的c3就是global object,也能算是一种static object，生命也是整个程序。
`Heap区域内的东西没有自己delete的话就会造成内存泄漏。`

```cpp
Complex* pc= new Complex(1,2);
//转化为


Complex* pc;
void * mem=operator new(sizeof(Complex));
//分配内存   operator new 是一个函数，内部调用malloc(n);
pc=static_cast<Complex*>(mem);
//转型
pc->Complex::Complex(1,2);
//构造函数    注意，构造函数是成员函数，所以构造函数的完整形态是Complex::Complex(pc,1,2);



delete ps;
//转化为


String::~String(ps);
//析构函数
operator delete(ps);
//释放内存    其内部调用free(ps)
```
> new是先创造mem在调用构造函数，delete是先调用析构函数再释放内存。

当new一个对象时，给的内存并不仅仅是只有一个类的内存。
> new complex 会给2个double和给8个位作为cookie用来方便回收，cookie用16进制来记录，一般位11，41之类，1是借最后一位的意思，如果不是16的整数，则会给pad字节作为补充。

` 当new一个数组时，会给4位用来记录有几个元素，而必须用array delete(delete [ ])是因为如果不用array delete，就只会唤起一次dtor，注意：这里内存泄露的不是数组内的东西，而是数组内的指针指向的东西。比如String* p =new String[3];...dekete p;就只会对数组内第一个string进行delete，因为他不知道有几个，指针指向的是数组的头。当知道是数组后，因为数组在前面会有包含几个元素的标志，所以可以准确delete而不用写出需要几个delete几个`
#  复习String类的实现过程
 1. 写出String类的头
2. 这个String类我需要什么呢：数组不太行，不能动态调整大小，所以使用指针。
3. 首先考虑构造函数，那么给他一个初值，同时考虑到不可能改变他，要记得在括号前面加const
4. 然后考虑拷贝构造，同样的，参数不会改变的话那就加上const
5. 再然后拷贝赋值，既然数据不是放在local object，使本来就存在的地方，所以直接return reference.
6. 既然使用了指针，那么一定要考虑~String，即析构函数。
7. 最后考虑到可能需要查看m_data，那么就创建一个成员函数用来返回m_data
8. 主要函数：

* 首先构造函数判断有没有初值，如果有那么就要给他足够的空间，要先给他new，然后给他赋值
* 如果没有初值。那就直接给他'/0'.
* 既然在构造函数中使用了array new，那么可以直接把析构函数写出来(记得使用array delete).
* 既然构造函数已经写出来了，那么拷贝构造也是差不多的。
* 拷贝赋值是最复杂的：首先要判断是不是自己赋值自己，如果是的话那么就直接返回自己，如果不是的话，那么就要首先把自己内容按除掉（使用array delete）然后重新array new一份空间，最后和构造函数一样使用strcpy就可以了，记得要返回*this。

`class中的函数都可以直接写上inline，不用考虑是否复杂而无法inline，编译器会自己判断` 
# 类模板，函数模板，及其他
## 进一步补充：static
* 当没有static时：
一个函数可以作用多个non-static对象，靠的是this-point指针。
```cpp
cout <<c1.real();//c1存在于stack中。
---相当于
cout << complex::real(&c1);
```
* 当有static时，那么那个东西就是只有一份
静态数据的用处：银行利率之类；
静态函数的用处：只能处理静态数据，没有this-point
> 注意：在类中的static是声明，此时还没有获得内存，在main外部时的设置初值时‘定义’，因为这个时候才获得内存。

 静态数据调用静态函数时不会调用this-point
 

## 进一步补充：把ctors放在private区
```cpp
class A{
public:    
    static A& getinstance();
    setup(){...};
private:
    A();
    A(const A& rhs);
    ...
};
A& A::getinstance()
{
    static A a;
    return a;
}
//这样，如果没有人使用则不会出现，即使有了，也只会有一份数据。    

```

## 进一步补充：cout
> cout 可以显示俺么多的数据是因为在class ostream : virtual public ios中把所有数据都重载了<<符号。

## 进一步补充：class template,类模板
```cpp
template<typename T>
class complex
//class head
{
//class body
public:
    complex (double r=0,double i=0):re(r),im(i){}
    complex& operator +=(const complex&);
    double real() const {return re;}
    double imag() const {return im;}
private:
    T re,im;
    
    friend complex& __doapl (complex*, const complex&);
}

{
    complex<double> c1(2.5,1.5);
    complex<int> c2(2,6);
    ...
}
//会生成两份只有T不同的代码
```

## 进一步补充：function template，函数模板
```cpp
template <class T>
//注意这里的class和typename是相通的。
inline 
const T& min(const T& a, const T& b)
{
return b < a? b:1;
}
//这里编译器会根据T的类型，自动使用T::operator<,如果没有定义会报错。

stone r1(2,3),r2(3,3),r3
r3=min(r1,r2);
//编译器函数模板进行实参推导，自动使用正确的类型，不用特意指出。
```

## 进一步补充:namespace
```cpp
namespace std
{
...
}
```
如何使用：

1. using namespacestd;
2. using std:cout;
使用后就可以直接cout<<
# 组合和继承
* Inheritance 继承
* Composition 复合
* Deegation 委托

`继承和复合的结构差不多，继承是derived object包含Base part，他们的构造都是由内而外，而析构是由外而内。`
## Composition 复合 表示 has-a
```cpp
template <class T, class Sequence =deque<T> >
class quene{
    ...
protected:
    Sequence c;
    ...
//表示我这个类有一个这种东西
```
c的结构也可以放一个结构，这是早就存在的概念
有一个强大的class，那么就可以只是改个名字就变成另一个类。
> Container object包含Component part
构造是由内而外，而析构由外而内


## Delegation 委托 Composition by reference
和复合不一样的是他的拥有使用的是指针
```cpp
class StringRep;
class String{
public:
    ...
private:
    StringRep* a;
    ...
```
这样的话Strig相当于接口，所有的功能都由StringRep实现。
这样的话StringRep怎么变，String都不会变

## Inheritance 继承 is-a
```cpp
struct List{
...
}
struct _List:public List
{
}
```
继承有三种状态 public（is-a) protected private

* public(最重要的):
在C++中，public继承意味着基类的public和protected成员在派生类中保持其原有的访问级别，但是基类的private成员在派生类中是不可访问的。也就是说，基类的private成员不会变成public，它们在派生类中仍然是private的，不能被派生类直接访问。这是为了保护数据的封装性。
* protected:
Protected 继承：基类的public和protected成员在派生类中都变为protected，而private成员仍然是不可访问的。
* private:
Private 继承：基类的所有public和protected成员在派生类中都变为private，而private成员仍然是不可访问的。



`注意：如果一个类有可能成为父类，那么他的析构函数一定要用virtual函数 `
# 虚函数和多态
* non-virtual不希望被重写(override)
* virtual 希望重写且已有默认定义（加上virtual即可）
* pure virtual 函数 一定要重写，且没有默认定义（函数前加virtual ,后面加上=0)

使用子类的对象来使用父类的函数是很正常的
一般是在一个框架中使用虚函数。

一个类中继承和组合是可以一起拥有的
</br>
最强大的是委托加继承
```cpp
class Subject
{
    int m_value;
    vetor<Observer*> m_views;
    //默认情况下为private
piblic:
    void attach(Observer* obs)
    {
        m_views.push_back(obs);
    }
    void set_val(int value)
    {
        m_value =value;
        notify();
    }
    void notify()
    {
        for (int i=0;i<m_views.size();++i)
            m_viewsi]->update(this,m_value);
    }
};

class Observer
{
public: 
    virtual void update(Subject* sub,int value)=0;
};
    
```
# 委托相关设计
##  委托加继承
### Composite
现在我想创建一个file system
首先创建一个类代表file容器的class-primitive
```cpp
class Primitive:public Component
{
public:
    Primitive(int val):Component(val){}
}
```
另外也有另一种容器Composite
```cpp
class Composite:public Component
{
    vector<Component*>c;
public:
    Composite(int val):Component(val){}
    
    void add(Component* elem){
    c.push_back(elem);
    }
    ...
};
```
他们拥有同一个父类Component
```cpp
class Component
{
    int value;
public:
    Component(int val){value=val;}
    virtual void add(Component*){}
...
};
```

Composite模式的主要用途是允许你以统一的方式处理单个对象和对象的组合。这意味着你可以使用相同的代码来处理单个对象和对象的组合，无需担心它们是单个对象还是组合。

Composite模式解决的核心问题是如何以一种通用的方式处理对象和对象的组合，而无需在代码中区分它们。这使得代码更加简洁，更易于理解和维护。

例如，如果你正在编写一个图形编辑器，你可能有多种不同类型的图形对象，如圆形、矩形和线条。每个对象都有自己的绘制方法。但是，你可能也想要创建一个组合对象，比如一个由多个图形组成的图形。在这种情况下，你可以使用Composite模式，使得你可以用同样的方式处理单个图形和图形的组合。
> 假设你正在编写一个图形编辑器，你可能有多种不同类型的图形对象，如圆形、矩形和线条。每个对象都有自己的绘制方法。例如：
```cpp
class Circle {
public:
    void draw() {
        // 绘制圆形的代码
    }
};

class Rectangle {
public:
    void draw() {
        // 绘制矩形的代码
    }
};

class Line {
public:
    void draw() {
        // 绘制线条的代码
    }
};

//但是，你可能也想要创建一个组合对象，比如一个由多个图形组成的图形。在这种情况下，你可以使用Composite模式。首先，你需要创建一个基类或接口，它定义了所有图形对象的公共接口：

class Graphic {
public:
    virtual void draw() = 0;  // 纯虚函数
};

然后，你的每个具体的图形类（如Circle、Rectangle和Line）都会实现这个接口：

class Circle : public Graphic {
public:
    void draw() override {
        // 绘制圆形的代码
    }
};

// Rectangle和Line类的实现类似

接下来，你可以创建一个Composite类，它也实现了Graphic接口，但是它包含了一个Graphic对象的列表，并且它的draw方法会调用列表中每个对象的draw方法：

class CompositeGraphic : public Graphic {
private:
    std::vector<Graphic*> graphics;
public:
    void draw() override {
        for (Graphic* graphic : graphics) {
            graphic->draw();
        }
    }

    void add(Graphic* graphic) {
        graphics.push_back(graphic);
    }

    // 还可以添加remove和get等方法
};

现在，你可以用同样的方式处理单个图形和图形的组合。例如，你可以创建一个CompositeGraphic对象，向其中添加多个图形，然后像处理单个图形一样处理它：

CompositeGraphic graphics;
graphics.add(new Circle());
graphics.add(new Rectangle());
graphics.draw();  // 这将绘制所有的图形
//graphics.add(new Circle());这行代码的意思是创建一个新的Circle对象，并将其添加到CompositeGraphic对象graphics中。同样，graphics.add(new Rectangle());也是创建一个新的Rectangle对象，并将其添加到graphics中。

//这样，graphics就包含了一个Circle对象和一个Rectangle对象。当你调用graphics.draw();时，它会调用CompositeGraphic对象中每个图形对象的draw()方法，也就是说，它会先调用Circle对象的draw()方法，然后调用Rectangle对象的draw()方法。
```
### prototype
* 创建未来才出现的对象，不知道classname
解决方法：子类需要创建一个静态的自己，这时会调用设定为私有的构造函数，并把这个个体挂到父类上，每个子类都要有一个clone 用来return new LandSatImages。这时候还要有一个不是public的构造函数用来与将类名传给父类的构造函数进行区别。
> Prototype模式可以简化创建对象的过程，特别是当对象的创建成本较高或复杂性较大时。以下是一些具体的应用场景：
复杂对象的创建：如果一个对象的创建过程需要大量的计算或者需要访问数据库等资源，那么直接克隆一个已经存在的对象会更加高效。
动态加载或运行时添加新的产品：如果你的系统需要在运行时动态地添加新的产品或处理新的对象，那么Prototype模式可以让你将新的产品或对象添加到系统中，而无需修改已有的代码。
保持对象的状态：如果你想创建一个和当前对象状态相同的新对象，那么Prototype模式可以帮助你复制原有对象的状态，而无需通过编程来显式地设置新对象的状态。
在分布式系统中复制对象：在分布式系统中，如果一个对象需要在多个处理器之间共享，那么通过发送该对象的副本而不是引用，可以避免同步和锁定的问题。
总的来说，Prototype模式可以简化对象的创建，提高代码的灵活性，并有助于提高系统的性能。
```cpp
//Prototype（原型）模式是一种创建型设计模式，它在C++中的应用主要是通过复制或克隆现有对象来创建新对象，而不是从头开始创建，这样可以节省时间和资源。

//在C++中，你可以使用各种技术实现Prototype模式，例如复制构造函数或克隆方法以下是一个简单的实现步骤：

//定义一个抽象基类：我们首先定义一个抽象基类，如Shape，它作为所有几何形状的原型。它声明了两个重要的虚函数：clone()和draw()1。
class Shape {
public:
    virtual Shape* clone() const = 0; // 克隆方法，用于创建副本
    virtual void draw() const = 0; // 绘制方法，用于渲染形状
    virtual ~Shape() {} // 虚析构函数，用于适当的清理
};

//创建具体的原型类：现在，我们定义从我们的抽象基类继承的具体类（可以实例化的类），如Circle和Rectangle。这些类为各自的形状实现了clone()和draw()方法。
class Circle : public Shape {
private:
    double radius;
public:
    Circle(double r) : radius(r) {}
    // 实现clone和draw方法
};

// Rectangle类的实现类似

//创建新对象：客户端代码负责通过克隆现有的原型来创建新对象。而不是直接使用new关键字创建对象，客户端请求原型克隆自身。
Circle* original = new Circle(1.0);
Circle* copy = original->clone(); // 创建一个新的Circle对象，它是原始对象的副本
```
# 转换函数-coversion function
```cpp
class Fraction{
public:
    Fraction(...){}
    operator double() const {
        return (double)(...);
    }
private:
    ...
};
```
> 转换函数不需要返回返回的类型，一般来说只是转换，不应该改变原来的东西，所以要记得加上const。

```cpp
Fraction f(3,5);
double d=4+f;
//首先会去找一个double.operator+(Fraction)，但是没有找到。那么就去找operator double()将f转换。
```
# non-explicit-one-argument ctor
数学上认为3就是3/1，所以可以在构造函数中设置一个默认值，这样就变成了：
```cpp
class Fraction
{
public:
    Fraction(int num ,int den=1):m_num...(num),m_...(den){}
    Fraction operator+(const Fraction& f){
        return Fraction(...);
    }
    ...
};
```
这样的构造函数就是non-explicit-one-argument ctor即：只要一个实参就够了同时没有explicit（不能自动转换 ）
`转换函数是把自己转换成其他的东西，但是explicit是把别人转换成自己`
但是当一个类有多个构造函数，并且其中一个构造函数是非显式的（即没有使用 explicit 关键字进行声明），而另一个构造函数是转换构造函数时，可能会导致二义性问题。
# pointer-like classes,关于智能指针
`pointer-like classes-一个像指针的类，设计出来作为智能针。`
设计出来后，要满足指针的基本功能：

*   *和->

例：
```cpp
template<class T>
class shared_ptr
{
public:
    T& operator*() const
    {   return *px;}
    
    T* operator->() const
    {   return px;}
//这两个符号一定是这个写法  
    shared_ptr(T* p):px(p){}

private:
    T* px;
    long*pn;
    ...
};

//使用时  sp->method();  会变成px->method()
```
` 注意：->这个符号比较特殊，虽然在sp->中->被消耗了，但是就是可以一直作用下去，这是c++特性。   `

## 迭代器
相当于各种库中的智能指针，但要注意，迭代器需要遍历整个容器，所以需要重载++--等符号

迭代器中使用*，就是想要获得data
->和上面的用途差不多 
所以
```cpp
reference operator *()const
{return (*node).data;}

pointer operator-> ()const
{return &(operator*());}
```
# function-like classes 仿函数
例子：
```cpp
template <class T>
struct identity{
    const T&
    operator()(const T& x) const {return x;}
};
//使用的时候需要identity()(x);

```
` 注意，这里的两个括号意义不同，第一个的意思是创建一个临时对象，第二个才是调用，一般在使用的时候会先构造一个对象出来在使用`
这种class创造出来的对象称为函数对象或者仿函数
<br/>
标准库中，仿函数会使用奇特的base classes
# namespace经验谈
> 程序名很容易重复，测试时更是如此，将每个函数放入不同的namespcace放入不同的命名空间中，使用时使用::就可以了
# class template 类模板
```cpp
template<typename T>
class complex
//class head
{
//class body
public:
    complex (double r=0,double i=0):re(r),im(i){}
    complex& operator +=(const complex&);
    double real() const {return re;}
    double imag() const {return im;}
private:
    T re,im;
    friend complex& __doapl (complex*, const complex&);
}
{
    complex<double> c1(2.5,1.5);
    complex<int> c2(2,6);
    ...
}
//会生成两份只有T不同的代码
```
# function template 函数模板
```cpp
template <calss T>
inline
const T& min (const T&a, const T&b)
{
    return b< a?b:a;
}

stone r1...,r2...,r3;
r3=min(r1,r2);

```
> 当使用时会进行实参推导，这里会调用stone::operator<

# member template 成员模板
模板中的模板就是成员模板
```cpp
template<class T1,class T2>
stryct{
template<class U1,class U2>
...
}
```
作用是什么呢？
```cpp
class Base1{};
class Derived1:public Base1{};

class Base2{};
class Derived2:public Base2{};
//现在有两个基类，也有两个扩展出来的子类

pair <Derived1,Derived2>p;
pair<Base1,Base2>p2(p);

//->pair<Base1,Base2>p2(pair<Derived1,Derived2>());
//上面调用时相当于创建一个临时对象
//现在想要将两个子类分别拷贝进他们的父类，可以吗，反过来呢？（不能想着我少他多肯定能放进去，这里的思维是父类有的子类一定有，所以父类的肯定都会有初值，但是父类拷贝进子类时可能会有子类有但是父类没有的东西，导致没有初值可以赋给子类）
//理论上子类可以用来初始化父类，因为子类是可以隐式转化成父类的，那么如何实现呢。
template <class T1,class T2>
struct pair{
...
T1 first;
T2 second;
pair():first(T1()),second(T2()){}
pair(const T1&a,const T2&b):first(a),second(b){}

template<class U1,class U2>
pair(const pair<U1,U2>&p):first(p.first),second(p.second){}
};
//pair 中的 first(p.first)是将一个对象的值拷贝构造给另一个对象，注意这里的 first 是T1的对象，这里相当于是把U1类型的对象拷贝构造给T1的对象，这里看似实现了父类和子类的互换，但是拷贝构造时只有子类对象可以隐式转化成父类对象，所以如果将parentPair用来拷贝构造childPair是会出现错误的。因此，这里实现的仅仅是将子类拷贝构造成父类！
}
```
这里是两个class所以才需要使用对象first，只有一个typename的话就可以直接用构造函数了。比如：
```cpp
template<typename _Tp>
class shared_ptr: public __shared_ptr<_Tp>
{
...
    template<typename _Tp1>
    explicit shared_ptr(_Tp1* __p):__shared_ptr<_Tp>(__p){}
...
};

//这样的话就可以让智能指针（指向子类）用来构造另一个智能指针（指向父类）

Base1* ptr=new child;
shared_ptr<parent>sptr(new child);
```
# specialization 模板特化
```cpp
template <class Key>
struct hash{};
//这是一个泛化的例子
template<>
struct hash<char>{
	size_t operator()(char x) const {return x;}
};
//相当于对特定的类型运用特定的定义
//cout<<hash<char>()(1000);
//这里是先创建一个临时对象再传参数
```
# partial specialization 模板偏特化
## 偏－－个数上的偏
```cpp
template<typename T,typename Alloc=...>
class vector
{
...
};
template<typename Alloc=...>
class vector<bool,alloc>
{
...
};
//将T绑定为bool

```
## 偏－－范围上的偏
```cpp
template<typename T>
class C{...};

template<typename T>
class C<T*>{...};

//分别的使用如下
C<string> obj1;
C<string*>obj2;
```
# template template paremeter 模板模板参数
```cpp
template<typename T,
			template <typename T>
				class Container
		>
class XCls
{
private:
	container<T> c;
public:
	...
	//XCls :sp(new T){}
};

//这里的template<tyoename T> class Container是一个模板，相当于可以把第一个参数传入第二个模板中，注意这里不能使用容器，因为容器可能需要多个参数，但是这里语法就是不能赋默认值
//如何使用？
XCls<string,shared_ptr>p1;
```
> 这不是模板参数
```cpp
template <class T,class Sequence=deque<T>>
class stack {
	friend bool operator==<> (const stack&,const stack&);
	friend bool operator< <> (const stack&,const stack&);
protected: 
	Sequence c；
...
};

//这个模板在使用时第二个的参数T并不是第一个参数T，即

stack<int>s1;//可以
stack<int,list<int>>s2;//也可以
```
# 关于c++标准库
* 仿函数->算法-迭代器->容器

算法加容器就是函数

# c++2.0的三个主题
## variadic templates 数量不定的模板参数
```cpp
void print(){}

template<typename T,typename... Types>
void print(const T& firstArg,const Types&... args)
{
    cout << firstArg<<endl;
    print(args...);
}
//...就是一个所谓的pack（包）
```
上方函数会递归使用自己，当参数到0个时，它会调用最上面函数，然后结束
当你想知道现在args还有几个的话可以使用
> sizeof...(args)

## auto
```cpp
list<string> c;
...
list<string>::iterator ite;
ite = find(c.begin(),c.end(),target);
//在过去需要将迭代器ite完整定义，但现在只需要auto就可以了
auto ite = find(c.begin(),c.end(),target);//注意这里不能将auto和=分开
```
auto是一个语法糖

## ranged-base for
```cpp
for(decl:coll){
statement
}
```
coll是一个容器
```cpp
vector<double> vec;
...
for (auto elem :vec){
    cout<<elem<<endl;
}
//如果想要改变数值，那么需要pass by reference
for (auto & elem :vec){
    elem*=3;
}
```
# reference
```cpp
int x=0;
int* p=&x;
int& r=x;
int x2=5;

r=x2;//这里不能代表其他物体，只能改变自己的值
int& r2=r;
```
object和其reference的大小相同，地址也相同。
java中的变量都是reference.
reference就是使用指针实现的
```cpp
void func(Cls obg){obj.xxx();}
void func2(Cls& obj){obj.xxx();}
//被调用端写法相同，很好
```
注意，引用实际上既然就代表另一个东西，那么在同名函数中不能只是在重载时只是改变参数是否引用。
const和reference不同，const算是函数的一部分，存不存在是两个函数

# 复合&继承关系下的构造和析构
这节是复习课，直接去c++面向对象高级编程（上）里面复习即可。
#  关于vptr和vtbl（虚指针和虚表）
> 只要有虚函数，就一定会有虚指针，所以类在有虚函数时，会看起来多4字节。

虚指针会指向一个虚表，虚表中保存着所有的虚函数
当重载虚函数后，那么这个虚函数就和父类中的虚函数不是同一个了，但是如果没有重载，只是单纯的继承的话，则各类虚表指向的虚函数是同一个，当不是虚函数时，那么各自的函数即使同名也很明显的不是同一个函数了
<br>
虚指针和虚表的关系相当于：
> (*(p->vptr)[n])(p);或者(*p->vptr[n])(p);

在保存不同内存大小的容器中，可以将将容器保存指向父类的指针即可。
在遍历这个容器时，如果是虚函数的话，那么每个子类都可以使用自己的函数。

> 资料：
1 成员函数重载特征：
* a 相同的范围（在同一个类中）
* b 函数名字相同
* c 参数不同
* d virtual关键字可有可无
2 重写（覆盖)是指派生类函数覆盖基类函数，特征是：
* a 不同的范围，分别位于基类和派生类中
* b 函数的名字相同
* c 参数相同
* d 基类函数必须有virtual关键字
3 重定义(隐藏)是指派生类的函数屏蔽了与其同名的基类函数，规则如下：
* a 如果派生类的函数和基类的函数同名，但是参数不同，此时，不管有无virtual，基类的函数被隐藏。
* b 如果派生类的函数与基类的函数同名，并且参数也相同，但是基类函数没有vitual关键字，此时，基类的函数被隐藏。
# 谈谈const
const 如果放在成员函数后面则表示我的意图是不会改数据。
那么const object就不能调用non-const member function。
注意函数的签名要算上const。
string使用basic_string就使用了有无const的函数重载，因为string字符串是共享的，但是几个人一起共享时也有可能会改变，所以必须考虑copy on write。
当成员函数的const和non-const版本同时存在时，const object只会调用const版本，non-const object只会调用non-const 版本
# 关于this
```cpp
CDocument::OnFileOpen(){
...
Serialize();
...
}
virtual Serialise();

class CmyDoc:public CDocument{
virtual Serialize(){...}
};


CMyDoc myDoc;
myDoc.OnFileOpen();
//第二行相当于CDcument::OnFileOpen(&myDoc);
//这里的&mydoc就是this-point
```
# 关于Dynamic Binding
调用动态绑定的三个条件：
1. 使用指针调用
2. 使用虚函数
3. 使用向上转型

详细注解：
首先，动态绑定发生的条件，这是本文的核心问题，记住这个问题就可以万变不离其宗了：在C++中，当我们使用基类的引用或指针调用一个虚函数是将发生动态绑定。几个关键词是基类，指针或引用，虚函数。记住这句话再分析几个实际问题就会明白了。

其次是动态绑定的原因：静态类型和动态类型不同。静态类型是变量声明时的类型，在这里就是基类的类型，动态类型是变量内存中的对象类型。例如把基类指针变量赋值为派生类指针的值，就会发生静态类型与动态类型不同的情况。

所以综上可知，发生动态类型的必要条件是基类指针或引用（静态类型），被赋值为派生类的指针或引用（动态类型），且调用了虚函数。

以下是在继承体系中的常见问题

（1）C++11新标准允许派生类显示的注明那个函数改写了基类的虚函数，具有做法是在该函数的形参列表之后增加override关键字。

（2）关键字virtual只能出现在类的内部的声明语句中儿不能出现在类外部函数定义中。

（3）虚函数的解析过程发生在运行阶段，普通成员函数发生在编译过程。

（4）基类中的静态成员函数在整个继承体系中也具有唯一性。

（5）C++11中提供了一种防止被继承的方法，在类名后面加上关键字final。

（6）表达式既不是引用也不是指针，则它的动态类型永远和静态类型一致。

（7）不存在从基类向派生类的隐式转换。

（8）可以将基类的基类的指针和引用绑定到派生类对象上（基类部分）。
# 关于new，delete
new:先分配memory,再调用ctor
delete:先调用dtor，再释放memory
array new一定要搭配array delete
new 编译器会转化：
```cpp
String*ps =new String("hello");

String* ps;
void* mem=operator new(sizeof(object));
ps=static_cast<String*>(mem);
ps->String::String("Hello");
```
delete编译器也会转化：
```cpp
delete obj; //编译器转化为下面的过程 
object::~object(obj); //析构函数 
operator delete(obj); //释放内存，内部调用free(obj)函数
```
注意 new和delete不能被重载，但是他们调用的operator new 和operator delete可以被重载。

注解：
人们有时好像喜欢有益使C++语言的术语难以理解。比方说new操作符（new operator）和operator new的差别。 

当你写这种代码：

string *ps = new string("Memory Management");
你使用的new是new操作符。

 

这个操作符就象sizeof一样是语言内置的。你不能改变它的含义，它的功能总是一样的。它要完毕的功能分成两部分。第一部分是分配足够的内存以便容纳所需类型的对象。

第二部分是它调用构造函数初始化内存中的对象。new操作符总是做这两件事情，你不能以不论什么方式改变它的行为。
（总结就是，new操作符做两件事，分配内存+调用构造函数初始化。

你不能改变它的行为。）
# operator new 和operator delete的重载
```cpp
void* myAlloc(size_t size)
{return malloc(size);}

void myFree(void* ptr)
{return free(ptr);}

inline void* operator new [](size_t size)
{cout<<"jjhou global new[]() \n";return myAlloc(size);}
inline void operator delete[](void* ptr)
{cout<<"jjhou global delete[]()\n" myfree (ptr);}
```
当然你也可以在成员函数中重载operator new

# 示例，接口
如果使用 ::new Foo;或者::delete pf.可以绕过自己写的overloaded function
# 重载new（），delete（）实例
operator new()的重载第一个参数一定是size_t,其余参数以new所指定的placement arguments为初值。
我们也可以重载class member operator delete(),但他们绝不会被delete调用，只有当new抛出exception，才会调用重载版本的operator delete
所以即使delete没有一一对应，也不会报错，相当于你放弃处理的意思。
# basic_string使用new(extra)扩充申请量
basic_string在申请时会申请Rep和extra内容，它的作用就是悄无声息的扩充自己的占用量