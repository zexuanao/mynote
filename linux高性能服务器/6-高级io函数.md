# pipe函数
用于创建管道，以实现进程间通信
```
#include <unistd.h>
int pipe(int fd[2])
```
fd0只能读出数据fd1只能写入数据
默认情况下，这一对文件描述符是阻塞的
read和write都会被阻塞

可以使用函数快速实现双通道
```
#include<sys/types.h>
#include<sys/socket.h>
int socketpair(int domain,int type,int protocol,int fd[2]);
```
domain只能是AF_UNIX因为只能本地使用双向通道
# dup函数和dup2函数
```
#include<unistd.h>
int dup(int file_descriptor);
int dup2(int file_descriptor_one,int file_descriptor_two);
```
用于复制文件描述符的
 dup总是取当前可用的最小值
 dup总是取第一个不小于`file_descriptor_two`的值
 
 先close（STDOUT_FILENO）关闭掉标准输出（1）
 dup到accept的，即对方的描述符
 因为总是使用最小的，所以会直接使用标准
 # readv函数和writev函数
 ```
#include<sys/uio.h>
ssize_t readv(int fd,const struct iovec* vector,int count);
ssize_t writev(int fd,const struct iovec* vector,int count);
```
他们可以实现分散读和集中写
vector是iovec结构数组
count是数组长度
相当于简化版的recvmsg和sendmsg函数
# sendfile函数
可以在两个文件描述符之间传递数据，完全内核造操作，避免了数据拷贝
```
#include<sys/sendfile.h>
ssize_t sendfile(int out_fd,int in_fd,off_t * offset,size_t count);
```
offset指定了从哪里开始读
count指定了传输的字节数
# mmap函数和munmap函数
```
#include<sys/mman.h>
void* mmap (void* start,size_t length,int prot,int flags,int fd,off_t offset);
int munmap(void* start,size_t length);
```
mmap用于申请一段内存空间，可以将这段内存作为进程通信的共享内存，也可以将文件直接映射进去，munmap则是用来释放
start用于指定开始的地址
prot用来设置内存段的访问权限：
1. PROT_READ
2. PROT_WRITE
3. PROT_EXEC
4. PROC_NONE
flag参数控制内存段内内容被修改后程序的行为
1. MAP_SHARED   共享
2. MAP_PRIVATE  私有
3. MAP_ANONYMOUS    不是从文件映射而来，后两个参数被忽略
4. MAP_FIXED
5. MAP_HUGETLB
fd是被映射文件对应的文件描述符，一般使用open打开获得
offset为偏移量
# splice函数
用于两个文件描述符之间移动数据
```
#include<fcntl.h>
ssize_t splice (int fd_in,loff_t* off_in,int fd_out,loff_t* off_out,size_t len,unsigned int flags);
```
`fd_in`是待输入数据的文件描述符，如果是一个管道文件描述符，那么`off_in`必须被设置为NULL，如果不是，那么off_in表示偏移量，后面两个参数和前面一样，不过是用于输出流
len指定移动数据的长度
flags控制数据如何移动：
常用值|含义
---|---
SPLICE_F_MOVE|没有效果
SPLICE_F_NONBLOCK|非阻塞的splice操作，实际上还是会受文件描述符本身的阻塞状态的影响
SPLICE_F_MORE|后续的splice调用将读取更多数据
SPLICE_F_GIDT|没有效果
使用管道可以实现零拷贝的回射服务器
splice(connfd,NULL,fd[1],NULL,....);
splice(fd[0],NULL,connfd,NULL...);
# tee函数
用于两个管道文件描述符之间复制数据，零拷贝操作
```
#include<fcntl.h>
ssize_t tee(int fd_in,int fd_out,unsigned int flags);
```
该函数的参数的含义与splice相同，但是必须要都是管道文件描述符

# fcntl函数
提供了对文件描述符的各种控制操作
另一个是ioctl，而且方法比fcntl更多，但是fcntl是POSIX规范指定的首选方法
```
#include<fcntl.h>
int fcntl(int fd,int cmd,...);
```
fd是被操作的文件描述符，cmd指定执行何种类型的操作
根据操作类型的不同，可能还需要第三个可选参数arg
1.复制一个现有的描述符（cmd=`F_DUPFD`）.
2.获得／设置文件描述符标记(cmd=`F_GETFD`或`F_SETFD`).
3.获得／设置文件状态标记(cmd=`F_GETFL`或`F_SETFL`).
4.获得／设置异步I/O所有权(cmd=`F_GETOWN`或`F_SETOWN`).
5.获得／设置记录锁(cmd=`F_GETLK`,`F_SETLK`或`F_SETLKW`).

文件状态标志如下表：

文件状态标志	|说明	                |十六进制值
---|---|---
O_RDONLY	    |只读打开            	|0x0
O_WRONLY	    |只写打开            	|0x1
O_RDWR	        |读、写打开          	|0x2
O_APPEND	    |追加写	                |0x400
O_NONBLOCK	    |非阻塞模式	            |0x800
O_SYNC	        |等待写完成（数据和属性)	|0x
O_DSYNC	        |等待写完成（仅数据)	|
O_RSYNC	        |同步读和写	|
O_FSYNC	        |等待写完成	|
O_ASYNC	        |异步IO	                |0x2000
SIGIO和SIGURG信号必须与某个文件描述符关联才能使用
文件描述符可读或可写就会触发SIGIO信号
有带外数据可读就出发SIGURG信号
关联文件描述符和文件的方法就是使用fcntl指定宿主进程
使用SIGIO时，还需要设置O_ASYNC 异步io标志
# 补充：dup的作用
dup() 函数是 UNIX 和类 UNIX 系统中的一个系统调用，用于复制文件描述符。它的主要作用是复制一个现有的文件描述符，并返回一个新的文件描述符，该文件描述符指向与原始文件描述符相同的文件或资源。这个新的文件描述符与原始文件描述符指向相同的文件表项，因此对其中一个文件描述符的操作也会影响另一个。

主要用途包括：

重定向标准输入/输出： 在进行输入/输出重定向时，可以使用 dup() 来复制标准输入、标准输出或标准错误文件描述符，并将其重定向到其他文件或管道上。

避免文件描述符的竞争条件： 在多线程或多进程环境中，使用 dup() 可以避免因为共享文件描述符而导致的竞争条件。

创建管道： 在创建管道时，常常需要使用 dup() 函数来复制管道的文件描述符，以确保在子进程中也可以正确引用管道的读写端。

关闭文件描述符的安全操作： 有时候需要在某些条件下关闭文件描述符，但是又希望保留对原始文件描述符的引用。这时可以先使用 dup() 复制一个副本，然后关闭原始文件描述符。

使用 dup() 可以灵活地操作文件描述符，实现输入/输出的重定向、文件描述符的传递等功能。


物理形式上：
unix上文件描述符指向一个数据结构，这个数据结构保存了指向文件的偏移量，为保存内容等等
dup说是复制
其实只是让文件描述符指向同一个数据结构
这样就不会发生两个文件描述符指向同一个文件但是发生数据覆盖等不想看见的场景
# 补充：unix进程间通信
方式|说明
---|---
管道 |pipe()用于父子进程间通信(不考虑传递描述符)
FIFO（有名管道）|非父子进程也能使用,以文件打通
文件 | 文件操作，效率可想而知
本地套接字  | 最稳定,也最复杂.套接字采用Unix域
共享内存| 传递最快,消耗最小,传递数据过程不涉及系统调用
信号|  数据固定且短小
