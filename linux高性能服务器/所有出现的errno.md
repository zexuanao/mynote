# 命名socket
bind（）绑定文件描述符和指定socket地址
EACCES 被绑定的地址是受保护的地址，仅超级用户能够访问。
比如0～1023
EADDRINUSE 被绑定的地址正在使用中。比如绑定到一个处于TIME_WAIT状态的socket地址

# 监听socket
listen（）系统以backlog为最长队列，对socket进行处理
如果超过这个长度，客户端会收到
ECONNREFUSED错误信息

# splice函数
错误|含义
---|---
EBADF|参数所指文件描述符有错
EINVAL|不能使用splice
ENOMEM|内存不够
ESPIPE|使用了管道描述符，但是off_in不为NULL

# accrpe\send\recv
事件未发生时errno通常被设置成EAGAIN（再来一次）
EWOULDBLOCK（期望阻塞）

# connect
EINPROGRESS（在处理中）

# 信号
EINVAL 无效的信号
EPERM 该进程没有权限发送信号给任何一个目标进程
ESRCH 目标进程或进程组不存在

# 线程回收
EDEADLK 可能引起死锁，比如两个线程互相回收
EINVAL  目标线程是不可回收的
ESRCH   目标线程不存在