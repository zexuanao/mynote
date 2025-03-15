# socket地址api
字节序分为大端字节序和小端字节序，大端指一个整数的高位存储在内存的低地址处，低位字节保存在内存的高地址处，小端则相反
现在一般使用小端字节序作为pc的使用，所以将小端字节序作为主机字节序，但是以前也有大端的主机，所以网络上直接规定使用大端字节序作为网络字节序，然后让客户端去选择是否改变字节序。
linux提供了四种函数来完成主机字节序和网络字节序的转换
htonl 表示host to network long 即将长整型的主机字节序转化成网络字节序，一般用来转换ip地址，还有htons，短整型用来转换端口，当然，还有ntohl和ntohs
socket接口中表示socket地址的是sockaddr结构体
```
#include<bits/socket.h>
struct sockaddr
{
	sa_family_t sa_family;
	char sa_data[14];
}
```
sa_family成员是地址族类型的变量，地址族类型通常与协议族类型对应
常见的协议族
PF_UNIX	unix本地域协议族
PF_INET	tcp/ipv4协议族
PF_INET6	tcp/ipv6协议族
地址族就是把协议族的pf改为af，他们的值完全相同
sa_data与协议族相对应分别是
文件的路径名
16bit端口号和32bit ipv4地址，共6字节
16bit端口号，32bit流标识，128bit ipv6地址，bit范围id，共26字节
因为sa_data 14个字节没有办法容纳ipv6，所以有新的通用socket地址结构体
```
#include<bits/socket.h>
struct sockaddr_storage
{
	sa_family_t sa_sa_family;
	unsigned long int  __ss_align;
	char __ss_padding[128-sizeof(__ss_align)];
}
```
不仅有足够大的空间，而且有内存对齐功能
但是在获取端口号上就需要繁琐的位操作，所以也有专用的socket地址
比如`sockaddr_un ,sockaddr_in,sockaddr_in6`

#ip地址转换函数
```
#include<arpa/inet.h>
in_addr_t inet_addr(const char * strptr);
int inet_aton(const char*cp,struct in_addr* inp);
char* inet_ntoa (struct in_addr in);
```
`inet_addr`将点分十进制字符串表示的ipv4地址转换成网络字节序整数表示的ipv4地址
`inet_aton`函数和`inet_addr`实现同样的功能，但是是将转换结果放在inp指向的地址结构中，成功返回1
`inet_ntoa`函数则相反,而且函数内部使用一个静态变量保存，所以是不可重入的

下面三个函数是同样的功能，但是也能用于ipv6
```
#include<arpa/inet.h>
int inet_pton(int af,const char* src, void * dst);
const char* inet_ntop(int af,const void *src,char* dst,socklen_t cnt);

```
pton将十进制字符串或16进制字符串转换成为网络字节序整数表示的ip地址
af指定地址族  AF_INET   AF_INET6
src表示字符串
dst指定存储的内存
cnt表示存储单元的大小，可使用下面两个宏
```
#include <netinet/in.h>
#define INET_ADDRSTRLEN 16 
#define INET6_ADDRSTRLEN 46
```
分别表示ipv4和ipv6
# 创建socket
```
#include<sys/types.h>
#include<sys/socket.h>
int socket(int domain,int type,int protocol);
```
domain指使用什么协议族pf_inet等
type指定服务类型，`SOCK_STREAM`(流服务),`SOCK_UGRAM`(数据报服务)，对于tcp/ip协议族而言，分别对应tcp和udp
protocol选择具体协议，一般使用默认“0”就可以了


注：内核2.6.17后可以使用`SOCK_NONBLOCK`和`SOCK_CLOEXEC`分别表示设置为非阻塞和使用fork调用子进城时关闭该socket
# 命名socket
命名是指将socket和socket地址绑定称为给socket命名
通常只有服务器需要命名，客户端则不需要
```
#include<sys/types.h>
#include<sys/socket.h>
int bind( int sockfd, const struct sockaddr* my_addr,socklen_t addlen);
```
指定了套接字的类型（地址族），但并没有绑定具体的IP地址和端口号,所以需要使用bind
bind成功返回0，失败返回-1，并设置errno
EACCES,被绑定的地址是受保护的地址
EADDRINUSE,被绑定的地址正在使用中
注意：backlog现在指的是完全连接状态的上限
# 监听socket
```
#include<sys/socket.h>
int listen(int sockfd,int backlog);
```
sockfd就是套接字名称，backlog是内核监听的最大长度一般是5
在内核2.2之前backlog指半链接加全链接，后面版本只指全链接
# 接受连接
```
#include <sys/types.h>
#include<sys/socket.h>
int accept(int sockfd, struct sockaddr* addr,socklen_t *addrlen)
```
sockfd是上面的监听socket，addr是接收的远端socket，长度由第三个参数提供
accept成功后会返回一个新的连接socket
accept对于客户端断开连接完全不知情，但是客户端直接退出的话，可以检测到
# 发起连接
```
#include<sys/types>
#include<sys/socket.h>
int connect(int sockfd,const struct sockaddr* serv_addr,socklen_t addrlen);
```
成功返回0，失败返回-1，并设置errno
ECONNREFUSED，目标端口不存在
ETIMEDOUT，连接超时
# 关闭连接
```
#include<unistd.h>
int close(int fd);
```
close是将socketfd的引用减1，只有引用次数为0的时候才真正关闭连接
如果要立即终止连接，那么应该使用shutdown，这是为网络编程专门设计的
```
#include<sys/socket.h>
int shuntdown (iont sockfd,int howto);
```
howto参数决定了shutdown的行为，以下为可选值
SHUT_RD关闭读
SHUT_WR关闭写
SHUT_RDWR同时关闭
# 数据读写
### tcp数据读写
文件的读写操作read和write同样适用于socket
但是socket编程接口提供了几个专门的函数
```
#include<sys/types.h>
#include<sys/socket.h>
ssize_t recv(int sockfd,void *buf ,size_t len,int flags);
ssize_t send(int sockfd,const void * vuf,size_t len,int flags);
```
buf和len分别是缓冲区的位置和大小
flag通常设置为0即可
recv返回可能小于期望长度，所以要多次调用，返回0则认为对方关闭连接，出错时返回-1
flag也有其他的选项。如下：send  recv
MSG_CONFIRM 持续监听    Y N
MSG_DONTROUTE 不查看路由表直接发送给本地局域网络内的主机 Y N
MSG_DONTWAIT 表示此次操作将是非阻塞的 Y Y
MSG_MORE 还有更多数据，超时等待 Y N
MSG_WAITALL 仅在读取到指定数量后才返回 N Y
MSG_PEEK 窥探缓存中的数据，不会导致这些数据被清除N Y
MSG_OOB 发送或接收紧急数据 Y Y
MSG_NOSIGNAL 往读端关闭的管道或者socket连接中写数据时不引发SIGPIPE信号 Y N

### udp数据读写
```
#include<sys.types.h>
#include<sys/socket.h>
ssize_t recvfrom(int sockfd,void *buf ,size_t len,int flags,struct sockaddr* src_addr,socklen_t * addrlen);
ssize_t sendto(int sockfd,const void * vuf,size_t len,int flags,const struct sockaddr* src_addr,socklen_t * addrlen);
```
udp不需要bind和listen，直接在传输函数里面绑定socketfd和sockaddr结构体
recvfrom和sendto也可以用来传输tcp数据，只需要最后两个参数改成null就可以了


还有一份通用的函数
```
#include<sys/socket.h>
ssize_t recvmsg(int sockfd,struct msghdr* msg ,int flags);
ssize_t sendmsg(int sockfd,struct msghdr* msg,int flags);
```
msghdr结构体定义如下：
```
struct msghdr
{
    void* msg_name;//socket地址
    socklen_t msg_namelen;
    struct iovec* msg_iov;
    int msg_iovlen;
    void* msg_control;
    socklen_t msg_controllen;
    int msg_flags;
};
  
struct iovec
{
    void* iov_base;//内存起始地址
    size_t iov_len;//这块内存的长度
};
```
# 带外数据
通常无法预期应用程序又带外数据需要接受
内核通知的两种方式：io复用产生的异常事件和SIGURG信号
如果需要知道内存位置可以用下面的函数：
```
#include<sys/socket.h>
int sockatmark(int sockfd);
```
如果是带外数据则返回1，使用MSG_OOB的recv接收带外数据
# 地址信息函数
```
#include<sys/socket.h>
int getsockname(int sockfd,struct sockaddr* address,socklen_t * address_len);
int getpeername(int sockfd,struct sockaddr* address,socklen_t * address_len);
```
可以分别获取本端和远端的socket地址
# socket选项
```
#include<sys.socket.h>
int getsockopt(int socketfd,int level,int option_name,void * option_value,socklen_t* restrict option_len);
int setsockopt(int socketfd,int level,int option_name,void * option_value,socklen_t* restrict option_len);
```
level指定要操作哪个协议的选项
level指定控制套接字的层次.可以取三种值:
1)SOL_SOCKET:通用套接字选项.
2)IPPROTO_IP:IP选项.
3)IPPROTO_TCP:TCP选项.　
<br>
option_name指定选项的名字
option_value和option_len分别是被操作选项的值和长度

注意：因为listen状态已经进入半连接状态，所以对于服务器，部分选项只能在listen之前设置

重要的选项：
`SO_REUSEADR `重用本地地址，可以使用处于`TIME_WAIT`状态的连接占用的socket地址
也可以直接设置`/proc/sys/net/ipv4/tcp_tw_recycle`来快速收回被关闭的socket
`SO_RCVBUF`和`SO_SNDBUF`分别表示tcp接收缓冲区和发送缓冲区的大小
也可以通过设置`/proc/sys/net/ipv4/tcp+_rmem`和`/proc/sys/net/ipv4/tcp_wmem`来改变缓冲区大小   但是这是有最小值的，分别是256和2048字节
`SO_RCVLOWAT`和`SO_SNDLOWAT`分别表示接收缓冲区和发送缓冲区的低水位标志，在小于接收低水位时接收高于发送缓冲区时发送，他们默认值是1字节
`SO_LINGER`用于控close系统调用在关闭tcp链接时的行为，设置他的值时需要用到一个linger类型的结构体
```
#include<sys/socket.h>
{
    int l_onoff;
    int l_linger;
}
```




```
SOL_SOCKET	SO_DEBUG	打开调试信息
SOL_SOCKET	SO_REUSEADDR	重用本地地址
SOL_SOCKET	SO_TYPE	获取socket类型
SOL_SOCKET	SO_ERROR	获取并清除socket错误状态
SOL_SOCKET	SO_DONTROUTE	不查看路由表，直接发送数据到目的地，类似于send系统调用的MSG_DONTROUTE标志
SOL_SOCKET	SO_RCVBUF	TCP接收缓冲区大小
SOL_SOCKET	SO_SNDBUF	TCP发送缓冲区大小
SOL_SOCKET	SO_KEEPALIVE	发送周期性保活消息以维持连接
SOL_SOCKET	SO_OOBINLINE	带外数据将存入普通数据输入队列中，因此无法使用MSG_OOB标志读取带外数据（应该像读取普通数据一样读取带外数据）
SOL_SOCKET	SO_LINGER	若有数据待发送，则延迟关闭
SOL_SOCKET	SO_RCVLOWAT	TCP接收缓冲区低水位标记
SOL_SOCKET	SO_SNDLOWAT	TCP发送缓冲区低水位标记
SOL_SOCKET	SO_RCVTIMEO	接收数据超时（见第11章）
SOL_SOCKET	SO_SNDTIMEO	发送数据超时（见第11章）
IPPROTO_IP	IP_TOS	服务类型
IPPROTO_IP	IP_TTL	存活时间
IPPROTO_IPV6	IPV6_NEXTHOP	下一跳IP地址
IPPROTO_IPV6	IPV6_RECVPKTINFO	接收分组信息
IPPROTO_IPV6	IPV6_DONTFRAG	禁止分片
IPPROTO_IPV6	IPV6_RECVTCLASS	接收通信类型
IPPROTO_TCP	TCP_MAXSEG	TCP最大报文段大小
IPPROTO_TCP	TCP_NODELAY	禁止Nagle算法
```
# 网络信息API
### gethostbyname和gethostbyaddr
```
#include<netdb.h>
struct hostent* gethostbyname(const char* name);
struct hostent* gethostbyaddr(const void* addr,size_t len ,int type);
```
name是主机名，addr指定ip地址len指定addr所指ip地址的长度，type指定ip地址类型
他们返回的都是hostent结构体
```
#include<netdb.h>
struct hostent
{
    char* h_name;   //主机名
    char** h_aliases;//主机别名列表
    int h_addrtype;//地址类型
    int h_length;//地址长度
    char** h_addr_list;//按网络字节序列出的主机ip地址列表
};
```

### getservbyname和getservbyport
分别通过名称和端口获取某个服务的完整信息
他们实际上是通过读取/etc/services文件来获取服务的信息
```
#include<netdb.h>
struct servent* getservbyname(const char *name,const char*proto);
struct servent* getservbyport(int port,const char * proto);
```
name表示目标服务的名字，port表示端口号
proto指定服务类型，可以是tcp，udp，NULL
他们返回的都是servent结构体类型的指针
```
#include<netdb.h>
struct servent
{
    char* s_name; //服务名称
    char** s_aliases;//别名列表
    int s_port;//端口号
    char* s_proto;//服务类型
}
```

### getaddrinfo
既能通过主机名获得ip地址，
```
#include<netdb.h>
int getaddrinfo(const char* hostname,const chhar* service,const struct addrinfo* hints,struct addrinfo** result);
```
hostname可以表示主机名字，也可以表示ip地址
service可以接受服务名，也可以接收字符串表示的十进制端口号
hints是一个提示，可以设置为null，表示允许反馈任何结果
result指向一个链表，用于存储反馈的结果
```
struct addinfo
{
    int ai_flags;//
    int ai_family;//地址族
    int ai_socktype;//服务类型
    int ai_protocol;//指具体的网络协议，含义和socket系统调用的第三个参数相同，通常被设置为0
    socklen_t ai_addrlen;//
    char* ai_canonname;//主机别名
    struct sockaddr* ai_addr;//指向socket地址
    struct addrinfo* ai_next;//指向下一个sockinfo结构的对象
};
```
getaddrinfo将隐式的分配堆内存，所以需要自己释放
```
#incldue<netdb.h>
void freeaddrinfo(struct addrinfo* res);
```

### getnameinfo
通过socket地址同时获得以字符串表示的主机名和服务名
```
#include<netdb.h>
int getnameinfo(const struct socjaddr* sockaddr,socklen_t addrlen,char* host,socklen_t hostlen,char* serv,socklen_t,int flags);
```
最后两个函数成功返回0失败返回错误码，可以使用
```
#include<netdb.h>
const char* gai_strerroe(int error);
```
将错误码转换成其字符串格式

