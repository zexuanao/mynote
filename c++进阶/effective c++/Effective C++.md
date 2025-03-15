## Effective C++

#### 一、让自己习惯C++ (Accustoming Yourself to C++ 11)

**1. 视C++ 为一个语言联邦 11（View C++ as a federation of languages 11)**

    主要是因为C++是从四个语言发展出来的：
    C的代码块({}), 语句，数据类型等，
    object-C的class，封装继承多态，virtual动态绑定等，
    template C++的泛型
    STL：容器，迭代器，算法，函数对象等
    
    因此当这四个子语言相互切换的时候，可以更多地考虑高效编程，例如pass-by-value和pass-by-reference在不同语言中效率不同

总结：
+ C++高效编程守则视状况而变化，取决于使用哪个子语言


**2. 尽量以const, enum, inline替换#define（Prefer consts,enums, and inlines to #defines)**

实际是：应该让编译器代替预处理器定义，因为预处理器定义的变量并没有进入到symbol table里面。编译器有时候会看不到预处理器定义

所以用 

    const double Ratio = 1.653;

来代替 
    
    #define Ratio 1.653

实际上在这个转换中还要考虑到指针，例如需要把指针写成const char* const authorName = "name";而不是只用一个const

以及在class类里面的常量，为了防止被多次拷贝，需要定义成类的成员（添加static）例如

    class GamePlayer{
        static const int numT = 5;
    }

对于类似函数的宏，最好改用inline函数代替，例如：
    
    #define CALL_WITH_MAX(a, b) f((a) > (b) ? (a) : (b))
    template<typename T>
    inline void callWithMax(const T& a, const T& b){
        f(a > b ? a : b);
    }

总结：
+ 对于单纯的常量，最好用const和enums替换#define， 对于形似函数的宏，最好改用inline函数替换#define

**3. 尽可能使用const（Use const whenever possible.)**

const 出现在星号左边，表示被指物是常量，如果出现在星号右边，表示指针本身是常量，如果出现在星号两边，表示被指物和指针都是常量

const最强的用法是在函数声明时，如果将返回值设置成const，或者返回指针设置成const，可以避免很多用户错误造成的意外。

概念上的const：

    考虑这样一段代码
    class CTextBlock{
        public:
            char& operator[](std::size_t position)const{
                return pText[position];
            }
        private:
            char *pText;
    }
    const CTextBlock cctb("Hello");
    char *pc = &cctb[0];
    *pc = 'J'
    这种情况下不会报错，但是一方面声明的时候说了是const，一方面还修改了值。这种逻辑虽然有问题但是编译器并不会报错

但是const使用过程中会出现想要修改某个变量的情况，而另外一部分代码确实不需要修改。这个时候最先想到的方法就是重载一个非const版本。
但是还有其他的方法，例如将非const版本的代码调用const的代码

总结：
+ 将某些东西声明为const可以帮助编译器检查出错误。
+ 编译器强制实施bitwise constneww，但是编写程序的时候应该使用概念上的常量性。
+ 当const和非const版本有着实质等价的实现时，让非const版本调用const版本可以避免代码重复


**4. 确定对象被使用前已先被初始化（Make sure that objects are initialized before they're used)**

对于C++中的C语言来说，初始化变量有可能会导致runtime的效率变低，但是C++部分应该手动保证初始化，否则会出现很多问题。

初始化的函数通常在构造函数上（注意区分初始化和赋值的关系，初始化的效率高，赋值的效率低，而且这些初始化是有次序的，base classes更早于他们的派生类（参看[C++ primer 二刷笔记](https://github.com/Tianji95/note-of-C-plus-plus-primer/blob/master/C%2B%2Bprimer%E4%BA%8C%E5%88%B7%E7%AC%94%E8%AE%B0.md)

除了这些以外，如果我们有两个文件A和B，需要分别编译，A构造函数中用到了B中的对象，那么初始化A和B的顺序就很重要了，这些变量称为（non-local static对象）

解决方法是：将每个non-local static对象搬到自己专属的函数内，并且该对象被声明为static，然后这些函数返回一个reference指向他所含的对象，用户调用这些函数，而不直接涉及这些对象（Singleton模式手法）：

    原代码：
    "A.h"
    class FileSystem{
        public:
            std::size_t numDisks() const;
    };
    extern FileSystem tfs;
    "B.h"
    class Directory{
        public:
            Directory(params){
                std::size_t disks = tfs.numDisks(); //使用tfs
            }
    }
    Director tempDir(params);
    修改后：
    "A.h"
    class FileSystem{...}    //同前
    FileSystem& tfs(){       //这个函数用来替换tfs对象，他在FileSystem class 中可能是一个static，            
        static FileSystem fs;//定义并初始化一个local static对象，返回一个reference
        return fs;
    }
    "B.h"
    class Directory{...}     // 同前
    Directory::Directory(params){
        std::size_t disks = tfs().numDisks();
    }
    Directotry& tempDir(){   //这个函数用来替换tempDir对象，他在Directory class中可能是一个static，
        static Directory td; //定义并初始化local static对象，返回一个reference指向上述对象
        return td;
    }

这样做的原理在于C++对于函数内的local static对象会在“该函数被调用期间，且首次遇到的时候”被初始化。当然我们需要避免“A受制于B，B也受制于A”

总结：
+ 为内置型对象进行手工初始化，因为C++不保证初始化他们
+ 构造函数最好使用初始化列初始化而不是复制，并且他们初始化时有顺序的
+ 为了免除跨文件编译的初始化次序问题，应该以local static对象替换non-local static对象

#### 二、构造/析构/赋值运算 (Constructors, Destructors, and Assignment Operators)

**5. 了解C++ 那些自动生成和调用的函数（Know what functions C++ silently writes and calls)**


总结：
+ 编译器可以自动为class生成default构造函数，拷贝构造函数，拷贝赋值操作符，以及析构函数

**6. 若不想使用编译器自动生成的函数，就该明确拒绝（Explicitly disallow the use of compiler-generated functions you do not want)**

这一条主要是针对类设计者而言的，有一些类可能从需求上不允许两个相同的类，例如某一个类表示某一个独一无二的交易记录，那么编译器自动生成的拷贝和复制函数就是无用的，而且是不想要的

总结：
+ 可以将不需要的默认自动生成函数设置成delete的或者弄一个private的父类并且继承下来

**7. 为多态基类声明virtual析构函数（Declare destructors virtual in polymorphic base classes)**

其主要原因是如果基类没有virtual析构函数，那么派生类在析构的时候，如果是delete 了一个base基类的指针，那么派生的对象就会没有被销毁，引起内存泄漏。
例如：
    
    class TimeKeeper{
        public:
        TimeKeeper();
        ~TimeKeeper();
        virtual getTimeKeeper();
    }
    class AtomicClock:public TimeKeeper{...}
    TimeKeeper *ptk = getTimeKeeper();
    delete ptk;
除析构函数以外还有很多其他的函数，如果有一个函数拥有virtual 关键字，那么他的析构函数也就必须要是virtual的，但是如果class不含virtual函数,析构函数就不要加virtual了，因为一旦实现了virtual函数，那么对象必须携带一个叫做vptr(virtual table pointer)的指针，这个指针指向一个由函数指针构成的数组，成为vtbl（virtual table），这样对象的体积就会变大，例如：

    class Point{
        public://析构和构造函数
        private:
        int x, y
    }

本来上面那个代码只占用64bits(假设一个int是32bits)，存放一个vptr就变成了96bits，因此在64位计算机中无法塞到一个64-bits缓存器中，也就无法移植到其他语言写的代码里面了。

总结：
+ 如果一个函数是多态性质的基类，应该有virtual 析构函数
+ 如果一个class带有任何virtual函数，他就应该有一个virtual的析构函数
+ 如果一个class不是多态基类，也没有virtual函数，就不应该有virtual析构函数

**8. 别让异常逃离析构函数（Prevent exceptions from leaving destructors)**

这里主要是因为如果循环析构10个Widgets，如果每一个Widgets都在析构的时候抛出异常，就会出现多个异常同时存在的情况，这里如果把每个异常控制在析构的话就可以解决这个问题：解决方法为：

原代码：

    class DBConn{
    public:
        ~DBConn(){
            db.close();
        }
    private:
        DBConnection db;
    }

修改后的代码：
    
    class DBConn{
    public:
        void close(){
            db.close();
            closed = true;
        }
    
        ~DBConn(){
            if(!closed){
                try{
                    db.close();
                }
                catch(...){
                    std::abort();
                }
            }
        }
    private:
        bool closed;
        DBConnection db;
    }
这种做法就可以一方面将close的的方法交给用户，另一方面在用户忽略的时候还能够做“强迫结束程序”或者“吞下异常”的操作。相比较而言，交给用户是最好的选择，因为用户有机会根据实际情况操作异常。

总结：
+ 析构函数不要抛出异常，因该在内部捕捉异常
+ 如果客户需要对某个操作抛出的异常做出反应，应该将这个操作放到普通函数（而不是析构函数）里面

**9. 绝不在构造和析构过程中调用virtual函数（Never call virtual functions during construction or destruction)**

主要是因为有继承的时候会调用错误版本的函数，例如

原代码：

    class Transaction{
    public:
        Transaction(){
            logTransaction();
        }
        Virtual void logTransaction const() = 0;
    };
    class BuyTransaction:public Transaction{
        public:
            virtual void logTransaction() const;
    };
    BuyTransaction b;
    
    或者有一个更难发现的版本：
    
    class Transaction{
    public:
        Transaction(){init();}
        virtual void logTransaction() const = 0;
    private:
        void init(){
            logTransaction();
        }
    };
这个时候代码会调用 Transaction 版本的logTransaction，因为在构造函数里面是先调用了父类的构造函数，所以会先调用父类的logTransaction版本，解决方案是不在构造函数里面调用，或者将需要调用的virtual弄成non-virtual的

修改以后：

    class Transaction{
    public:
        explicit Transaction(const std::string& logInfo);
        void logTransaction(const std::string& logInfo) const; //non-virtual 函数
    }
    Transaction::Transaction(const std::string& logInfo){
        logTransaction(logInfo); //non-virtual函数
    }
    class BuyTransaction: public Transaction{
    public:
        BuyTransaction(parameters):Transaction(createLogString(parameters)){...} //将log信息传递给base class 构造函数
    private:
        static std::string createLogString(parameters); //注意这个函数是用来给上面那个函数初始化数据的，这个辅助函数的方法
    }

总结：
+ 在构造和析构期间不要调用virtual函数，因为这类调用从不下降至派生类的版本

**10. 令operator= 返回一个reference to *this （Have assignment operators return a reference to *this)**

主要是为了支持连读和连写，例如：
    
    class Widget{
    public:
        Widget& operator=(int rhs){return *this;}
    }
    a = b = c;

**11. 在operator= 中处理“自我赋值” （Handle assignment to self in operator=)**

主要是要处理 a[i] = a[j] 或者 *px = *py这样的自我赋值。有可能会出现一场安全性问题，或者在使用之前就销毁了原来的对象，例如

原代码：
    
    class Bitmap{...}
    class Widget{
    private:
        Bitmap *pb;
    };
    Widget& Widget::operator=(const Widget& rhs){
        delete pb; // 当this和rhs是同一个对象的时候，就相当于直接把rhs的bitmap也销毁掉了
        pb = new Bitmap(*rhs.pb);
        return *this;
    }

修改后的代码

    class Widget{
        void swap(Widget& rhs);    //交换this和rhs的数据
    };
    Widget& Widget::operator=(const Widget& rhs){
        Widget temp(rhs)           //为rhs数据制作一个副本
        swap(temp);                //将this数据和上述副本数据交换
        return *this;
    }//出了作用域，原来的副本销毁

或者有一个效率不太高的版本：
    Widget& Widget::operator=(const Widget& rhs){
        Bitmap *pOrig = pb;       //记住原先的pb
        pb = new Bitmap(*rhs.pb); //令pb指向 *pb的一个副本
        delete pOrig;            //删除原先的pb
        return *this;
    }

总结：
+ 确保当对象自我赋值的时候operator=有比较良好的行为，包括两个对象的地址，语句顺序，以及copy-and-swap
+ 确定任何函数如果操作一个以上的对象，而其中多个对象可能指向同一个对象时，仍然正确

**12. 复制对象时勿忘其每一个成分 （Copy all parts of an object)**

总结：
+ 当编写一个copy或者拷贝构造函数，应该确保复制成员里面的所有变量，以及所有基类的成员
+ 不要尝试用一个拷贝构造函数调用另一个拷贝构造函数，如果想要精简代码的话，应该把所有的功能机能放到第三个函数里面，并且由两个拷贝构造函数共同调用
+ 当新增加一个变量或者继承一个类的时候，很容易出现忘记拷贝构造的情况，所以每增加一个变量都需要在拷贝构造里面修改对应的方法

#### 三、资源管理 (Resource Management)

**13. 以对象管理资源 （Use objects to manage resources)**

主要是为了防止在delete语句执行前return，所以需要用对象来管理这些资源。这样当控制流离开f以后，该对象的析构函数会自动释放那些资源。
例如shared_ptr就是这样的一个管理资源的对象。他是在自己的析构函数里面做delete操作。所以如果自己需要管理资源的时候，也要在类内进行delete，通过对象来管理资源

总结：
+ 建议使用shared_ptr
+ 如果需要自定义shared_ptr，请通过定义自己的资源管理类来对资源进行管理

**14. 在资源管理类中小心copying行为 （Think carefully about copying behavior in resource-managing classes)**

在资源管理类里面，如果出现了拷贝复制行为的话，需要注意这个复制具体的含义，从而保证和我们想要的效果一样

思考下面代码在复制中会发生什么：
    
    class Lock{
    public:
        explicit Lock(Mutex *pm):mutexPtr(pm){
            lock(mutexPtr);//获得资源锁
        }
        ~Lock(){unlock(mutexPtr);}//释放资源锁
    private:
        Mutex *mutexPtr;
    }
    Lock m1(&m)//锁定m
    Lock m2(m1);//好像是锁定m1这个锁。。而我们想要的是除了复制资源管理对象以外，还想复制它所包括的资源（deep copy）。通过使用shared_ptr可以有效避免这种情况。

需要注意的是：copy函数有可能是编译器自动创建出来的，所以在使用的时候，一定要注意自动生成的函数是否符合我们的期望

总结;
+ 复制RAII对象（Resource Acquisition Is Initialization）必须一并复制他所管理的资源（deep copy）
+ 普通的RAII做法是：禁止拷贝，使用引用计数方法

**15. 在资源管理类中提供对原始资源的访问（Provide access to raw resources in resource-managing classes)**

例如：shared_ptr<>.get()这样的方法，或者->和*方法来进行取值。但是这样的方法可能稍微有些麻烦，有些人会使用一个隐式转换，但是经常会出错：
    
    class Font; class FontHandle;
    void changeFontSize(FontHandle f, int newSize){    }//需要调用的API
    
    Font f(getFont());
    int newFontSize = 3;
    changeFontSize(f.get(), newFontSize);//显式的将Font转换成FontHandle
    
    class Font{
        operator FontHandle()const { return f; }//隐式转换定义
    }
    changeFontSize(f, newFontSize)//隐式的将Font转换成FontHandle
    但是容易出错，例如
    Font f1(getFont());
    FontHandle f2 = f1;就会把Font对象换成了FontHandle才能复制

总结：
+ 每一个资源管理类RAII都应该有一个直接获得资源的方法
+ 隐式转换对客户比较方便，显式转换比较安全，具体看需求

**16. 成对使用new和delete时要采取相同形式 （Use the same form in corresponding uses of new and delete)**

总结：
+ 即： 使用new[]的时候要使用delete[], 使用new的时候一定不要使用delete[]

**17. 以独立语句将new的对象置入智能指针 （Store newed objects in smart pointers in standalone statements)**

主要是会造成内存泄漏，考虑下面的代码：
    
    int priority();
    void processWidget(shared_ptr<Widget> pw, int priority);
    processWidget(new Widget, priority());// 错误，这里函数是explicit的，不允许隐式转换（shared_ptr需要给他一个普通的原始指针
    processWidget(shared_ptr<Widget>(new Widget), priority()) // 可能会造成内存泄漏
    
    内存泄漏的原因为：先执行new Widget，再调用priority， 最后执行shared_ptr构造函数，那么当priority的调用发生异常的时候，new Widget返回的指针就会丢失了。当然不同编译器对上面这个代码的执行顺序不一样。所以安全的做法是：
    
    shared_ptr<Widget> pw(new Widget)
    processWidget(pw, priority())

总结：
+ 凡是有new语句的，尽量放在单独的语句当中，特别是当使用new出来的对象放到智能指针里面的时候

#### 四、设计与声明 (Designs and Declarations)

**18. 让接口容易被正确使用，不易被误用  （Make interfaces easy to use correctly and hard to use incorrectly)**

要思考用户有可能做出什么样子的错误，考虑下面的代码：
    
    Date(int month, int day, int year);
    这一段代码可以有很多问题，例如用户将day和month顺序写反（因为三个参数都是int类型的），可以修改成：
    Date(const Month &m, const Day &d, const Year &y);//注意这里将每一个类型的数据单独设计成一个类，同时加上const限定符
    为了让接口更加易用，可以对month加以限制，只有12个月份
    class Month{
        public:
        static Month Jan(){return Month(1);}//这里用函数代替对象，主要是方式第四条：non-local static对象的初始化顺序问题
    }
    
    而对于一些返回指针的问题函数，例如：
    Investment *createInvestment();//智能指针可以防止用户忘记delete返回的指针或者delete两次指针，但是可能存在用户忘记使用智能指针的情况，那么方法：
    std::shared_ptr<Investment> createInvestment();就可以强制用户使用智能指针，或者更好的方法是另外设计一个函数：
    std::shared_ptr<Investment>pInv(0, get)

总结：
+ “促进正确使用”的办法包括接口的一致性，以及与内置类型的行为兼容
+ “阻止误用”的办法包括建立新类型、限制类型上的操作，束缚对象值，以及消除客户的资源管理责任
+ shared_ptr支持定制删除器，从而防范dll问题，可以用来解除互斥锁等

**19. 设计class犹如设计type  （Treat class design as type design)**

如何设计class：
+ 新的class对象应该被如何创建和构造
+ 对象的初始化和赋值应该有什么样的差别（不同的函数调用，构造函数和赋值操作符）
+ 新的class如果被pass by value（以值传递），意味着什么（copy构造函数）
+ 什么是新type的“合法值”（成员变量通常只有某些数值是有效的，这些值决定了class必须维护的约束条件）
+ 新的class需要配合某个继承图系么（会受到继承类的约束）
+ 新的class需要什么样的转换（和其他类型的类型变换）
+ 什么样的操作符和函数对于此type而言是合理的（决定声明哪些函数，哪些是成员函数）
+ 什么样的函数必须为private的 
+ 新的class是否还有相似的其他class，如果是的话就应该定义一个class template
+ 你真的需要一个新type么？如果只是定义新的derived class或者为原来的class添加功能，说不定定义non-member函数或者templates更好

**20. 以pass-by-reference-to-const替换pass-by-value  （Prefer pass-by-reference-to-const to pass-by-value)**

主要是可以提高效率，同时可以避免基类和子类的参数切割问题
    
    bool validateStudent(const Student &s);//省了很多构造析构拷贝赋值操作
    bool validateStudent(s);
    
    subStudent s;
    validateStudent(s);//调用后,则在validateStudent函数内部实际上是一个student类型，如果有重载操作的话会出现问题

对于STL等内置类型，还是以值传递好一些

**21. 必须返回对象时，别妄想返回其reference  （Don't try to return a reference when you must return an object)**

主要是很容易返回一个已经销毁的局部变量，如果想要在堆上用new创建的话，则用户无法delete，如果想要在全局空间用static的话，也会出现大量问题,所以正确的写法是：

    inline const Rational operator * (const Rational &lhs, const Rational &rhs){
        return Rational(lhs.n * rhs.n, lhs.d * rhs.d);
    }
当然这样写的代价就是成本太高，效率会比较低

**22. 将成员变量声明为private  （Declare data members private)**

应该将成员变量弄成private，然后用过public的成员函数来访问他们，这种方法的好处在于可以更精准的控制成员变量，包括控制读写，只读访问等。

同时，如果public的变量发生了改变，如果这个变量在代码中广泛使用，那么将会有很多代码遭到了破坏，需要重新写

另外protected 并不比public更具有封装性，因为protected的变量，在发生改变的时候，他的子类代码也会受到破坏

**23. 以non-member、non-friend替换member函数  （Prefer non-member non-friend functions to member functions)**

区别如下：
    
    class WebBrowser{
        public:
        void clearCache();
        void clearHistory();
        void removeCookies();
    }
    
    member 函数：
    class WebBrowser{
        public:
        ......
        void clearEverything(){ clearCache(); clearHistory();removeCookies();}
    }
    
    non-member non-friend函数：
    void clearBrowser(WebBrowser& wb){
        wb.clearCache();
        wb.clearHistory();
        wb.removeCookies();
    }

这里的原因是：member可以访问class的private函数，enums，typedefs等，但是non-member函数则无法访问上面这些东西，所以non-member non-friend函数更好

这里还提到了namespace的用法，namespace可以用来对某些便利函数进行分割，将同一个命名空间中的不同类型的方法放到不同文件中(这也是C++标准库的组织方式，例如：
    
    "webbrowser.h"
    namespace WebBrowserStuff{
        class WebBrowser{...};
        //所有用户需要的non-member函数
    }
    
    "webbrowserbookmarks.h"
    namespace WebBrowserStuff{
        //所有与书签相关的便利函数
    }

**24. 若所有参数皆需类型转换，请为此采用non-member函数  （Declare non-member functions when type conversions should apply to all parameters)**

例如想要将一个int类型变量和Rational变量做乘法，如果是成员函数的话，发生隐式转换的时候会因为不存在int到Rational的类型变换而出错：


    class Rational{
        public:
        const Rational operator* (const Rational& rhs)const;
    }
    Rational oneHalf;
    result = oneHalf * 2;
    result = 2 * oneHalf;//出错，因为没有int转Rational函数
    
    non-member函数
    class Rational{}
    const Rational operator*(const Rational& lhs, const Rational& rhs){}


**25. 考虑写出一个不抛异常的swap函数  （Consider support for a non-throwing swap)**

写出一个高效、不容易发生误会、拥有一致性的swap是比较困难的，下面是对比代码：

    修改前代码：
    class Widget{
        public:
        Widget& operator=(const Widget& rhs){
            *pImpl = *(rhs.pImpl);//低效
        }
        private:
        WidgetImpl* pImpl;
    }
    
    修改后代码：
    namespace WidgetStuff{
        template<typename T>
        class Widget{
            void swap(Widget& other){
                using std::swap;      //此声明是std::swap的一个特例化，
                swap(pImpl, other.pImpl);
            }
        };
        ...
        template<typename T>           //non-member swap函数
        void swap(Widget<T>& a, Widget<T>& b){//这里并不属于 std命名空间
            a.swap(b);
        }    
    }

总结：
+ 当std::swap对我们的类型效率不高的时候，应该提供一个swap成员函数，且保证这个函数不抛出异常（因为swap是要帮助class提供强烈的异常安全性的）
+ 如果提供了一个member swap，也应该提供一个non-member swap调用前者，对于classes（而不是templates），需要特例化一个std::swap
+ 调用swap时应该针对std::swap使用using std::swap声明，然后调用swap并且不带任何命名空间修饰符
+ 不要再std内加对于std而言是全新的东西（不符合C++标准）



#### 五、实现 (Implementations)


**26. 尽可能延后变量定义式的出现时间  （Postpone variable definitions as long as possible)**

主要是防止变量在定义以后没有使用，影响效率，应该在用到的时候再定义，同时通过default构造而不是赋值来初始化

**27. 尽量不要进行强制类型转换  （Minimize casting)**

主要是因为：

1.从int转向double容易出现精度错误

2.将一个类转换成他的父类也容易出现问题

总结：
+ 尽量避免转型，特别是在注重效率的代码中避免dynamic_cast，试着用无需转型的替代设计
+ 如果转型是必要的，试着将他封装到韩束背后，让用户调用该函数，而不需要在自己的代码里面转型
+ 如果需要转型，使用新式的static_cast等转型，比原来的（int）好很多（更明显，分工更精确）

**28. 避免返回handles指向对象内部成分  （Avoid returning "handles" to object internals)**

主要是为了防止用户误操作返回的值：
    
    修改前代码：
    class Rectangle{
        public:
        Point& upperLeft() const { return pData->ulhc; }
        Point& lowerRight() const { return pData->lrhc; }
    }
    如果修改成：
    class Rectangle{
        public:
        const Point& upperLeft() const { return pData->ulhc; }
        const Point& lowerRight() const { return pData->lrhc; }
    }
    则仍然会出现悬吊的变量，例如：
    const Point* pUpperLeft = &(boundingBox(*pgo).upperLeft());
boundingBox会返回一个temp的新的，暂时的Rectangle对象，在这一整行语句执行完以后，temp就变成空的了，就成了悬吊的变量

总结：
+ 尽量不要返回指向private变量的指针引用等
+ 如果真的要用，尽量使用const进行限制，同时尽量避免悬吊的可能性

**29. 为“异常安全”而努力是值得的  （Strive for exception-safe code)**

异常安全函数具有以下三个特征之一：
+ 如果异常被抛出，程序内的任何事物仍然保持在有效状态下，没有任何对象或者数据结构被损坏，前后一致。在任何情况下都不泄露资源，在任何情况下都不允许破坏数据，一个比较典型的反例：
+ 如果异常被抛出，则程序的状态不被改变，程序会回到调用函数前的状态
+ 承诺绝不抛出异常

    原函数：
    class PrettyMenu{
        public:
        void changeBackground(std::istream& imgSrc); //改变背景图像
        private:
        Mutex mutex; // 互斥器
    };

    void changeBackground(std::istream& imgSrc){
        lock(&mutex);               //取得互斥器
        delete bgImage;             //摆脱旧的背景图像
        ++imageChanges;             //修改图像的变更次数
        bgImage = new Image(imgSrc);//安装新的背景图像
        unlock(&mutex);             //释放互斥器
    }
当异常抛出的时候，这个函数就存在很大的问题：
+ 不泄露任何资源：当new Image(imgSrc)发生异常的时候，对unlock的调用就绝不会执行，于是互斥器就永远被把持住了
+ 不允许数据破坏：如果new Image(imgSrc)发生异常，bgImage就是空的，而且imageChanges也已经加上了
  
    修改后代码：
    void PrettyMenu::changeBackground(std::istream& imgSrc){
        Lock ml(&mutex);    //Lock是第13条中提到的用对象管理资源的类
        bgImage.reset(new Image(imgSrc));
        ++imageChanges; //放在后面
    }

总结：
+ 异常安全函数的三个特征
+ 第二个特征往往能够通过copy-and-swap实现出来，但是并非对所有函数都可实现或具备现实意义
+ 函数提供的异常安全保证，通常最高只等于其所调用各个函数的“异常安全保证”中最弱的那个。即函数的异常安全保证具有连带性

**30. 透彻了解inlining  （Understand the ins and outs of inlining)**

inline 函数的过度使用会让程序的体积变大，内存占用过高

而编译器是可以拒绝将函数inline的，不过当编译器不知道该调用哪个函数的时候，会报一个warning

尽量不要为template或者构造函数设置成inline的，因为template inline以后有可能为每一个模板都生成对应的函数，从而让代码过于臃肿
同样的道理，构造函数在实际的过程中也会产生很多的代码，例如下面的：
    
    class Derived : public Base{
        public:
        Derived(){} // 看起来是空白的构造函数
    }
    实际上：
    Derived::Derived{
        //100行异常处理代码
    }

**31. 将文件间的编译依存关系降至最低  （Minimize compilation dependencies between files)**

这个关系其实指的是一个文件包含另外一个文件的类定义等

那么如何实现解耦呢,通常是将实现定义到另外一个类里面，如下：
    
    原代码：
    class Person{
    private
        Dates m_data;
        Addresses m_addr;
    }
    
    添加一个Person的实现类，定义为PersonImpl，修改后的代码：
    class PersonImpl;
    class Person{
        private:
        shared_ptr<PersonImpl> pImpl;
    }

在上面的设计下,就实现了解耦，即“实现和接口分离”

与此相似的接口类还可以使用全虚函数
    
    class Person{
        public:
        virtual ~Person();
        virtual std::string name() const = 0;
        virtual std::string birthDate() const = 0;
    }
然后通过继承的子类来实现相关的方法

这种情况下这些virtual函数通常被成为factory工厂函数

总结：
+ 应该让文件依赖于声明而不依赖于定义，可以通过上面两种方法实现
+ 程序头文件应该有且仅有声明

#### 六、继承与面向对象设计 (Inheritance and Object-Oriented Design)

**32. 确定你的public继承塑模出is-a关系  （Make sure public inheritance models "is-a.")**

public类继承指的是单向的更一般化的，例如：
    
    class Student : public Person{...};

其意义指的是student是一个person，但是person不一定是一个student。

这里经常会出的错误是，将父类可能不存在的功能实现出来，例如：
    
    class Bird{
        virtual void fly();
    }
    class Penguin:public Bird{...};//企鹅是不会飞的

这个时候就需要通过设计来排除这种错误，例如通过定义一个FlyBird

总结：
+ public继承中，意味着每一个Base class的东西一定适用于他的derived class

**33. 避免遮掩继承而来的名称  （Avoid hiding inherited names)**

举例：
    class Base{
        public:
        virtual void mf1() = 0;
        virtual void mf1(int);
        virtual void mf2();
        void         mf3();
        void         mf3(double);
    }
    class Derived:public Base{
        public:
        virtual void mf1();
        void         mf3();
    }

这种问题可以通过 
    
    using Base::mf1;
    或者
    virtual void mf1(){//转交函数
        Base::mf1();
    }
    来解决，但是尽量不要出现这种遮蔽的行为

总结：
+ derived class 会遮蔽Base class的名称
+ 可以通过using 或者转交函数来解决

**34. 区分接口继承和实现继承  （Differentiate between inheritance of interface and inheritance of implementation)**

pure virtual 函数式提供了一个接口继承，当一个函数式pure virtual的时候，意味着所有的实现都在子类里面实现。不过pure virtual也是可以有实现的，调用他的实现的方法是在调用前加上基类的名称：
    
    class Shape{
        virtual void draw() const = 0;
    }
    ps->Shape::draw();
总结：
+ 接口继承和实现继承不同，在public继承下，derived classes总是继承base的接口
+ pure virtual函数只具体指定接口继承
+ 简朴的（非纯）impure virtual函数具体指定接口继承以及缺省实现继承
+ non-virtual函数具体指定接口继承以及强制性的实现继承

**35. 考虑virtual函数以外的其他选择  （Consider alternatives to virtual functions)**

NVI手法：通过public non-virtual成员函数间接调用private virtual函数，即所谓的template method设计模式：

    class GameCharacter{
    public:
        int healthValue() const{
            //做一些事前工作
            int retVal = doHealthValue();
            //做一些事后工作
            return retVal;
        }
    private:
        virtual int doHealthValue() const{
            ...                   //缺省算法，计算健康函数
        }
    }
这种方法的优点在于事前工作和事后工作，这些工作能够保证virtual函数在真正工作之前之后被单独调用

但是这种方法只是一种替代方法，另外的方法还有：函数指针（strategy设计模式

    class GameCharacter; // 前置声明
    int defaultHealthCalc(const GameCharacter& gc);
    class GameCharacter{
    public:
        typedef int (*HealthCalcFunc)(const GameCharacter&);//函数指针
        explicit GameCHaracter(HealthCalcFunc hcf = defaultHealthCalc):healthFunc(hcf){}//可以换一个函数的
        int healthValue()const{return healthFunc(*this);}
    private:
        HealthCalcFunc healthFunc;
    }
    
    如果将函数指针换成函数对象的话，会有更具有弹性的效果：
    
    typedef std::tr1::function<int (const GameCharacter&)> HealthCalcFunc;
    在这种情况下，HealthCalcFunc是一个typedef，他的行为更像一个函数指针，表示“接受一个reference指向const GameCharacter，并且返回int*”，

总结：这一节表示当我们为了解决问题而寻找某个特定设计方法时，不妨考虑virtual函数的替代方案
+ 使用NVI手法，他是用public non-virtual成员函数包裹较低访问性（private和protected）的virtual函数
+ 将virtual函数替换成“函数指针成员变量”，这是strategy设计模式的一种表现形式
+ 以tr1::function成员变量替换virtual函数，因而允许使用任何可调用物（callable entity）搭配一个兼容与需求的签名式
+ 将继承体系内的virtual函数替换成另一个继承体系内的virtual函数

+ 将机能从成员函数移到class外部函数，带来的一个缺点是：非成员函数无法访问class的non-public成员
+ tr1::function对象就像一般函数指针，这样的对象可接纳“与给定之目标签名式兼容”的所有可调用物（callable entities）

**36. 绝不重新定义继承而来的non-virtual函数  （Never redefine an inherited non-virtual function)**

主要是考虑一下的代码：
    class B{
    public:
        void mf();
    }
    class D : public B{
    public:
        void mf();
    };

    D x;
    
    B *pB = &x; pB->mf(); //调用B版本的mf
    D *pD = &x; pD->mf(); // 调用D版本的mf

即使不考虑这种代码层的差异，如果这样重定义的话，也不符合之前的“每一个D都是一个B”的定义

**37. 绝不重新定义继承而来的缺省参数值  （Never redefine a function's inherited default parameter value)**

原代码：
    
    class Shape{
    public:
        enum ShapeColor {Red, Green, Blue};
        virtual void draw(ShapeColor color=Red)const = 0;
    };
    class Rectangle : public Shape{
    public:
        virtual void draw(ShapeColor color=Green)const;//和父类的默认参数不同
    }
    Shape* pr = new Rectangle; // 注意此时pr的静态类型是Shape，但是他的动态类型是Rectangle
    pr->draw(); //virtual函数是动态绑定，而缺省参数值是静态绑定，所以会调用Red

**38. 通过复合塑模出has-a或"根据某物实现出"  （Model "has-a" or "is-implemented-in-terms-of" through composition)**

复合：一个类里面有另外一个类的成员，那么这两个类的成员关系就叫做复合（或称聚合，内嵌，内含等）。
我们认为复合的关系是“has a”的概念，

例如：set并不是一个list，但是set可以has a list：
    
    template<class T>
    class Set{
    public: 
        void insert();
        //.......
    private:
        std::list<T> rep;
    }

总结：
+ 复合（composition）的意义和public继承完全不同
+ 在应用域（application domain），复合意味着has a，在实现域（implementation domain），复合意味着 is implemented-in-terms-of

**39. 明智而审慎地使用private继承  （Use private inheritance judiciously)**

因为private继承并不是is-a的关系，即有一部分父类的private成员是子类无法访问的，而且经过private继承以后，子类的所有成员都是private的，意思是is implemented in terms of（根据某物实现出），有点像38条的复合。所以大部分时间都可以用复合代替private继承。

当我们需要两个并不存在“is a”关系的类，同时一个类需要访问另一个类的protected成员的时候，我们可以使用private继承

总结：
+ private 继承意味着is implemented in terms of， 通常比复合的级别低，但是当derived class 需要访问protect base class 的成员，或者需要重新定义继承而来的virtual函数时，这么设计是合理的。
+ 和复合不同，private继承可以造成empty base最优化，这对致力于“对象尺寸最小化”的程序库开发者而言，可能很重要

**40. 明智而审慎地使用多重继承  （Use multiple inheritance judiciously)**

多重继承很容易造成名字冲突：
    
    class BorrowableItem{
        public:
        void checkOut();
    };
    class ElectronicGadget{
        bool checkOut()const;
    };
    class MP3Player:public BorrowableItem, public ElectronicGadget{...};
    MP3Player mp;
    mp.checkOut();//歧义，到底是哪个类的函数
    只能使用：
    mp.BorrowableItem::checkOut();

在实际应用中, 经常会出现两个类继承与同一个父类，然后再有一个类多继承这两个类：
    
    class Parent{...};
    class First : public Parent(...);
    class Second : public Parent{...};
    class last:public First, public Second{...};
当然，多重继承也有他合理的用途，例如一个类刚好继承自两个类的实现。

总结：
+ 多重继承容易产生歧义
+ virtual继承会增加大小、速度、初始化复杂度等成本，如果virtual base class不带任何数据，将是最具使用价值的情况
+ 多重继承的使用情况：当一个类是“public 继承某个interface class”和“private 继承某个协助实现的class”两个相结合的时候。

#### 七、模板与泛型编程 (Templates and Generic Programming)

**41. 了解隐式接口和编译期多态 （Understand implicit interfaces and compile-time polymorphism)**

对于面向对象编程：以显式接口（explicit interfaces）和运行期多态（runtime polymorphism）解决问题：
    
    class Widget {
    public:
        Widget();
        virtual ~Widget();
        virtual std::size_t size() const;
        void swap(Widget& other); //第25条
    }
    
    void doProcessing(Widget& w){
        if(w.size()>10){...}
    }

+ 在上面这段代码中，由于w的类型被声明为Widget，所以w必须支持Widget接口，我们可以在源码中找出这个接口，看看他是什么样子（explicit interface），也就是他在源码中清晰可见
+ 由于Widget的某些成员函数是virtual，w对于那些函数的调用将表现运行期多态，也就是运行期间根据w的动态类型决定调用哪一个函数

在templete编程中：隐式接口（implicit interface）和编译器多态（compile-time polymorphism）更重要：
    
    template<typename T>
    void doProcessing(T& w)
    {
        if(w.size()>10){...}
    }
+ 在上面这段代码中，w必须支持哪一种接口，由template中执行于w身上的操作来决定，例如T必须支持size等函数。这叫做隐式接口
+ 凡涉及到w的任何函数调用，例如operator>，都有可能造成template具现化，使得调用成功，根据不同的T调用具现化出来不同的函数，这叫做编译期多态

**42. 了解typename的双重意义 （Understand the two meanings of typename)**

下面一段代码：
    
    template<typename C>
    void print2nd(const C& container){
        if(container.size() >=2)
            typename C::const_iterator iter(container.begin());//这里的typename表示C::const_iterator是一个类型名称，
                                                               //因为有可能会出现C这个类型里面没有const_iterator这个类型
                                                               //或者C这个类型里面有一个名为const_iterator的变量
    }
所以，在任何时候想要在template中指定一个嵌套从属类型名称（dependent names，依赖于C的类型名称），前面必须添加typename

+ 声明template参数时，前缀关键字class和typename是可以互换的
+ 需要使用typename标识嵌套从属类型名称，但不能在base class lists（基类列）或者member initialization list（成员初始列）内以它作为base class修饰符 
  
    template<typename T>
    class Derived : public typename Base<T> ::Nested{}//错误的！！！！！

**43. 学习处理模板化基类内的名称 （Know how to access names in templatized base classes)**

原代码：
    
    class CompanyA{
    public:
        void sendCleartext(const std::string& msg);
        ....
    }
    class CompanyB{....}
    
    template <typename Company>
    class MsgSender{
    public:
        void sendClear(const MsgInfo& info){
            std::string msg;
            Company c;
            c.sendCleartext(msg);
        }
    }
    template<typename Company>//想要在发送消息的时候同时写入log，因此有了这个类
    class LoggingMsgSender:public MsgSender<Company>{
        public:
        void sendClearMsg(const MsgInfo& info){
            //记录log
            sendClear(info);//无法通过编译，因为找不到一个特例化的MsgSender<company>
        }
    }

解决方法1（认为不是特别好）：

    template <> // 生成一个全特例化的模板
    class MsgSender<CompanyZ>{  //和一般的template，但是没有sendClear,当Company==CompanyZ的时候就没有sendClear了
    public:
        void sendSecret(const MsgInfo& info){....}
    }

解决方法2（使用this）：

    template<typename Company>
    class LoggingMsgSender:public MsgSender<Company>{
        public:
        void sendClearMsg(const MsgInfo& info){
            //记录log
            this->sendClear(info);//假设sendClear将被继承
        }
    }

解决方法3（使用using）：

    template<typename Company>
    class LoggingMsgSender:public MsgSender<Company>{
        public:
    
        using MsgSender<Company>::sendClear; //告诉编译器，请他假设sendClear位于base class里面
    
        void sendClearMsg(const MsgInfo& info){
            //记录log
            sendClear(info);//假设sendClear将被继承
        }
    }

解决方法4（指明位置）：

    template<typename Company>
    class LoggingMsgSender:public MsgSender<Company>{
        public:
        void sendClearMsg(const MsgInfo& info){
            //记录log
            MsgSender<Company>::sendClear(info);//假设sendClear将被继承
        }
    }

上面那些做法都是对编译器说：base class template的任何特例化版本都支持其一般版本所提供的接口

**44. 将与参数无关的代码抽离templates （Factor parameter-independent code out of templates)**

主要是会让编译器编译出很长的臃肿的二进制码，所以要把参数抽离，看以下代码：
    
    template<typename T, std::size_t n>
    class SquareMatrix{
        public:
        void invert();    //求逆矩阵
    }
    
    SquareMatrix<double, 5> sm1;
    SquareMatrix<double, 10> sm2;
    sm1.invert(); 
    sm2.invert(); //会具现出两个invert并且基本完全相同

修改后的代码：
    
    template<typename T>
    class SquareMatrixBase{
        protected:
        void invert(std::size_t matrixSize);
    }
    
    template<typename T, std::size_t n>
    class SquareMatrix:private SquareMatrixBase<T>{
        private:
        using SquareMatrixBase<T>::invert;  //避免遮掩base版的invert
        public:
        void invert(){ this->invert(n); }   //一个inline调用，调用base class版的invert
    }

当然因为矩阵数据可能会不一样，例如5x5的矩阵和10x10的矩阵计算方式会不一样，输入的矩阵数据也会不一样，采用指针指向矩阵数据的方法会比较好：
    
    template<typename T, std::size_t n>
    class SquareMatrix:: private SquareMatrixBase<T>{
        public:
        SquareMatrix():SquareMatrixBase<T>(n, 0), pData(new T[n*n]){
            this->setDataPtr(pData.get());
        }
        private:
        boost::scoped_array<T> pData; //存在heap里面
    };

总结：
+ templates生成多个classes和多个函数，所以任何template代码都不该与某个造成膨胀的template参数产生依赖关系
+ 因非类型模板参数（non-type template parameters）而造成的代码膨胀，往往可以消除，做法是以函数参数后者class成员变量替换template参数
+ 因类型参数（type parameters）而造成的代码膨胀，往往可以降低，做法是让带有完全相同的二进制表述的具现类型，共享实现码

**45. 运用成员函数模板接受所有兼容类型 （Use member function templates to accept "all compatible types.")**

    Top* pt2 = new Bottom; //将Bottom*转换为Top*是很容易的
    template<typename T>
    class SmartPtr{
        public:
        explicit SmartPtr(T* realPtr);
    };
    SmartPtr<Top> pt2 = SmartPtr<Bottom>(new Bottom);//将SmartPtr<Bottom>转换成SmartPtr<Top>是有些麻烦的

但是我们只是希望SmartPtr<Bottom>转换成SmartPtr<Top>，而不希望SmartPtr<Top>转换成SmartPtr<Bottom>
这种需求可以通过构造模板来实现：
    
    template<typename T>
    class SmartPtr{
    public:
        template<typename U>
        SmartPtr(const SmartPtr<U>& other)  //为了生成copy构造函数
            :heldPtr(other.get()){....}
        T* get() const { return heldPtr; }
    private:
        T* heldPtr;                        //这个SmartPtr持有的内置原始指针
    };

总结:
+ 使用成员函数模板生成“可接受所有兼容类型”的函数
+ 如果还想泛化copy构造函数、操作符重载等，同样需要在前面加上template

**46. 需要类型转换时请为模板定义非成员函数 （Define non-member functions inside templates when type conversions are desired)**

像第24条一样，当我们进行混合类型算术运算的时候，会出现编译通过不了的情况
    
    template<typename T>
    const Rational<T> operator* (const Rational<T>& lhs, const Rational<T>& rhs){....}
    
    Rational<int> oneHalf(1, 2);
    Rational<int> result = oneHalf * 2; //错误，无法通过编译

解决方法：使用friend声明一个函数,进行混合式调用
    
    template<typename T>
    class Rational{
        public:
        friend const Rational operator*(const Rational& lhs, const Rational& rhs){
            return Rational(lhs.numerator()*rhs.numerator(), lhs.denominator() * rhs.denominator());
        }
    };
    template<typename T>
    const Rational<T> operator*(const Rational<T>& lhs, const Rational<T>&rhs){....}

总结：
+ 当我们编写一个class template， 而他所提供的“与此template相关的”函数支持所有参数隐形类型转换时，请将那些函数定义为classtemplate内部的friend函数

**47. 请使用traits classes表现类型信息 （Use traits classes for information about types)**

traits是一种允许你在编译期间取得某些类型信息的技术，或者受是一种协议。这个技术的要求之一是：他对内置类型和用户自定义类型的表现必须是一样的。
    
    template<typename T>
    struct iterator_traits;  //迭代器分类的相关信息
                             //iterator_traits的运作方式是，针对某一个类型IterT，在struct iterator_traits<IterT>内一定声明//某个typedef名为iterator_category。这个typedef 用来确认IterT的迭代器分类
    一个针对deque迭代器而设计的class大概是这样的
    template<....>
    class deque{
        public:
        class iterator{
            public:
            typedef random_access_iterator_tag iterator_category;
        }
    }
    对于用户自定义的iterator_traits，就是有一种“IterT说它自己是什么”的意思
    template<typename IterT>
    struct iterator_traits{
        typedef typename IterT::iterator_category iterator_category;
    }
    //iterator_traits为指针指定的迭代器类型是：
    template<typename IterT>
    struct iterator_traits<IterT*>{
        typedef random_access_iterator_tag iterator_category;
    }

综上所述，设计并实现一个traits class：
+ 确认若干你希望将来可取得的类型相关信息，例如对迭代器而言，我们希望将来可取得其分类
+ 为该信息选择一个名称（例如iterator_category）
+ 提供一个template和一组特化版本（例如iterator_traits)，内含你希望支持的类型相关信息

在设计实现一个traits class以后，我们就需要使用这个traits class：
    
    template<typename IterT, typename DistT>
    void doAdvance(IterT& iter, DistT d, std::random_access_iterator_tag){ iter += d; }//用于实现random access迭代器
    template<typename IterT, typename DistT>
    void doAdvance(IterT& iter, DistT d, std::bidirectional_iterator_tag){ //用于实现bidirectional迭代器
        if(d >=0){
            while(d--)
                ++iter;
        }
        else{
            while(d++)
                --iter;
        }
    }
    
    template<typename IterT, typename DistT>
    void advance(IterT& iter, DistT d){
        doAdvance(iter, d, typename std::iterator_traits<IterT>::iterator_category());
    }
使用一个traits class:
+ 建立一组重载函数（像劳工）或者函数模板（例如doAdvance），彼此间的差异只在于各自的traits参数，令每个函数实现码与其接受traits信息相应
+ 建立一个控制函数（像工头）或者函数模板（例如advance），用于调用上述重载函数并且传递traits class所提供的信息

**48. 认识template元编程 （Be aware of template metaprogramming)**

Template metaprogramming是编写执行于编译期间的程序，因为这些代码运行于编译器而不是运行期，所以效率会很高，同时一些运行期容易出现的问题也容易暴露出来
    
    template<unsigned n>
    struct Factorial{
        enum{
            value = n * Factorial<n-1>::value
        };
    };
    template<>
    struct Factorial<0>{
        enum{ value = 1 };
    };                       //这就是一个计算阶乘的元编程


#### 八、定制new和delete (Customizing new and delete)

**49. 了解new-handler的行为 （Understand the behavior of the new-handler)**

当new无法申请到新的内存的时候，会不断的调用new-handler，直到找到足够的内存,new_handler是一个错误处理函数：
    namespace std{
        typedef void(*new_handler)();
        new_handler set_new_handler(new_handler p) throw();
    }

一个设计良好的new-handler要做下面的事情：
+ 让更多内存可以被使用
+ 安装另一个new-handler，如果目前这个new-handler无法取得更多可用内存，或许他知道另外哪个new-handler有这个能力，然后用那个new-handler替换自己
+ 卸除new-handler
+ 抛出bad_alloc的异常
+ 不返回，调用abort或者exit

new-handler无法给每个class进行定制，但是可以重写new运算符，设计出自己的new-handler
此时这个new应该类似于下面的实现方式：
    
    void* Widget::operator new(std::size_t size) throw(std::bad_alloc){
        NewHandlerHolder h(std::set_new_handler(currentHandler));      // 安装Widget的new-handler
        return ::operator new(size);                                   //分配内存或者抛出异常，恢复global new-handler
    }

总结：
+ set_new_handler允许客户制定一个函数，在内存分配无法获得满足时被调用
+ Nothrow new是一个没什么用的东西

**50. 了解new和delete的合理替换时机 （Understand when it makes sense to replace new and delete)**

+ 用来检测运用上的错误，如果new的内存delete的时候失败掉了就会导致内存泄漏，定制的时候可以进行检测和定位对应的失败位置
+ 为了强化效率（传统的new是为了适应各种不同需求而制作的，所以效率上就很中庸）
+ 可以收集使用上的统计数据
+ 为了增加分配和归还内存的速度
+ 为了降低缺省内存管理器带来的空间额外开销
+ 为了弥补缺省分配器中的非最佳对齐位
+ 为了将相关对象成簇集中起来

**51. 编写new和delete时需固守常规（Adhere to convention when writing new and delete)**

+ 重写new的时候要保证49条的情况，要能够处理0bytes内存申请等所有意外情况
+ 重写delete的时候，要保证删除null指针永远是安全的

**52. 写了placement new也要写placement delete（Write placement delete if you write placement new)**

如果operator new接受的参数除了一定会有的size_t之外还有其他的参数，这个就是所谓的palcement new

void* operator new(std::size_t, void* pMemory) throw(); //placement new
static void operator delete(void* pMemory) throw();     //palcement delete，此时要注意名称遮掩问题

#### 杂项讨论 (Miscellany)

**53. 不要轻忽编译器的警告（Pay attention to compiler warnings)**

+ 严肃对待编译器发出的warning， 努力在编译器最高警告级别下无warning
+ 同时不要过度依赖编译器的警告，因为不同的编译器对待事情的态度可能并不相同，换一个编译器警告信息可能就没有了

**54. 让自己熟悉包括TR1在内的标准程序库 （Familiarize yourself with the standard library, including TR1)**

其实感觉这一条已经有些过时了，不过虽然过时，但是很多地方还是有用的
+ smart pointers
+ tr1::function ： 表示任何callable entity（可调用物，只任何函数或者函数对象）
+ tr1::bind是一种stl绑定器
+ Hash tables例如set，multisets， maps等
+ 正则表达式
+ tuples变量组
+ tr1::array：本质是一个STL化的数组
+ tr1::mem_fn:语句构造上与程艳函数指针一样的东西
+ tr1::reference_wrapper： 一个让references的行为更像对象的东西
+ 随机数生成工具
+ type traits

**55. 让自己熟悉Boost （Familiarize yourself with Boost)**

主要是因为boost是一个C++开发者贡献的程序库，代码相对比较好
