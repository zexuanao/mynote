# 日志
服务器的调试和维护都需要一个专业的日志系统
linux提供一个守护进程来处理系统日志-syslogd，现在一般都是升级版rsyslogd
调用syslog生成系统日志，该函数将日志输出到一个unix本地域socket类型的文件/dev/log中
syslog函数
```
#include<syslog.h>
void syslog(int priority,const char* message,...);
```
priority是所谓的设施值与日志级别的按位或
设施值的默认值是LOG_USER
日志级别有：
```
#include <syslog.h>

#define LOG_EMERG   LOG_EMERG    /* system is unusable */
#define LOG_ALERT   LOG_ALERT    /* action must be taken immediately */
#define LOG_ERR     LOG_ERR      /* error conditions */
#define LOG_WARNING LOG_WARNING  /* warning conditions */
#define LOG_NOTICE  LOG_NOTICE   /* normal but significant condition */
#define LOG_INFO    LOG_INFO     /* informational */
#define LOG_DEBUG   LOG_DEBUG    /* debug-level messages */
```
等等

```
#include<syslog.h>
void openlog(const char* ident,int logopt,int facility);
```
ident通常被设置为程序的名字，加在日志信息的日期和时间之后
logopt参数对后续syslog调用的行为进行配置
facility参数可以用来修改syslog函数中默认设施值

发布程序后不一定还需要一些日志信息，但日后还会用到，所以需要使用日志掩码
```
#include <syslog.h>
int setlogmask(int maskpri);
```
maskpri指定日志掩码值

最后，关闭日志功能
```
#include<syslog.h>
void closelog();
```
# 用户信息
下面这一组函数可以获取和设置当前进程的id
```
#include<sys/types.h>
#include<unistd.h>
uid_t get*id()
int set*id(*id_t *id);
```
一个进程拥有两个用户id
uid和euid，比如su必须用到root的权限，他的有效用户euid是root，所以所有人都可以使用它调用root权限
euid为root的进程称为特权进程

使用sudo chmod +s ...可以将文件的权限在使用时提升为拥有者的权限，但是用户执行时，肯定还是需要这个文件的执行权限的
只是使用时的权限不同，导致环境变量不同
# 进程间关系
linux下每个进程都隶属于一个进程组
可以使用getpgid来获得指定进程的pgid
同样的可以使用setpgid来设置

### 会话
有关联的进程会形成一个会话
```
#include<unistd.h>
pid_t setsid(void);
```
不能由进程组的首领进程调用
对于非组首领，调用：
1. 调用进程称为会话的首领
2. 新建一个进程组，其pgid就是调用进程的pid
3. 调用进程将会甩开终端
linux认为会话id（sid）等于会话首领所在的进程组的pgid并提供了读取sid的函数
getsid

# 系统资源限制
```
#include<sys/resouce.h>
int getrlimit(int resource,struct rlimit *rlim);
int setrlimit(int resource,const struct rlimit*rlim);

struct rlimit
{
    rlim_t rlim_cur;//软限制
    rlim_t rlim_max;//硬限制
}
```
| 资源限制类型   | 含义                                                   |
|----------------|--------------------------------------------------------|
| RLIMIT_AS      | 进程虚拟内存总量限制(单位是字节)。超过该限制将使得某些函数(比如mmap)产生 ENOMEM 错误 |
| RLIMIT_CORE    | 进程核心转储文件(coredump)的大小限制(单位是字节)。其值为0表示不产生核心转储文件 |
| RLIMIT_CPU     | 进程CPU时间限制(单位是秒)                               |
| RLIMIT_DATA    | 进程数据段(初始化数据 data 段、未初始化数据 bss 段和堆)限制(单位是字节) |
| RLIMIT_FSIZE   | 文件大小限制(单位是字节)，超过该限制将使得某些函数(比如write)产生 EFBIG 错误 |
| RLIMIT_NOFILE  | 文件描述符数量限制，超过该限制将使得某些函数(比如pipe)产生 EMFILE 错误 |
| RLIMIT_NPROC   | 用户能创建的进程数限制，超过该限制将使得某些函数(比如fork)产生 EAGAIN 错误 |
| RLIMIT_SIGPENDING | 用户能够挂起的信号数量限制                             |
| RLIMIT_STACK   | 进程栈内存限制(单位是字节)，超过该限制将引起 SIGSEGV 信号 |

# 改变工作目录和根目录
获取当前工作目录和改变进程工作目录的函数
```
#include<unistd.h>
char* getcwd(char* buf,size_t size);
int chdir(const char* path);
```
buf用于存储当前工作目录的绝对路径名
如果buf为NULL且size非0，则getcwd可能在内部使用malloc动态分配内存，此时需要自己释放
改变进程根目录的函数是chroot
```
#include<unistd.h>
int chroot(const char * path);
```
只有特权进程可以改变根目录
# 服务器程序后台化
遵循一定的步骤：
1. 创建子进程，关闭父进程，使程序在后台运行
2. 设置文件权限掩码，当进程创建新文件时，文件的权限将是mode& 0777
3. 创建新的会话，设置本进程为进程组的首领
4. 关闭标准输入、标准输出、标准错误
5. 关闭其他已经打开的文件描述符
6. 将标准流重定向

linux提供了完成同样功能的库函数
```
#include<unistd.h>
int daemon(int nochdir,int noclose);
```
nichdir指定是否改变工作目录，若传递0则工作目录将被设置为/
noclose参数为0时，标准流都被重定向到/dev/null文件，否则依然使用原来的设备
成功返回0，失败返回-1并设置errno
