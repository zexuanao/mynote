#### 一、基础议题

**1. 区分指针和引用**

引用必须指向一个对象，而不是空值，下面是一个危险的例子：
    
    char* pc = 0;  //设置指针为空值
    char& rc = *pc;//让引用指向空值，很危险！！！

下面的情况下使用指针：
+ 存在不指向任何对象的可能
+ 需要能够在不同的时刻指向不同的对象
其他情况应该使用引用

**2. 优先考虑C++风格的类型转换**

上本书说过了，第27条

**3. 决不要把多态用于数组**

主要是考虑以下写法：
    
    class BST{...}
    class BalancedBST : public BST{...}
    
    void printBSTArray(const BST array[]){
        for(auto i : array){
            std::cout << *i;
        }
    }
    
    BalancedBST bBSTArray[10];
    printBSTArray(bBSTArray);

由于我们之前说的，这种情况下编译器是毫无警告的，而对象在传递过程中是按照声明的大小来传递的，所以每一个元素的间隔是sizeof(BST)此时指针就指向了错误的地方

**4. 避免不必要的默认构造函数**

这里主要是为了防止出现有了对象但是却没有必要的数据，例如：没有id的人
但是主要还是在关键词 *不必要* 上面，必要的默认构造函数，不会造成数据出现遗漏的话，还是可以用的
当然，如果不提供缺省构造函数的话，例如：
    
    class EP{
    public:
        EP(int ID);
    }

这样的代码会让使用者在某些时候非常的难受，特别是当EP类是虚类的时候。

这时可以通过让用户使用

    EP bestP[] = {
        EP(ID1),
        EP(ID2),
        ......
    }
函数数组的方法，或者是指针：
    
    typedef EP* PEP;
    PEP bestPieces[10];
    PEP *bestPieces = new PEP[10];然后使用的时候再重新new来进行初始化

#### 二、运算符

**5. 小心用户自定义的转换函数**

因为可能会出现一些无法理解的并且也是无能为力的运算，而且在不需要这些类型转换函数的时候，仍然可能会调用这些转换，例如下面的代码：
    
    // 有理数类
    class Rational{
    public:
        Rational(int numerator = 0, int denominator = 1)
        operator double() const;
    }
    
    Rational r(1, 2);
    double d = 0.5 * r; //将r转换成了double进行计算
    
    cout << r; //会调用最接近的类型转换函数double，将r转换成double打印出来，而不是想要的1/2，

上面问题的解决方法是，把double变成
    
    double asDouble() const;这样就可以直接用了

但是即使这样做还有可能会出现隐式转换的现象：
    
    template<class T>
    class Array{
    public:
        Array(int size);
        T& operator[](int index);
    };
    
    bool operator==(const Array<int> &lhs, const Array<int> & rhs);
    Array<int> a(10), b(10);
    if(a == b[3]) //想要写 a[3] == b[3]，但是这时候编译器并不会报错，解决方法是使用explicit关键字
    
    explicit Array(int size); 
    if(a == b[3]) // 错误，无法进行隐式转换

其实还有一种很骚的操作：

    class Array { 
    public:  
        class ArraySize {                    // 这个类是新的 
            public: 
            ArraySize(int numElements):theSize(numElements){}
            int size() const { return theSize;}
        private: 
            int theSize;
        };
        Array(int lowBound, int highBound); 
        Array(ArraySize size);                  // 注意新的声明
        ... 
    }; 

这样写的代码在Array<int> a(10);的时候，编译器会先通过类型转换转换成ArraySize，然后再进行构造，虽然麻烦很多，效率也低了很多，但是在一定程度上可以避免隐式转换带来的问题

**6. 区分自增运算符和自减运算符的前缀形式与后缀形式**

这一点主要是要知道前缀和后缀的重载形式是不同的，以及重载的时候不要进行连续重载例如i++++;
因为连续的+号会导致创建很多临时对象，效率会变低

**7. 不要重载"&&"、"||"和","**

主要是因为上面三个符号，大部分的程序员都已经达成共识，先运算前面的一串表达式，再判断后面的一串表达式：
if(expression1 && expression2){} 就会先运算第一个表达式，然后再运算第二个表达式

比较特殊的是逗号操作符：“,“，例如最常见的for循环：
    
    for(int i = 0, j = strlen(s)-1; i < j; i++, j--){}

在这个for循环里面，因为最后一个部分职能使用一个表达式，分开表达式来改变i和j的值是不合法的，用逗号表达式就会先计算出来左边的i++，然后计算出逗号右边的j--

**8. 理解new和delete在不同情形下的含义**

两种new: new 操作符（new operator）和new操作（operator new）的区别

    string *ps = new string("Memory Management"); //使用的是new操作符，这个操作符像sizeof一样是内置的，无法改变
    
    void* operator new(size_t size); // new操作，可以重写这个函数来改变如何分配内存

一般不会直接调用operator new，但是可以像调用其他函数一样调用他：

    void* rawMemory = operator new(sizeof(String));

placement new : placement new 是有一些已经被分配但是没有被处理的内存，需要在这个内存里面构造一个对象，使用placement new 可以实现这个需求，实现方法：
    
    class Widget{
        public:
            Widget(int widgetSize);
        ....
    };
    
    Widget* constructWidgetInBuffer(void *buffer, int widgetSize){
        return new(buffer) Widget(widgetSize);
    }

这样就返回一个指针，指向一个Widget对象，对象在传递给函数的buffer里面分配

同样的道理：
    delete buffer; //指的是先调用buffer的析构函数，然后再释放内存
    operator delete(buffer); //指的是只释放内存，但是不调用析构函数

而placement new 出来的内存，就不应该直接使用delete操作符，因为delete操作符使用operator delete来释放内存，但是包含对象的内存最初不是被operator new分配的，而应该显示调用析构函数来消除构造函数的影响

new[]和delete[]就相当于对每一个数组元素调用构造和析构函数

#### 三、异常

**9. 使用析构函数防止资源泄漏**

原代码：
    
    void processAdoptions(istream& dataSource){
        while(dataSource){
            ALA *pa = readALA(dataSource);
        }
        try{
            pa->processAdoption();
        }
        catch(...){
            delete pa; //在抛出异常的时候避免泄露
            throw;
        }
        delete pa;     //在不抛出异常的时候避免泄露
    }

因为这种情况会需要删除两次pa，代码维护很麻烦，所以需要进行优化：

template<class T>
class auto_ptr{
public:
    auto_ptr(T *p=0):ptr(p){} //保存ptr，指向对象
    ~auto_ptr(){delete prt;}
private:
    T *ptr;    
}

void processAdoptions(istream& dataSource){
    while(dataSource){
        auto_ptr<ALA> pa(readALA(dataSource));
        pa->processAdoption();
    }
}

auto_ptr后面隐藏的思想是：使用一个对象来存储需要被自动释放的资源，然后依靠对象的析构函数来释放资源。
事实上WindowHandle就是这样一个东西

那么这样就引出一个非常重要的规则：资源应该被封装在一个对象里面

**10. 防止构造函数里的资源泄漏**

这一条主要是防止在构造函数中出现异常导致资源泄露：
    
    BookEntry::BookEntry(){
        theImage     = new Image(imageFileName);
        theAudioClip = new AudioClip(audioClipFileName);
    }
    BookEntry::~BookEntry(){
        delete theImage;
    }

如果在构造函数new AudioClip里面出现异常的话，那么~BookEntry析构函数就不会执行，那么NewImage就永远不会被删除，而且因为new BookEntry失败，导致delete BookEntry也无法释放theImage，那么只能在构造函数里面使用异常来避免这个问题
    
    BookEntry::BookEntry(){
        try{
            theImage     = new Image(imageFileName);
            theAudioClip = new AudioClip(audioClipFileName);
        }
        catch(...){
            delete theImage;
            delete theAudioClip;
            //上面一段代码和析构函数里面的一样，所以可以直接封装成一个成员函数cleanup：
            cleanup();
            throw;
        }
    }

更好的做法是将theImage和theAudioClip做成成员来进行封装：
    
    class BookEntry{
    public:......
    private:
        const auto_ptr<Image> theImage;
        const auto_ptr<AudioClip> theAudioClip;
    }


**11. 阻止异常传递到析构函数以外**

如果析构函数抛出异常的话，会导致程序直接调用terminate函数，中止程序而不释放对象，所以不应该让异常传递到析构函数外面，而是应该在析构函数里面直接catch并且处理掉

另外，如果析构函数抛出异常的话，那么析构函数就不会完全运行，就无法完成希望做的一些其他事情例如：
    
    Session::~Session(){
        logDestruction(this);
        endTransaction(); //结束database transaction,如果上面一句失败的话，下面这句就没办法正确执行了
    }

**12. 理解“抛出异常”，“传递参数”和“调用虚函数”之间的不同**

传递参数的函数：

    void f1(Widget w);
catch子句：    

    catch(widget w)... 

上面两行代码的相同点：传递函数参数与异常的途径可以是传值、传递引用或者传递指针

上面两行代码的不同点：系统所需要完成操作的过程是完全不同的。调用函数时程序的控制权还会返回到函数的调用处，但是抛出一个异常时，控制权永远都不会回到抛出异常的地方
三种捕获异常的方法：
    
    catch(Widget w);
    catch(Widget& w);
    catch(const Widget& w);

一个被抛出的对象可以通过普通的引用捕获，它不需要通过指向const对象的引用捕获，但是在函数调用中不允许传递一个临时对象到一个非const引用类型的参数里面
同时异常抛出的时候实际上是抛出对象创建的临时对象的拷贝，

另外一个区别就是在try语句块里面，抛出的异常不会进行类型转换（除了继承类和基类之间的类型转换，和类型化指针转变成无类型指针的变换），例如：
    
    void f(int value){
        try{
            throw value; //value可以是int也可以是double等其他类型的值
        }
        catch(double d){
            ....         //这里只处理double类型的异常，如果遇到int或者其他类型的异常则不予理会
        }
    }

最后一个区别就是，异常catch的时候是按照顺序来的，即如果两个catch并且存在的话，会优先进入到第一个catch里面，但是函数则是匹配最优的

**13. 通过引用捕获异常**

使用指针方式捕获异常：不需要拷贝对象，是最快的,但是，程序员很容易忘记写static，如果忘记写static的话，会导致异常在抛出后，因为离开了作用域而失效：
    
    void someFunction(){
        static exception ex;
        throw &ex;
    }
    void doSomething(){
        try{
            someFunction();
        }
        catch(exception *ex){...}
    }
创建堆对象抛出异常：new exception 不会出现异常失效的问题，但是会出现在捕捉以后是否应该删除他们接受的指针，在哪一个层级删除指针的问题
通过值捕获异常：不会出现上述问题，但是会在被抛出时系统将异常对象拷贝两次，而且会出现派生类和基类的slicing problem，即派生类的异常对象被作为基类异常对象捕获时，会把派生类的一部分切掉，例如：
    
    class exception{
    public:
        virtual const char *what() throw();
    };
    class runtime_error : public exception{...};
    void someFunction(){
        if(true){
            throw runtime_error();
        }
    }
    void doSomething(){
        try{
            someFunction();
        }
        catch(exception ex){
            cerr << ex.what(); //这个时候调用的就是基类的what而不是runtime_error里面的what了，而这个并不是我们想要的
        }
    }

通过引用捕获异常：可以避免上面所有的问题，异常对象也只会被拷贝一次：
    
    void someFunction(){...} //和上面一样
    void doSomething(){
        try{...}             //和上面一样
        catch(exception& ex){
            cerr << ex.what(); //这个时候就是调用的runtime_error而不是基类的exception::what()了，其他和上面其实是一样的
        }
    }

**14. 审慎地使用异常规格（exception specifications）**

异常规格指的是函数指定只能抛出异常的类型：
    
    extern void f1();    //f1可以抛出任意类型的异常
    void f2() throw(int);//f2只能抛出int类型的异常
    void f2() throw(int){ 
         f1();           //编译器会因为f1和f2的异常规格不同而在发出异常的时候调用unexpected
    }

在用模板的时候，会让这种情况更为明显：
    
    template<class T>
    bool operator==(const T& lhs, const T&rhs) throw(){
        return &lhs == &rhs;
    }
这个模板为所有的类型定义了一个操作符函数operator==对于任意一对相同类型的对象，如果有一样的地址，则返回true，否则返回false，单单这么一个函数可能不会抛出异常，但是如果有operator&重载时，operator&可能会抛出异常，这样就违反了异常规则，让程序跳转到unexpected

阻止程序跳转到unexpected的三种方法：
将所有的unexpected异常都替换成UnexpectedException对象：
    
    class UnexpectedException{}; //所有的unexpected异常对象都被替换成这种对象
    void convertUnexpected(){       //如果一个unexpected异常被抛出，这个函数就会被调用
        throw UnexpectedException();
    }
    set_unexpected(convertUnexpected);
替换unexpected函数：

    void convertUnexpected(){ //如果一个unexpected异常被抛出，这个函数被调用
        throw;                //只是重新抛出当前的异常
    }
    set_unexpected(convertUnexpected);//安装convertUnexpected作为unexpected的替代品，此方法应该在所有的异常规格里面包含bad_exception

总结：异常规格应该在加入之前谨慎的考虑它带来的行为是否是我们所希望的


**15. 理解异常处理所付出的代价**

编译器带来的开销（很难消除，因为所有的编译器都是支持异常的
try块语句的开销：大概会降低5%-10%的速度和增加相应的代码尺寸

#### 四、效率

**16. 记住80-20准则**

分别有20%的代码耗用了80%的程序资源，运行时间，内存，磁盘，有80%的维护投入到20%的代码上
用profiler工具来对程序进行分析

**17. 考虑使用延迟计算**

一个延迟计算的例子：

    class String{....}
    String s1 = "Hello";
    String s2 = s1;  //在正常的情况下，这一句需要调用new操作符分配堆内存，然后调用strcpy将s1内的数据拷贝到s2里面。但是我们此时s2并没有被使用，所以我们不需要s2，这个时候如果让s2和s1共享一个值，就可以减小这些开销

使用延迟计算进行读操作和写操作：

    String s = "Homer's Iliad";
    cout << s[3];
    s[3] = 'x';
首先调用operator[] 用来读取string的部分值，但是第二次调用该函数式为了完成写操作。读取效率较高，写入因为需要拷贝，所以效率较低，这个时候可以推迟作出是读操作还是写操作的决定。

延迟策略进行数据库操作：有点类似之前写web 的时候，把数据放在内存和数据库两份，更新的时候只更新内存，然后隔一段时间（或者等到使用的时候）去更新数据库。
在effective c++里面，则是更加专业的将这个操作封装成了一个类，然后把是否更新数据库弄成一个flag。以及使用了mutable关键字，来修改数据

延迟表达式：
    
    Matrix<int> m1(1000, 1000), m2(1000, 1000);
    m3 = m1 + m2;
    因为矩阵的加法计算量太大（1000*1000）次计算，所以可以先用表达式表示m3是m1和m2的和，然后真正需要计算出值的时候再真的进行计算（甚至计算的时候也只计算m3[3][2]这样某一个位置的值）

**18. 分期摊还预期的计算开销（提前计算法）**

例如对于max， min函数，如果被频繁调用的话，就可以专门将min和max缓存城一个m_min成员或者mmax成员，这样就在每次调用的时候直接返回就行了，不需要每次调用的时候就重新计算，这个方法叫做cache

prefetching是另一种方法，例如从磁盘读取数据的时候，一次读取一整块或者整个扇区的数据，因为一次读取一大块要比不同时间读取几个小块要快

**19. 了解临时对象的来源**

通常意义的临时对象指的是 temp = a; a = b; b = temp;中的temp
但是在C++中的临时对象指的是那些看不见的东西，例如：

    size_t countChar(const string& str, char ch);
    char buffer[MAX_STRING_LEN];
    cout << countChar(buffer, c);

对于countChar的调用来说，buffer是一个char的数据，但是其形参是const string，那么就需要建立一个string类型的临时对象，然后用buffer作为参数对这个临时对象进行初始化

另外再如operator+重载函数中，函数的返回值是临时的，因为它没有被命名。

所以在任何时候只要见到函数中的常量引用参数，就存在建立临时对象的可能性

**20. 协助编译器实现返回值优化**

一个返回一整个对象的函数，效率是很低的，因为需要调用对象的析构和构造函数。但是有时候编译器会帮助优化我们的实现：
    
    inline const Rational operator*(const Rational& lhs, const Rational& rhs{
        return Rational(lhs.numerator() * rhs.numerator(), lhs.denominator() * rhs.denominator());
    }

上面这个操作实在是太骚了，初看起来好像是会创建一个Rational的临时对象，但是实际上编译器会把这个临时对象给优化掉，所以就免除了析构和构造的开销，而inline还可以减少函数的调用开销

**21. 通过函数重载避免隐式类型转换**

改代码之前：

    class UPInt{
        public:
        UPInt();
        UPInt(int value);
    }
    const UPInt operator+(const UPInt& lhs, const UPInt& rhs);
    upi3 = upi1 + upi2;
    upi3 = 10 + upi1;  // 会产生隐式类型转换，转换过程中会出现临时对象
    upi3 = upi1 + 10;

改代码之后：
    
    const UPInt operator+(const UPInt& lhs, const UPInt& rhs);
    const UPInt operator+(const UPInt& lhs, int rhs);
    const UPInt operator+(int lhs, const UPInt& rhs);

**22. 考虑使用op=来取代单独的op运算符**

operator+ 和operator+=是不一样的，所以如果想要重载+号，就最好重载+=，那么一个比较好的方法就是把+号用+=来实现，当然如果可以的话，可以使用模板编写：
    
    template<class T>
    const T operator+(const T& lhs, const T& rhs)
    {
        return T(lhs) += rhs;
    }
    template<class T>
    const T operator-(const T& lhs, const T& rhs){
        return T(lhs) -= rhs; 
    }


**23. 考虑使用其他等价的程序库**

例如stdio和iostream两个程序库都有输入输出的功能，但是stdio库则速度更快，iostream则写起来更安全。需要合理的选择应用的替代库

**24. 理解虚函数、多重继承、虚基类以及RTTI所带来的开销**

C++的特性和编译器会很大程度上影响程序的效率，所以我们有必要知道编译器在一个C++特性后面做了些什么事情。

例如虚函数，指向对象的指针或者引用的类型是不重要的，大多数编译器使用的是virtual table(vtbl)和virtual table pointers(vptr)来进行实现

vtbl:  

    class C1{
    public:
        C1();
        virtual ~C1();
        virtual void f1();
        virtual int f2(char c)const;
        virtual void f3(const string& s);
        void f4()const
    }

vtbl的虚拟表类似于下面这样,只有虚函数在里面，非虚函数的f4不在里面：

     ___
    |___| → ~C1()
    |___| → f1()
    |___| → f2()
    |___| → f3()

如果按照上面的这种，每一个虚函数都需要一个地址空间的话，那么如果拥有大量虚函数的类，就会需要大量的地址存储这些东西，这个vtbl放在哪里根据编译器的不同而不同

vptr：

     __________
    |__________| → 存放类的数据
    |__________| → 存放vptr

每一个对象都只存储一个指针，但是在对象很小的时候，多于的vptr将会看起来非常占地方。在使用vptr的时候，编译器会先通过vptr找到对应的vtbl，然后通过vtbl开始找到指向的函数
事实上对于函数：
    
    pC1->f1();
他的本质是：

    (*pC1->vptr[i])(pC1);

在使用多继承的时候，vptr会占用很大的地方，并且非常恶心，所以不要用多继承

RTTI：能够让我们在runtime找到对象的类信息，那么就肯定有一个地方存储了这些信息，这个特性也可以使用vtbl实现，把每一个对象，都添加一个隐形的数据成员type_info，来存储这些东西，从而占用很大的空间

#### 五、技巧

**25. 使构造函数和非成员函数具有虚函数的行为**

    class NewsLetter{
    private:
        static NLComponent *readComponent(istream& str);
        virtual NLComponent *clone() const = 0;
    };
    NewsLetter::NewsLetter(istream& str){
        while(str){
            components.push_back(readComponent(str));
        }
    }
    class TextBlock: public NLComponent{
    public:
        virtual TextBlock*clone()const{
            return new TextBlock(*this);
        }
    }
在上面那段代码当中，readComponent就是一个具有构造函数行为（因为能够创建出新的对象）的函数，我们叫做虚拟构造函数

clone() 叫做虚拟拷贝构造函数,相当于拷贝一个新的对象

通过这种方法，我们上面的NewsLetter构造函数就可以这样：

    NewsLetter::NewsLetter(const NewsLetter& rhs){
        while(str){
            for(list<NLComponent*>::const_iterator it=rhs.component.begin(); it!=rhs.component.end();it++){
                components.push_back((*it)->clone());
            }
        }
    }
这样每一个TextBlock都可以调用他自己的clone，其他的子类也可以调用他们自己对应的clone()

**26. 限制类对象的个数**

比如某个类只应该有一个对象，那么最简单的限制这个个数的方法就是把构造函数放在private域里面，这样每个人都没有权力创建对象

或者做一个约束，每次创建的时候都返回static的对象：
    
    class Printer{
    public:
        friend Printer& thePrinter();或者static Printer& thePrinter();
    private:
        Printer();
        Printer(const Printer& rhs);
    };
    Printer& thePrinter(){
        static Printer p;
        return p;
    }
上面这段代码中，Printer类的构造函数是private，可以阻止建立对象，全局函数thePrinter被声明为类的友元，让thePrinter避免私有构造函数引起的限制

创建对象的环境：
当然还有一个直观的方法来限制对象的个数，就是添加一个名为numObjects的static变量，来记录对象的个数，当然这种方法在出现继承的时候会出现问题（一个Printer和一个继承自Printer的colorPrinter同时存在的时候，就会超出numObjects个数，这个时候就需要限制继承

允许对象来去自由：
如果使用伪构造函数的话，会导致对象销毁后，无法创建新的对象，解决方法就是一起使用上面的伪构造函数和计数器。

一个具有对象计数功能的基类：
如果拥有大量像Printer这样的类需要进行计数，那么较好的方法就是一次性封装所有的计数功能,需要确保每个进行实例计数的类都有一个相互隔离的计数器，所以模板会比较好:
    
    template <class BeingCounted>
    class Counted{
    public:
        class TooManyObjects{};
        static int objectCount(){return numObjects;}
    protected:
        Counted();
        Counted(const Counted& rhs);
        ~Counted(){ --numObjects; }
    private:
        static int numObjects;
        static const size_t maxObjects;
        void init();                 //避免构造函数的代码重复
    };
    
    template<class BeingCounted>
    Counted<BeingCounted>::Counted(){init();}
    
    template<class BeingCounted>
    Counted<BeingCounted>::Counted(const Counted<BeingCounted>&){init();}
    
    template<class BeingCounted>
    void Counted<BeingCounted>::init(){
        if(numObjects >= maxObjects)throw TooManyObjects();
        ++numObjects;
    }
    
    class Printer:private Counted<Printer>{
    public:
        static Printer* makePrinter(); // 伪构造函数
        using Counted<Printer>::objectCount;
        using Counted<Printer>::TooManyObjects;
    }
**27. 要求或禁止对象分配在堆上**

必须在堆中建立对象（程序有自我管理对象的需求）：
禁用隐式的构造函数和析构函数，例如声明成private，或者仅仅让析构函数成为private（副作用小一些），然后创建一个public的destory()方法来调用析构。
遇到继承析构的问题的话(现在的做法无法继承)，也可以将析构函数声明成protected的

判断一个对象是否在堆中：
在构造函数中无法区分是否在堆中，但是在new里面可以做些事情：
    
    class UPNumber{
    public:
        class HeapConstraintViolation{};
        static void* operator new(size_t size);
        UPNumber();
    private:
        static bool onTheHeap;
    };
实际上上面这段代码是跑不了的，因为如果使用new[]创造数组的话就没有办法用了

另一种方法是判断变量所在的地址，因为stack是从高位地址向下的，heap是从地位地址向上的：
    
    bool onHeap(const void *address) { 
        char onTheStack; // 局部栈变量，因为他是新的变量，所以比他小的都在堆或者静态空间里面，比他大的都在栈里面
        return address < &onTheStack; 
    }

禁止堆对象：
重写operator new就行了，例如弄成private

**28. 智能(smart)指针**

auto_ptr：会把值给传出去，原来的指针作废掉
实现dereference（取出指针所指东西的内容）：
    template<class T>
    T& SmartPtr<T>::operaotr*()const{
        return *pointee;
    }

    template<class T>
    T* SmartPtr<T>::operator->()const{
        return pointee;
    }

测试smart pointer是否是NULL：
如果直接使用下面的代码是错误的：
    
    SmartPtr<TreeNode> ptn;
    if(ptn == 0)... //error
    if(ptn)... //error
    if(!ptn)... //error
所以需要进行隐式类型转换操作符，才能够进行上面的操作
    
    template<class T>
    class SmartPtr{
    public:
        operator void*();
    };
    SmartPtr<TreeNode> ptn;
    if(ptn == 0) //现在正确
    if(ptn) //现在正确
    if(!ptn) //现在正确

smart pointer 和继承类/基类的类型转换:

    class MusicProduct{....};
    class Cassette:public MusicProduct{....};
    class CD:public MusicProduct{....};
    displayAndPlay(const SmartPtr<MusicProduct>& pmp, int numTimes);
    
    SmartPtr<Cassette> funMusic(new Cassette("1234"));
    SmartPtr<CD> nightmareMusic(new CD("143"));
    displayAndPlay(funMusic, 10); // 错误!
    displayAndPlay(nightmareMusic, 0); // 错误!
我们可以看到的是，如果没有隐式转换操作符的话，是没有办法进行转换的，那么解决方法就是添加一个操作符,：
    
    class SmartPtr<Cassette>{//或者用模板来代替
    public:
        operator SmartPtr<MusicProduct>(){
            return SmartPtr<MusicProduct>(pointee);
        }
    };
smart pointer 和 const：
    
    SmartPtr<CD> p; //non-const 对象 non-const 指针
    SmartPtr<const CD> p; //const 对象 non-const 指针
    const SmartPtr<CD> p = &goodCD; //non-const 对象 const 指针
    const SmartPtr<const CD> p = &goodCD; //const 对象 const 指针
    
    template<class T>      // 指向const对象的
    class SmartPtrToConst{ //灵巧指针
        ...                // 灵巧指针通常的成员函数
    protected:
        union {
            const T* constPointee; // 让 SmartPtrToConst 访问
            T* pointee; // 让 SmartPtr 访问
        };
    };
    
    template<class T> // 指向 non-const 对象的灵巧指针
    class SmartPtr: public SmartPtrToConst<T> {
        ... // 没有数据成员
    };


**29. 引用计数**
就是一个smart pointer，不讨论了
**30. 代理类**

例子：实现二维数组类：
    
    template<class T>
    class Array2D{
    public:
        Array2D(int dim1, int dim2);
        class Array1D{
        public:
            T& operator[](int index);
            const T& operator[](int index) const;
        };
        Array1D operator[](int index);
        const Array1D operator[](int index) const;
    };
    Array2D<int> data(10, 20);
    cout << data[3][6] //这里面的[][]运算符是通过两次重载实现的

例子：代理类区分[]操作符的读写：

采用延迟计算方法，修改operator[]让他返回一个（代理字符的）proxy对象而不是字符对象本身，并且判断之后这个代理字符怎么被使用，从而判断是读还是写操作
    
    class String{
    public:
        class CharProxy{
        public:
            CharProxy(String& str, int index);
            CharProxy& operator=(const CharProxy& rhs);
            CharProxy& operator=(char c);
            operator char() const;
        private:
            String& theString;
            int charIndex;
        };
        const CharProxy operator[](int index) const;//对于const的Strings
        CharProxy operator[](int index);            //对于non-const的Strings
    
        friend class CharProxy;
    private:
        RCPtr<StringValue> value;
    };

**31. 基于多个对象的虚函数**

考虑两个对象碰撞的问题：
    
    class GameObject{....};
    class SpaceShip : public GameObject{....};
    class SpaceStation : public GameObject{....};
    class Asteroid : public GameObject{....};
    
    void checkForCollision(GameObject& object1, GameObject& object2){
        processCollision(object1, object2);
    }

当我们调用processCollision的时候，该函数取决于两个不同的对象，但是这个函数并不知道其object1和object2的真实类型，这个时候就要基于多个对象设计虚函数 

解决方法有很多：
    
使用虚函数+RTTI：

    class GameObject{
    public:
        virtual void collide(GameObject& otherObject) = 0;
    };
    class SpaceShip:public GameObject{
    public:
        virtual void collide(GameObject& otherObject);
    };
    
    void SpaceShip:collide(GameObject& otherObject){
        const type_info& objectType = typeid(otherObject);
        if(objectType == typeid(SpaceShip)){
            SpaceShip& ss = static_cast<SpaceShip&>(otherObject);
        }
        else if(objectType == typeid(SpaceStation)).......
    }
只使用虚函数：
    
    class SpaceShip; // forward declaration
    class SpaceStation;
    class Asteroid;
    class GameObject { 
    public:
        virtual void collide(GameObject&   otherObject) = 0;
        virtual void collide(SpaceShip&    otherObject) = 0;
        virtual void collide(SpaceStation& otherObject) = 0;
        virtual void collide(Asteroid&     otherObject) = 0;
        ...
    };
模拟虚函数表（对继承体系中的函数做一些修改）：

    class SpaceShip : public GameObject { 
    public:
        virtual void collide(GameObject&   otherObject);
        virtual void hitSpaceShip(SpaceShip&    otherObject);
        virtual void hitSpaceStation(SpaceStation& otherObject);
        virtual void hitAsteroid(Asteroid&     otherObject);
        ...
    };
初始化模拟虚函数表：
    
    class GameObject { // this is unchanged 
    public: 
        virtual void collide(GameObject& otherObject) = 0;
        ...
    };
    
    class SpaceShip: public GameObject {
    public:
        virtual void collide(GameObject& otherObject);
        // these functions now all take a GameObject parameter
        virtual void hitSpaceShip(GameObject& spaceShip);
        virtual void hitSpaceStation(GameObject& spaceStation);
        virtual void hitAsteroid(GameObject& asteroid);
        ...
    };
    
    SpaceShip::HitMap * SpaceShip::initializeCollisionMap(){
        HitMap *phm = new HitMap;
        (*phm)["SpaceShip"] = &hitSpaceShip;
        (*phm)["SpaceStation"]= &hitSpaceStation;
        (*phm)["Asteroid"] = &hitAsteroid;
        return phm; 
    }


#### 六、杂项

**32. 在将来时态下开发程序**

新的函数会被加入到函数库里面， 将来会出现新的重载（所以要注意哪些含糊的函数调用行为的结果），新的类会加入到继承中，新的环境下运行等。

应该通过代码来描述这些行为，而不仅仅是注释写上。实在拿不定我们类怎么设计的时候，仿照int来写

**33. 将非尾端类设计为抽象类**

如果采用这样的代码：

    class Animal{
    public:
        virtual Animal& operator=(const Animal& rhs);
        ....
    };
    class Lizard:public Animal{
    public:
        virtual Lizard& operator=(const Animal& rhs);
    };
    class Chicken:public Animal{
    public:
        virtual Chicken& operator=(const Animal& rhs);
    }
则会出现我们不愿意出现的类型转换和赋值：
    
    Animal *pAnimal1 = &liz;
    Animal *pAnimal2 = &chick;
    *pAnimal1 = *pAnimal2;      //把一个chick赋值给了一个lizard

但是我们又希望下面的操作是可行的：
    Animal *pAnimal1 = &liz1;
    Animal *pAnimal2 = &liz2;
    *pAnimal1 = *pAnimal2;      //正确，把一个lizard赋值给了一个lizard

解决这个问题最简单的方法是使用dynamic_cast进行类型检测，但是还有一个方法就是把Animal设成抽象类或者创建一个抽象Animal类：

    class AbstractAnimal{
    protected:
        AbstractAnimal& operator=(const AbstractAnimal& rhs);
    public:
        virtual ~AbstractAnimal() = 0;
    };
    
    class Animal: public AbstractAnimal{
    public:
        Animal& operator=(const Animal& rhs);
    };
    class Lizard:public AbstractAnimal{
    public:
        virtual Lizard& operator=(const Animal& rhs);
    };
    class Chicken:public AbstractAnimal{
    public:
        virtual Chicken& operator=(const Animal& rhs);
    }

感觉这个方法以后会非常有用。。。。

**34. 理解如何在同一程序中混合使用C**

名字变换：就是在编译器分别给C++和C不同的前缀，在C语言中，因为没有函数重载，所以编译器没有专门给函数改变名字，但是在C++里面，编译器是要给函数不同的名字的。

C++的extern‘C’可以禁止进行名字变换，例如：
    
    extern 'C'
    void drawLine(int x1, int y1, int x2, int y2);

静态初始化：在C++中，静态的类对象和定义会在main执行前执行。
在编译器中，这种处理方法通常是在main里面默认调用某个函数：
    
    int main(int argc, char *argv[]){
        performStaticInitialization();
    
        realmain();
    
        performStaticDestruction();
    }
动态内存分配：C++时候new和delete，C是malloc和free

数据结构的兼容性：C无法知道C++的特性

总结下来就是：确保C++和C编译器产生兼容的obj文件，将在两种语言下都是用的函数声明为extern'C'，只要可能，应该用C++写main(),delete，new成对使用，malloc和free成对使用，

**35. 让自己熟悉C++语言标准**

熟悉stl和一些新的C++特性。

在C++运行库中的几乎任何东西都是模板，几乎所有的内容都在命名空间std中


## Effective Modern C++

some note copy from [EffectiveModernCppChinese](https://github.com/racaljk/EffectiveModernCppChinese)

#### 一、类型推导

**1. 理解模板类型推导**

其他之前说过了，主要是T有三种情况：1.指针或引用。2.通用的引用。3.既不是指针也不是引用
    
    template<typename T>
    void f(T& param);   //param是一个引用
    
    int x = 27; // x是一个int
    const int cx = x; // cx是一个const int
    const int& rx = x; // rx是const int的引用
    上面三种在调用f的时候会编译出不一样的代码：
    f(x);  // T是int，param的类型时int&
    f(cx); // T是const int，param的类型是const int&
    f(rx); // T是const int， param的类型时const int&
    
    template<typename T>
    void f(T&& param); // param现在是一个通用的引用
    
    template<typename T>
    void f(T param); // param现在是pass-by-value

如果用数组或者函数指针来调用的话，模板会自动抽象成指针。如果模板本身是第一种情况（指针或引用），那么就会自动编译成数组

**2. 理解auto类型推导**

auto关键字的类型推倒和模板差不多，auto就相当于模板中的T，所以：

    auto x = 27; // 情况3（x既不是指针也不是引用）
    const auto cx = x; // 情况3（cx二者都不是）
    const auto& rx = x; // 情况1（rx是一个非通用的引用）
    
    auto&& uref1 = x; // x是int并且是左值，所以uref1的类型是int&
    auto&& uref2 = cx; // cx是int并且是左值，所以uref2的类型是const int&
    auto&& uref3 = 27; // 27是int并且是右值， 所以uref3的类型是int&&
在花括号初始化的时候，推倒的类型是std::initializer_list的一个实例，但是如果把相同的类型初始化给模板，则是失败的，

    auto x = { 11, 23, 9 }; // x的类型是std::initializer_list<int>
    template<typename T> void f(T param); // 和x的声明等价的模板
    f({ 11, 23, 9 }); // 错误的！没办法推导T的类型
    
    template<typename T> void f(std::initializer_list<T> initList);
    f({ 11, 23, 9 }); // T被推导成int，initList的类型是std::initializer_list<int>

**3. 理解decltype**

    template<typename Container, typename Index> // works, but requires refinements
    auto authAndAccess(Container& c, Index i) -> decltype(c[i])
    {
        authenticateUser();
        return c[i];
    }
    在上面的这段代码里面，C++14可以把后面的->decltype(c[i])删掉，但是auto实际推倒的类型是container而不带引用。因为 authAndAccess(d, 5) = 10这样是编译器不允许的情况。
如果想要返回引用的话，需要将上面的那一段代码重写成下面的样子：
    
    template<typename Container, typename Index> // works, but still requires refinements
    decltype(auto) authAndAccess(Container& c, Index i)
    {
        authenticateUser();
        return c[i];
    }
如果想要这个函数既返回左值（可以修改）又可以返回右值（不能修改）的话，可以用下面的写法：
    
    template<typename Container, typename Index>
    decltype(auto) authAndAccess(Container&& c, Index i){//C++14
        authenticateUser();
        return std::forward<Container>(c)[i];
    }
decltype的一些让人意外的应用：
    
    decltype(auto) f2(){
        int x = 0 ;
        return x;     // 返回的是int;
    }
    decltype(auto) f2(){
        int x = 0;
        return (x);   //返回的是int&
    }

**4. 学会查看类型推导结果**

其实就是使用IDE编辑器来进行鼠标悬停/debug模式/运行时typeid输出等操作来查看类型

需要知道的是，编译器报告出来的数据类型并不一定正确，所以还是需要对C++标准的类型推倒熟悉

#### 二、auto

**5. 优先考虑auto而非显式类型声明**

没有初始化auto的时候，会从编译器阶段就报错;
可以让lambda表达式更加稳定，更加快速，需要更少的资源，避免类型截断的问题，变量声明引起的歧义：
    
    std::vector<int> v;
    unsigned sz = v.size(); //在32位下运行良好，因为此时size()返回的size_type是32位的，unsigned也是32位的，但是在64位上就不行了，size_type会变成64位，而unsigned仍然是32位
    auto     sz = v.size(); //在64位机器上仍然表现良好

**6. auto推导若非己愿，使用显式类型初始化惯用法**

    std::vector<bool> features(const Widget& w);
    Widget w;
    auto highPriority = features(w)[5]
    
    processWidget(w, highPriority); // 未定义的行为，因为这个时候highPriority已经不是bool类型的了，这个时候返回的是一个std::vector<bool>::reference对象（内嵌在std::vector<bool>中的对象）
如果用：
    
    bool highPriority = features(w)[5];的时候，因为编译器看到bool，所以会发生隐式转换，将reference转换成bool类型
当然也有强制变成bool 的方法：
    
    auto highPriority = static_cast<bool>(features(w)[5]);


#### 三、移步现代C++

**7. 区别使用()和{}创建对象**

大括号{}，更像是一种通用的，什么时候初始化都能用的东西，但是大括号会进行类型检查：
    
    double x, y, z;
    int sum1{x+y+z}; //错误，因为double之和可能无法用int表达（超出int范围）

小括号()和等于号=在更多时候是无法使用的，并且小括号很容易被认为是一个函数。但是这两个不会进行类似上面的类型检查：
    
    class Widget{
        int x{0}; //right
        int y = 0;//right
        int z(0); //错！
    };
    
    std::atomic<int> ai2(0); //right
    std::atomic<int> ai3 = 0; //错！
    
    Widget w1(10); //调用w1的构造函数

大括号和小括号的另一个区别是带有std::initializer_list<long double> 的时候，会自动调用大括号，反之没区别：
    
    class Widget{
    public:
        Widget(int i, bool b);
        Widget(std::initializer_list<long double> il);
    };
    
    Widget w1(10, true); //调用第一个构造函数
    Widget w2{10, true}; //调用第二个构造函数


**8. 优先考虑nullptr而非0和NULL**

编译器扫到一个0，发现有一个指针用到了他，所以才勉强强行将0解释为空指针，而NULL也是如此，这就会造成一些细节上的不确定性。

使用nullptr不仅可以避免一些歧义，还可以让代码更加清晰，而且nullptr是无法被解释为整数的，可以避免很多问题
**9. 优先考虑别名声明而非typedefs**

别名声明可以让函数指针变得更容易理解：

    // FP等价于一个函数指针，这个函数的参数是一个int类型和
    // std::string常量类型，没有返回值
    typedef void (*FP)(int, const std::string&); // typedef
    // 同上
    using FP = void (*)(int, const std::string&); // 声明别名
并且类型别名可以实现别名模板，而typedef不行：
    
    template<typname T> // MyAllocList<T>
    using MyAllocList = std::list<T, MyAlloc<T>>; // 等同于std::list<T,MyAlloc<T>>
    MyAllocList<Widget> lw; // 终端代码
模板别名还避免了::type的后缀，在模板中，typedef还经常要求使用typename前缀：
    
    template<class T>
    using remove_const_t = typename remove_const<T>::type

**10. 优先考虑限域枚举(enmus)而非未限域枚举(enum)**

    enum Color { black, white, red}; // black, white, red 和 Color 同属一个定义域
    auto white = false; // 错误！因为 white 在这个定义域已经被声明过
    
    enum class Color { black, white, red}; // black, white, red作用域为 Color
    auto white = false; // fine, 在这个作用域内没有其他的 "white"

C++98 风格的 enum 是没有作用域的 enum

有作用域的枚举体的枚举元素仅仅对枚举体内部可见。只能通过类型转换（ cast ）转换
为其他类型

有作用域和没有作用域的 enum 都支持指定潜在类型。有作用域的 enum 的默认潜在类型是 int 。没有作用域的 enum 没有默认的潜在类型。

有作用域的 enum 总是可以前置声明的。没有作用域的 enum 只有当指定潜在类型时才可以前置声明。
**11. 优先考虑使用delete来禁用函数而不是声明成private却又不实现**

    template <class charT, class traits = char_traits<charT> >
    class basic_ios : public ios_base {
    public:
        basic_ios(const basic_ios& ) = delete;
        basic_ios& operator=(const basic_ios&) = delete;
    };
delete的函数不能通过任何方式被使用，即使是其他成员函数或者friend，都是不行的，但是如果只是声明成privatre，编译器只会报警说是private的。

delete的另一个优势就是任何函数都可以delete，但是只有成员函数才能是private的，例如：
    
    bool isLucky(int number); // 原本的函数
    bool isLucky(char) = delete; // 拒绝char类型
上面这一段代码如果只是声明成private的话，会被重载

**12. 使用override声明重载函数**

只有当基类和子类的虚函数完全一样的时候，才会出现覆盖的情况，如果不完全一样，则会重载：
    
    class Base{
    public:
        virtual void doWork();
    };
    class Derived: public Base{
    public:
        virtual void doWork();   //会覆盖基类
    };
    
    class Derived:public Base{
    public:
        virtual void doWork()&&; //不会发生覆盖，而是会重载
    };
所以尽量要在需要重写的函数后面加上override

**13. 优先考虑const_iterator而非iterator**

C++98中const_iterator不太好用，但是C++11中很方便

**14. 如果函数不抛出异常请使用noexcept**

因为对于异常本身来说，会不会发生异常往往是人们所关心的事情，什么样的异常反而是不那么关心的，因此noexcept和const是同等重要的信息
并且加上noexcept关键字，会让编译器对代码的优化变强。

对于像swap这样需要进行异常检查的函数（还有移动操作函数，内存释放函数，析构函数），如果有noexcept关键字的话，会让代码效率提升非常大。当然，noexcept用的时候必须保证函数真的不会抛出异常

**15. 尽可能的使用constexpr**

constexpr：表示的值不仅是const，而且在编译阶段就已知其值了，他们因为这样的特性就会被放到只读内存里面，并且因为这个特性，constexpr的值可以用在数组规格，整形模板实参中：
    
    constexpr auto arraySize = 10;
    std::array<int, arraySize> data2;

但是对于constexpr的函数来说，如果所有的函数实参都是已知的，那这个函数也是已知的，如果所有实参都是未知的，编译无法通过，
在调用constexpr函数时，入股传入的值有一个或多个在编译期未知，那这个函数就是个普通函数，如果都是已知的，那这个函数也是已知的。

使用constexpr会让客户的代码得到足够的支持，并且提升程序的效率

**16. 确保const成员函数线程安全**

    class Polynomial{
    public:
        using RootsType = std::vector<double>;
        RootsType roots() const{
            if(!rootAreValid){
                rootsAreValid = true;
            }
            return rootVals;
        }
    private:
        mutable bool rootsAreValid{false};
        mutable RootsType rootVals{};
    }

在上面那段代码中，虽然roots是const的成员函数，但是成员变量是mutable的，是可以在里面改的，如果这样做的话，就无法做到线程安全，并且编译器在看到const的时候还认为他是安全的。这个时候只能加上互斥量 std::lock_guard<std::mutex> g(m); mutable std::mutex m;

当然，除了上面添加互斥量的做法以外，成本更低的做法是进行std::atomic的操作（但是仅适用于对单个变量或内存区域的操作）：
    
    class Point{
    public:
        double distanceFromOrigin() const noexcept{
            ++callCount;
            return std::sqrt((x*x) + (y * y));
        }    
    private:
        mutable std::atomic<unsigned> callCount{0};
        double x, y;
    };

**17. 理解特殊成员函数函数的生成**

特殊成员函数包括默认构造函数，析构函数，拷贝构造函数，拷贝赋值运算符（这些函数只有在需要的时候才会生成），以及最新的移动构造函数和移动赋值运算符

三大律：如果你声明了拷贝构造函数，赋值运算符重载，析构函数中的任何一个，都需要把其他几个补全，如果不想自己写的话，也要写上=default（如果不声明的话，编译器很有可能不会生成另外几个函数的默认函数）

对于成员函数模板来说，在任何情况下都不会抑制特殊成员函数的生成

#### 四、智能指针

**18. 对于占有性资源使用std::unique_ptr**

资源是独占的，不允许拷贝，允许进行move
std::unique_ptr是一个具有开销小，速度快，move-only特定的智能指针，使用独占拥有方式来管理资源

默认情况下，释放资源由delete来完成，也可以指定自定义的析构函数来替代，但是具有丰富状态的deleters和以函数指针作为deleters增大了std::unique_ptr的存储开销

很容易将一个std::unique_ptr转化为std::shared_ptr

**19. 对于共享性资源使用std::shared_ptr**

+ std::shared_ptr是原生指针的两倍大小，因为他们内部除了包含一个原生指针以外，还包含了一个引用计数
+ 引用计数的内存必须被动态分配，当然用make_shared来创建shared_ptr会避免动态内存的开销。
+ 引用计数的递增和递减必须是原子操作。
+ std::shared_ptr为了管理任意资源的共享式内存管理，提供了自动垃圾回收的便利
+ std::shared_ptr 是 std::unique_ptr 的两倍大，除了控制块，还有需要原子引用计数操作引起的开销
+ 资源的默认析构一般通过delete来进行，但是自定义的deleter也是支持的。deleter的类型对于 std::shared_ptr 的类型不会产生影响
+ 避免从原生指针类型变量创建 std::shared_ptr

**20. 对于类似于std::shared_ptr的指针使用std::weak_ptr可能造成悬置**

weak_ptr通常由一个std::shared_ptr来创建，他们指向相同的地方，但是weak_ptr并不会影响到shared_ptr的引用计数：
    
    auto spw = std::make_shared<Widget>();//spw 被构造之后被指向的Widget对象的引用计数为1(欲了解std::make_shared详情，请看Item21)
    std::weak_ptr<Widget> wpw(spw);//wpw和spw指向了同一个Widget,但是RC(这里指引用计数，下同)仍旧是1
    spw = nullptr;//RC变成了0，Widget也被析构，wpw现在处于悬挂状态
    if(wpw.expired())... //如果wpw悬挂...
那么虽然weak_ptr看起来没什么用，但是他其实也有一个应用场合（用来做缓存）：
    
    std::unique_ptr<const Widget> loadWidget(WidgetID id); //假设loadWidget是一个很繁重的方法，需要对这个方法进行缓存的话，就需要用到weak_ptr了：
    
    std::shared_ptr<const Widget> fastLoadWidget(WidgetId id){
        static std::unordered_map<WidgetID,
        std::weak_ptr<const Widget>> cache;
        auto objPtr = cache[id].lock();//objPtr是std::shared_ptr类型指向了被缓存的对象(如果对象不在缓存中则是null)
        if(!objPtr){
            objPtr = loadWidget(id);
            cache[id] = objPtr;
        }   //如果不在缓存中，载入并且缓存它
        return objPtr;
    }
+ std::weak_ptr 用来模仿类似std::shared_ptr的可悬挂指针
+ 潜在的使用 std::weak_ptr 的场景包括缓存，观察者列表，以及阻止 std::shared_ptr 形成的环

**21. 优先考虑使用std::make_unique和std::make_shared而非new**

+ 和直接使用new相比，使用make函数减少了代码的重复量，提升了异常安全度，并且，对于std::make_shared以及std::allocate_shared来说，产生的代码更加简洁快速
+ 也会存在使用make函数不合适的场景：包含指定自定义的deleter,以及传递大括号initializer的需要
+ 对于std::shared_ptr来说，使用make函数的额外的不使用场景还包含

    (1)带有自定义内存管理的class
    (2)内存非常紧俏的系统，非常大的对象以及比对应的std::shared_ptr活的还要长的std::weak_ptr

**22. 当使用Pimpl惯用法，请在实现文件中定义特殊成员函数**

impl类的做法：之前写到过，就是把对象的成员变量替换成一个指向已经实现的类的指针，这样可以减少build的次数
    
    class Widget{ //still in header "widget.h"
    public:
        Widget();
        ~Widget(); //dtor is needed-see below
    private:
        struct Impl; //declare implementation struct and pointer to it
        std::unique_ptr<Impl> pImpl;
    }
    
    #include "widget.h" //in impl,file "widget.cpp"
    #include "gadget.h"
    #include <string>
    #include <vector>
    struct Widget::Impl{
        std::string name; //definition of Widget::Impl with data members formerly in Widget
        std::vector<double> data;
        Gadget g1,g2,g3;
    }
    Widget::Widget():pImpl(std::make_unique<Impl>())
    Widget::~Widget(){} //~Widget definition，必须要定义，如果不定义的话会报错误，因为在执行Widget w的时候，会调用析构，而我们并没有声明，所以unique_ptr会有问题

+ Pimpl做法通过减少类的实现和类的使用之间的编译依赖减少了build次数
+ 对于 std::unique_ptr pImpl指针，在class的头文件中声明这些特殊的成员函数，在class
的实现文件中定义它们。即使默认的实现方式(编译器生成的方式)可以胜任也要这么做
+ 上述建议适用于 std::unique_ptr ,对 std::shared_ptr 无用


#### 五、右值引用，移动语意，完美转发

**23. 理解std::move和std::forward**

首先move不move任何东西，forward也不转发任何东西，在运行时，不产生可执行代码，这两个只是执行转换的函数（模板），std::move无条件的将他的参数转换成一个右值，forward只有当特定的条件满足时才会执行他的转换，下面是std::move的伪代码：
    
    template<typename T>
    typename remove_reference<T>::type&& move(T&& param){
        using ReturnType = typename remove_reference<T>::type&&; //see Item 9
        return static_cast<ReturnType>(param);
    }

**24. 区别通用引用和右值引用**

    void f(Widget&& param);       //rvalue reference
    Widget&& var1 = Widget();     //rvalue reference
    auto&& var2 = var1;           //not rvalue reference
    template<typename T>
    void f(std::vector<T>&& param) //rvalue reference
    template<typename T>
    void f(T&& param);             //not rvalue reference

+ 如果一个函数的template parameter有着T&&的格式，且有一个deduce type T.或者一个对象被生命为auto&&,那么这个parameter或者object就是一个universal reference.
+ 如果type的声明的格式不完全是type&&,或者type deduction没有发生，那么type&&表示的是一个rvalue reference.
+ universal reference如果被rvalue初始化，它就是rvalue reference.如果被lvalue初始化，他就是lvaue reference.

**25. 对于右值引用使用std::move，对于通用引用使用std::forward**

右值引用仅会绑定在可以移动的对象上，如果形参类型是右值引用，则他绑定的对象应该是可以移动的

+ 通用引用在转发的时候，应该进行向右值的有条件强制类型转换（用std::forward）
+ 右值引用在转发的时候，应该使用向右值的无条件强制类型转换（用std::move)
+ 如果上面两个方法使用反的话，可能会导致很麻烦的事情（代码冗余或者运行期错误）

在书中一直在强调“move”和"copy"两个操作的区别，因为move在一定程度上会效率更高一些

但是在局部对象中这种想法是错误的：
    
    Widget MakeWidget(){
        Widget w;
        return w; //复制，需要调用一次拷贝构造函数
    }
    
    Widget MakeWidget(){
        Widget w;
        return std::move(w);//错误！！！！！！！会造成负优化
    }

因为在第一段代码中，编译器会启用返回值优化（return value optimization RVO）,这个优化的启动需要满足两个条件：
+ 局部对象类型和函数的返回值类型相同
+ 返回的就是局部对象本身

而下面一段代码是不满足RVO优化的，所以会带来负优化

所以：如果局部对象可以使用返回值优化的时候，不应该使用std::move 和std:forward

**26. 避免重载通用引用**

主要是因为通用引用（特别是模板），会产生和调用函数精确匹配的函数，例如现在有一个：
    
    template<typename T>
    void log(T&& name){}
    
    void log(int name){}
    
    short a;
    log(a);

这个时候如果调用log的话，就会产生精确匹配的log方法，然后调用模板函数

而且在重载过程当中，通用引用模板还会和拷贝构造函数，复制构造函数竞争（这里其实有太多种情况了），只举书上的一个例子：
    
    class Person{
    public:
        template<typename T> explicit Person(T&& n): name(std::forward<T>(n)){} //完美转发构造函数
        explicit Person(int idx); //形参为int的构造函数
    
        Person(const Person& rhs) //默认拷贝构造函数（编译器自动生成）
        Person(Person&& rhs); //默认移动构造函数（编译器生成）
    };
    
    Person p("Nancy");
    auto cloneOfP(p);  //会编译失败，因为p并不是const的，所以在和拷贝构造函数匹配的时候，并不是最优解，而会调用完美转发的构造函数

**27. 熟悉重载通用引用的替代品**

这一条主要是为了解决26点的通用引用重载问题提的几个观点，特别是对构造函数（完美构造函数）进行解决方案

+ 放弃重载，采用替换名字的方案
+ 用传值来替代引用（可以提升性能但却不用增加一点复杂度
+ 采用impl方法：
  
    template<typename T>
    void logAndAdd(T&& name){
        logAndAddImpl(
            std::forward<T>(name), 
            std::is_integral<typename std::remove_reference<T>::type>() //这一句只是为了区分是否是整形
        ); 
    }
+ 对通用引用模板加以限制（使用enable_if）
  
    class Person{
    public:
        template<typename T,
                 typename = typename std::enable_if<condition>::type>//这里的condition只是一个代号，condition可以是：!std::is_same<Person, typename std::decay<T>::type>::value,或者是：!std::is_base_of<Person, typename std::decay<T>::type>::value&&!std::is_integral<std::remove_reference_t<T>>::value
        explicit Person(T&& n);
    }
//说实话这个代码的可读性emmmmmmmm，大概还是我太菜了。。。。

**28. 理解引用折叠**

在实参传递给函数模板的时候，推导出来的模板形参会把实参是左值还是右值的信息编码到结果里面：
    
    template<typename T>
    void func(T&& param);
    
    Widget WidgetFactory() //返回右值
    Widget w;
    
    func(w);               //T的推到结果是左值引用类型，T的结果推倒为Widget&
    func(WidgetFactory);   //T的推到结果是非引用类型（注意这个时候不是右值），T的结果推到为Widget
C++中，“引用的引用”是违法的，但是上面T的推到结果是Widget&时，就会出现 void func(Widget& && param);左值引用+右值引用

所以事实说明，编译器自己确实会出现引用的引用（虽然我们并不能用），所以会有一个规则（我记得C++ primer note里面也讲到过）
+ 如果任一引用是左值引用，则结果是左值引用，否则就是右值引用
+ 引用折叠会在四种语境中发生：模板实例化，auto类型生成、创建和运用typedef和别名声明，以及decltype

**29. 认识移动操作的缺点**

+ 假设移动操作不存在，成本高，未使用
+ 对于那些类型或对于移动语义的支持情况已知的代码，则无需做上述假定

原因在于C++11以下的move确实是低效的，但是C++11及以上的支持让move操作快了一些，但是更多时候编写代码并不知道代码对C++版本的支持，所以要做以上假定

**30. 熟悉完美转发失败的情况**

    template<typename T>
    void fwd(T&& param){           //接受任意实参
        f(std::forward<T>(param)); //转发该实参到f
    }
    
    template<typename... Ts>
    void fwd(Ts&&... param){        //接受任意变长实参
        f(std::forward<Ts>(param)...);
    }

完美转发失败的情况：
    
    （大括号初始化物）
    f({1, 2, 3}); //没问题，{1, 2, 3}会隐式转换成std::vector<int>
    fwd({1, 2, 3}) //错误，因为向为生命为std::initializer_list类型的函数模板形参传递了大括号初始化变量，但是之前说如果是auto的话，会推到为std::initializer_list,就没问题了。。。
    
    （0和NULL空指针）
    （仅仅有声明的整形static const 成员变量）：
    class Widget{
    public:
        static const std::size_t MinVals = 28; //仅仅给出了声明没有给出定义
    };
    fwd(Widget::MinVals);      //错误，应该无法链接，因为通常引用是当成指针处理的，而也需要指定某一块内存来让指针指涉
    
    （重载的函数名字和模板名字）
    void f(int (*fp)(int));
    int processValue(int value);
    int processValue(int value, int priority);
    fwd(processVal); //错误，光秃秃的processVal并没有类型型别
    
    （位域）
    struct IPv4Header{
        std::uint32_t version:4,
        IHL:4,
        DSCP:6,
        ECN:2,
        totalLength:16;
    };
    
    void f(std::size_t sz); IPv4Header h;
    fwd(h.totalLength); //错误
+ 最后，所有的失败情形实际上都归结于模板类型推到失败，或者推到结果是错误的。

#### 六、Lambda表达式

**31. 避免使用默认捕获模式**

主要是使用显式捕获的时候，可以比较明显的让用户知道变量的声明周期：
    
    void addDivisorFilter(){
        auto divisor = computeDivisor(cal1, cal2);
        filters.emplace_back([&](int value){return value % divisor == 0;}) //危险，因为divisor在闭包里面很容易空悬，生命周期会结束
    }
如果用显式捕获的话：

    filters.emplace_back([&divisor](int value){return value % divisor == 0;}) //仍然很危险，但是起码很明显
最好的做法就是传一个this进去：

    void Widget::addFilter() const{
        auto currentObjectPtr = this;    //这样就把变量的声明周期和object绑定起来了
        filters.emplace_back([currentObjectPtr](int value){
            return value % currentObjectPtr->advisor == 0;
        })
    }

**32. 使用初始化捕获来移动对象到闭包中**

    auto func = [pw = std::make_unique<Widget>()]{    //初始化捕获（广义lambda捕获），适用于C++14及其以上
        return pw->isValidated() && pw->isArchived();
    };
    
    auto func = std::bind([](const std::unique_ptr<Widget>& data){}, std::make_unique<Widget>()); // C++11的版本，和上面的含义一样

**33. 对于std::forward的auto&&形参使用decltype**

在C++14中，我们可以在lambda表达式里面使用auto了，那么我们想要把传统的完美转发用lambda表达式写出来应该是什么样子的呢：
    
    class SomeClass{
    public:
        template<typename T>
        auto operator()(T x) const{
            return func(normalize(x));
        }
    }
    
    auto f=[](auto&& x){
        return func(normalize(std::forward<decltype(x)>(x)));
    };

**34. 优先考虑lambda表达式而非std::bind**

+ lambda表达式具有更好的可读性，表达力也更强，有可能效率也更高
+ 只有在C++11中，bind还有其发挥作用的余地 

#### 七、并发API

**35. 优先考虑基于任务的编程而非基于线程的编程**

基于线程的代码：
    
    int doAsyncWork();
    std::thread t(doAsyncWork);

基于任务的代码：
    
    auto fut = std::async(doAsyncWork);

我们应该优先考虑基于任务的方法（后面这个），首先async是能够获得doAsyncWork的返回值的，并且如果里面有异常的话，也可以捕捉得到。而且更重要的是，使用后面这种方法可以将线程管理的责任交给std标准库来，不需要自己解决死锁，负载均衡，新平台适配等问题

另外，软件线程（操作系统线程或者系统线程）是操作系统的跨进程管理线程，能够创建的数量比硬件线程要多，但是是一种有限资源，当软件线程没有可用的时候，就会直接抛出异常，即使被调用函数式noexcept的。

下面是几种直接使用线程的情况（当然这些情况并不常见）：
+ 需要访问底层线程实现的API（pthread或者Windows线程库）
+ 需要并且开发者有能力进行线程优化
+ 需要实现C++并发API中没有的技术

**36. 如果有异步的必要请指定std::launch::threads**

+ std::launch::async：指定的时候意味着函数f必须以异步方式进行，即在另一个线程上执行
+ std::launch::deferred 则指f只有在get或者wait函数调用的时候同步执行，如果get或者wait没有调用，则f不执行
+ 如果不指定策略的话（默认方法），则系统会按照自己的估计来推测需要进行什么样的策略（会带来不确定性），感觉还是很危险的！！！所以尽量在使用的时候指定是否是异步或者是同步
  
    auto fut = std::async(f);
    if(fut.wait_for(0s) == std::future_statuc::deferred){....}    //判断是否是同步（是否推迟了）
    else{
        while{fut.wait_for(100ms) != std::future_status::ready}{}//不可能死循环，因为之前有过判断是否是同步
    }

**37. 从各个方面使得std::threads unjoinable**

每一个std::thread类型的对象都处于两种状态：joinable和unjoinable

+ joinable：对应底层已运行、可运行或者运行结束的出于阻塞或者等待调度的线程
+ unjoinable： 默认构造的std::thread, 已move的std::thread, 已join的std::thread, 已经分离的std::thread
+ 如果某一个std::thread是joinable的，然后他被销毁了，会造成很严重的后果，（比如会造成隐式join（会造成难以调试的性能异常）和隐式detach（会造成难以调试的未定义行为）），所以我们要保证thread在所有路径上都是unjoinable的：
  
    class ThreadRAII{
    public:
        enum class DtorAction{join, detach};
        ThreadRAII(std::thread&& t, DtorAction a):action(a), t(std::move(t)){} //把线程交给ThreadRAII处理
        ~THreadRAII(){
            if(t.joinable()){
                if(action == DtorAction::join){
                    t.join();
                }
                else{
                    t.detach();                  //保证所有路径出去都是不可连接的
                }
            }
        }
    private:
        DtorAction action;
        std::thread t;    //成员变量最后声明thread
    }

**38. 知道不同线程句柄析构行为**

     _____           ___返回值___  std::promise _______
    |调用方|<--------|被调用方结果|<------------|被调用方|

因为被调用函数的返回值有可能在调用方执行get前就执行完毕了，所以被调用线程的返回值会保存在一个地方，所以会存在一个"共享状态"

所以在异步状态下启动的线程的共享状态的最后一个返回值是会保持阻塞的，知道该任务结束，返回值的析构函数在常规情况下，只会析构返回值的成员变量

**39. 考虑对于单次事件通信使用void**

对于我们在线程中经常使用的flag标志位：
    
    while(!flag){}

可以用线程锁来代替,这个时候等待，不会占用本该进行计算的某一个线程资源：
    
    bool flag(false);
    std::lock_guard<std::mutex> g(m);
    flag = true;

不过使用标志位的话也不太好，如果使用std::promise类型的对象的话就可以解决上面的问题，但是这个途径为了共享状态需要使用堆内存，而且只限于一次性通信
    
    std::promise<void> p;
    void react();    //反应任务
    void detect(){  //检测任务
        std::thread t([]{
            p.get_future().wait();
            react();           //在调用react之前t是暂停状态
        });
        p.set_value();  //取消暂停t
        t.join();       //把t置为unjoinable状态
    }   

**40. 对于并发使用std::atomic，对特殊内存区使用volatile**

atomic原子操作（其他线程只能看到ai的值是0 或者10）:
    
    std::atomic<int> ai(0);
    ai = 10;                 //将ai原子的设置为10

volatile 类型值（其他线程可以看到vi取任何值）：
    
    volatile int vi(0);      //将vi初始化为0
    vi = 10;                 //将vi的值设置为10，如果两个线程同时执行vi++的话，就可能会出现11和12两种情况

volatile的作用：告诉编译器正在处理的变量使用的是特殊内存，不要在这个变量上做任何优化
    
    volatile int x;
    auto y = x; //读取x，（这个时候auto会把const和volatile的修饰词丢弃掉，所以y的类型是int
    y = x;      //再次读取x，这个时候不会被优化掉

#### 八、微调

**41. 对于那些可移动总是被拷贝的形参使用传值方式**

一般来说，我们写函数的时候是不用按值传递的，但是如果形参本身就是要拷贝或者移动的话，是可以按值来传递的，三种操作的成本如下：

+ 重载操作：对于左值是一次复制，对于右值是一次移动
+ 使用万能引用：左值是一次复制，右值是一次移动
+ 按值传递：左值是一次复制加一次移动，右值是两次移动

所以按值传递的应用场景：移动操作成本低廉，形参是可以复制的，因为这两种情况同时满足的时候，按值传递效率并不会低太多

**42. 考虑就地创建而非插入**

+ 插入方法： push_back()等
+ 就地创建方法：emplace_back()等

考虑以下代码：
    
    std::vector<std::string> vs;
    vs.push_back("xyz");

上面这一段代码一共有三个步骤：
+ 从xyz变量出发，创建从const char到string的临时变量temp，temp是个右值
+ temp被传递给push_back的右值重载版本，在内存中为vector构造一个x的副本，创建一个新的对象
+ 在push_back完成的时候，temp被析构

如果用emplace_back的话，就不会产生任何临时对象，因为emplace_back使用了完美转发方法，这样就会大大提升代码的效率

在以下情况下，创建插入会比插入更高效（其实如果不是出现拒绝添加新值的情况的话，置入永远比插入要好一些）：
+ 要添加的值是以构造而不是复制的方式加入到容器中的
+ 传递的实参类型和容器内本身的类型不同
+ 容器不太可能由于出现重复情况而拒绝添加的新值（例如map）