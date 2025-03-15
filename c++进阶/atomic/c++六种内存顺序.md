
指令重排问题

有时候，我们会用一个变量作为标志位，当这个变量等于某个特定值的时候就进行某些操作。但是这样依然可能会有一些意想不到的坑，例如两个线程以如下顺序执行：

step	thread A	thread B
1	a = 1	
2	flag= true	
3		if flag== true
4		assert(a == 1)
当B判断flag为true后，断言a为1，看起来的确是这样。那么一定是这样吗？可能不是，因为编译器和CPU都可能将指令进行重排。实际上的执行顺序可能变成这样：

step	thread A	thread B
1	flag = true	
2		if flag== true
3		assert(a == 1)
4	a = 1	
这就导致了step3的时候断言失败。

为什么编译器和CPU在执行时会对指令进行重排呢？

因为现代CPU采用多发射技术（同时有多条指令并行）、流水线技术，为了避免流水线断流，CPU会进行适当的指令重排。这在计算机组成原理的流水线一节有所涉及，如果是单线程任务，那么一切正常，CPU和编译器对代码顺序调换是符合程序逻辑的，不会出错。但一到多线程编程中，结果就可能如上例所示。

C++11引入了非常重要的内存顺序概念，用以解决上述指令重排问题。

实际上，之前介绍的atomic类型的成员函数有一个额外参数，以store为例：

 void store( T desired, std::memory_order order = std::memory_order_seq_cst )
这个参数代表了该操作使用的内存顺序，用于控制变量在不同线程见的顺序可见性问题，不只store，其他成员函数也带有该参数。

c++11提供了六种内存顺序供选择：

 typedef enum memory_order {
  memory_order_relaxed,
  memory_order_consume,
  memory_order_acquire,
  memory_order_release,
  memory_order_acq_rel,
  memory_order_seq_cst
 } memory_order;
之前在场景2中，因为指令的重排导致了意料之外的错误，通过使用原子变量并选择合适内存序，可以解决这个问题。下面先来看看这几种内存序

memory_order_release/memory_order_acquire
memory_order_release用于store成员函数。
在本行代码之前，如果有任何写内存的操作，都是不能放到本行语句之后的。
简单地说，就是写不后。即，写语句不能调到本条语句之后。
memory_order_acquire用于load成员函数
就是读不前
举个例子：

假设flag为一个 atomic特化的bool 原子量，a为一个int变量，并且有如下时序的操作：

step	thread A	thread B
1	a = 1	
2	flag.store(true, memory_order_release)	
3		if( true == flag.load(memory_order_acquire))
4		assert(a == 1)
在这种情况下，step1不会跑到step2后面去，step4不会跑到step3前面去。

这样一来，保证了当读取到flag为true的时候a一定已经被写入为1了。

换一种比较严谨的描述方式可以总结为：对于同一个原子量，release操作前的写入，一定对随后acquire操作后的读取可见。 这两种内存序是需要配对使用的，这也是将他们放在一起介绍的原因。

还有一点需要注意的是：只有对同一个原子量进行操作才会有上面的保证，比如step3如果是读取了另一个原子量flag2，是不能保证读取到a的值为1的。

memory_order_release/memory_order_consume
memory_order_release还可以和memory_order_consume搭配使用。

memory_order_release的作用跟上面介绍的一样。
memory_order_consume用于load操作。
这个组合比上一种更宽松，comsume只阻止对这个原子量有依赖的操作重拍到前面去，而非像aquire一样全部阻止。

comsume操作防止在其后对原子变量有依赖的操作被重排到前面去，对无依赖的操作不做限定。这种情况下：对于同一个原子变量，release操作所依赖的写入，一定对随后consume操作后依赖于该原子变量的操作可见。

将上面的例子稍加改造来展示这种内存序，假设flag为一个 atomic特化的bool 原子量，a为一个int变量，b、c各为一个bool变量，并且有如下时序的操作：

step	thread A	thread B
1	b = true	
2	a = 1	
3	flag.store(b, memory_order_release)	
4		while (!(c = flag.load(memory_order_consume)))
5		assert(a == 1)
6		assert(c == true)
7		assert(b == true)
step4使得c依赖于flag，所以step6断言成功。

由于flag依赖于b，b在之前的写入是可见的，此时b一定为true，所以step7的断言一定会成功。而且这种依赖关系具有传递性，假如b又依赖与另一个变量d，则d在之前的写入同样对step4之后的操作可见。

那么a呢？很遗憾在这种内存序下a并不能得到保证，step5的断言可能会失败。

memory_order_acq_rel
这个选项看名字就很像release和acquire的结合体，实际上它的确兼具两者的特性。

这个操作用于“读取-修改-写回”这一类既有读取又有修改的操作，例如CAS操作。可以将这个操作在内存序中的作用想象为将release操作和acquire操作捆在一起，因此任何读写操作的重排都不能跨越这个调用。

依然以一个例子来说明，flag为一个 atomic特化的bool 原子量，a、c各为一个int变量，b为一个bool变量：

step	thread A	thread B
1	a = 1	
2	flag.store(true, memory_order_release)	
3		b = true
4		c = 2
5		while (!flag.compare_exchange_weak(b, false, memory_order_acq_rel)) {b = true}
6		assert(a == 1)
7	if (true == flag.load(memory_order_acquire)	
8	assert(c == 2)	
由于memory_order_acq_rel同时具有memory_order_release与memory_order_acquire的作用，因此step2可以和step5组合成上面提到的release/acquire组合，因此step6的断言一定会成功，而step5又可以和step7组成release/acquire组合，step8的断言同样一定会成功。

memory_order_seq_cst
该内存顺序是各个成员函数的内存顺序的默认选项。

它是最严格的内存顺序，一句话说就是：在这条语句的时候 所有这条指令前面的语句不能放到后面，所有这条语句后面的语句不能放到前面来执行。

memory_order_relaxed
这个选项如同其名字——自由。它仅仅只保证其成员函数操作本身是原子不可分割的，但是对于顺序性不做任何保证。