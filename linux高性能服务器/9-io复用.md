# select系统调用
用途：在一段时间内，监听用户感兴趣的文件描述符上的可读、可写和异常等事件
```
#include<sys/select.h>
int select (int nfds,fd_set* readfds,fd_set* writefds,fd_set* exceptfds,struct timeval* timeout);
```
nfds    被监听的文件描述符的总数，一般为文件描述符中的最大值加一
readfds,writefds和exceptfds 分别指向可读可写和异常等事件对应的文件描述符集合
fd_set结构体仅包含一个整型数组，能容纳的文件描述符数量由FD_SETSIZE指定，下面一些列宏可用来访问结构体中的位
```
#include<sys/select.h>
FD_ZERO(fd_set* fdset);//清除fdset的所有位
FD_SET(int fd,fd_set* fdset);//设置fdset的位fd
FD_CLR(int fd,fd_set* fdset);//清除fdset的位fd
int FD_ISSET(int fd,fd_set* fdset);//测试fdset的位fd是否被设置
```
timeout参数用来设置超时时间，内核将修改它以告诉应用程序select等待了多久

#文件描述符就绪条件
可读：
1. 接受缓存区中的字数大于等于其低水位标记
2. 通信对方关闭连接。此时对该socket的读操作将返回0
3. 监听socket上有新的连接请求
4. socket有未处理的错误。此时我们可以使用getsockopt来读取和清除
可写：
1. 发送缓存区中的可用字数大于等于低水位标记
2. socket的写操作被关闭。对写操作被关闭的sockey执行写操作将触发一个sigpipe信号
3. socket使用非阻塞connect连接成功或者失败后
4. socket上有未处理的错误
网络程序中，select唯一能处理的异常就只是接收到带外数据

#select工作原理
select工作原理：传入要监听的文件描述符集合（可读、可写或异常）开始监听，select处于阻塞状态，当有事件发生或设置的等待时间timeout到了就会返回，返回之前自动去除集合中无事件发生的文件描述符，返回时传出有事件发生的文件描述符集合。但select传出的集合并没有告诉用户集合中包括哪几个就绪的文件描述符，需要用户后续进行遍历操作。
# poll系统调用
和select类似，也是在指定时间内轮询一定数量的文件描述符
```
#include<poll.h>
int poll(struct pollfd* fds,nfds_t nfds,int timeout);
```
fds,指定所有我们感兴趣的文件描述符上发生的事件
```
struct pollfd
{
    int fd;//文件描述符
    short events;//注册的事件
    short revents;//实际发生的事件
};
```
```
POLLIN 数据可读
POLLRDNORM普通数据可读
POLLPRI高优先级数据可读，比如tcp带外数据
POLLOUT数据可写
POLLWRNORM普通数据可写
POLLWRBAND优先级带数据可写
POLLRDHUP   tcp连接被对方关闭，由GNU提供，所以需要使用时定义_GNU_SOURCE
POLLERR错误
```
nfds参数指定fds的大小
timeout指定poll的超时值，单位是毫秒，-1，永远阻塞，0，立即返回
# epoll系列系统调用
epoll是linux特有的io复用函数
epoll把用户关心的文件描述符上的事件放在内核里的一个事件表中，所以需要一个额外的文件描述符来唯一标识内核中的这个事件表
```
#include<sys/epoll.h>
int epoll_create(int size);
```
size现在并不起作用，只是一个提示作用
操作epoll的内核事件表：
```
#include<sys/epoll.h>
int epoll_ctl(int epfd,int op,int fd,struct epoll_event* event)
```
fd是要操作的文件描述符
op参数指定操作类型：
1. `EPOLL_CTL_ADD` 注册事件
2. `EPOLL_CTL_MOD` 修改事件
3. `EPOLL_CTL_DEL` 删除事件
event指定事件

```
struct epoll_event
{
    __uint32_t events;//epoll事件
    epoll_data_t data;//用户数据
};
```
epoll支持的事件类型和poll基本相同，表示的宏在前面加上E就可以了
有两个额外的：
1. EPOLLET
2. EPOLLONESHOT
data成员用于存储用户数据

```
typedef union epoll_data
{
    void* ptr;
    int fd;
    uint32_t u32;
    uint64_t u64;
}epoll_data_t;
```
其四个成员中使用最多的是fd，若要将文件描述符和用户数据关联起来，以实现快速的数据访问，只能使用其他手段，比如放弃使用`epoll_data_t`的fd成员，而在ptr只想的用户数据中包含fd

#epoll_wait函数
```
#include<sys.epoll.h>
int epoll_wait(int epfd,struct epoll_event* event,int maxevents,int timeout);
```
timeout 表示超时时间
maxevents 指定最多监听多少个事件
epfd指定内核事件表
这个函数如果检测到事件，就将所有就绪的事件从内核事件表中复制到event指向的数组中，这个数组只用于输出epoll_wait检测到的就绪事件，而不像select和poll的数组参数那样既用于输出内核检测到的就绪事件，又用于传入用户注册的事件


#LT和ET模式
LT（电平触发），默认工作模式，epoll相当于效率较高的poll
当往epoll内核事件表中注册一个文件描述符上的epollet事件时，epoll将以ET（边沿触发）模式来操作，为epoll的高效工作模式
他们的区别是LT模式下可以不立即处理该事件，但是ET模式下必须立即处理

#EPOLLONESHOT事件
希望在任何时刻都只被一个线程处理
除非使用epoll_ctl函数重置该文件描述符上注册的事件
相应的，处理完一个事件后，应该立即重置这个socket上的EPOLLONESHOT事件
# io复用的高级应用
### 非阻塞connect
einprogress，这种错误发生在对非阻塞的socket调用connect，而连接有没有立即建立时。在这种情况下，我们可以调用select、poll等函数来监听这个连接失败的socket上的可写事件。当select、poll等函数返回后，再利用getsocketopt来读取错误码并清除该socket上的错误。如果错误吗是0，表示连接成功建立，否则连接失败。
这样的话我们就能同时发起多个连接并一起等待
### 聊天室程序
##### client.cpp
```
/* 这是一个聊天室程序的客户端程序 */
#define _GUN_SOURCE 1
#include<sys/types.h>
#include<sys/socket.h>
#include<arpa/inet.h>
#include<netinet/in.h>
#include<stdio.h>
#include<stdlib.h>
#include<assert.h>
#include<poll.h>
#include<string.h>
#include<fcntl.h>
#include<unistd.h>


#define BUFFER_SIZE 64

int main(int argc, char* argv[])
{
	if (argc <= 2)
	{
        printf("usage: %s ip_address port_number\n",basename(argv[0]));
		return 1;
	}
	const char* ip = argv[1];
	int port = atoi(argv[2]);

	struct sockaddr_in server_address;
	bzero(&server_address, sizeof(server_address));
	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(port);
	inet_pton(AF_INET, ip, &server_address.sin_addr);

	int sockfd = socket(PF_INET, SOCK_STREAM, 0);
	assert(sockfd >= 0);
	if (connect(sockfd, (struct sockaddr*)&server_address, sizeof(server_address)) < 0)
	{
		printf("connection failed\n");
		close(sockfd);
		return 1;
	}
	
	/* 前期准备工作 */
	pollfd fds[2];
	/* 注册文件描述符0(标准输入)和文件描述符 sockfd 上的可读事件 */
	fds[0].fd = 0;
	fds[0].events = POLLIN;
	fds[0].revents = 0;
	fds[1].fd = sockfd;
	fds[1].events = POLLIN | POLLRDHUP;	/* 这里使用了 POLLRDHUP，所以本程序开头要进行 _GUN_SOURCE 的宏定义 */
	fds[1].revents = 0;
	char read_buf[BUFFER_SIZE];
	int pipefd[2];
	int ret = pipe(pipefd);
	assert(ret != -1);

	while (1)
	{
		ret = poll(fds, 2, -1);		/* 最后一个参数为-1，意味着 poll 调用将永远阻塞，这对 epoll 也同样适用 */
		if (ret < 0)
		{
			printf("poll failure\n");
			break;
		}

		if (fds[1].revents & POLLRDHUP)
		{
			printf("server close the connection\n");
			break;
		}
		else if (fds[1].revents & POLLIN)
		{
			memset(read_buf, '\0', BUFFER_SIZE);
			recv(fds[1].fd, read_buf, BUFFER_SIZE - 1, 0);
			printf("%s\n", read_buf);
		}

		if (fds[0].revents & POLLIN)
		{
			/* 使用 splice 将用户输入的数据直接写到 sockfd 上(零拷贝) */
			ret = splice(0, NULL, pipefd[1], NULL, 32768, SPLICE_F_MORE | SPLICE_F_MOVE);
			ret = splice(pipefd[0], NULL, sockfd, NULL, 32768, SPLICE_F_MORE | SPLICE_F_MOVE);
			/* 这里使用 SPLICE_F_MORE 也要在程序开头进行 _GUN_SOURCE 的宏定义 */
		}
	}
	
	close(sockfd);
	return 0;
}

```
##server.cpp
```
/* 这是聊天室程序的服务器程序 */
#define _GUN_SOURCE 1
#include<sys/types.h>
#include<sys/socket.h>
#include<arpa/inet.h>
#include<unistd.h>
#include<assert.h>
#include<netinet/in.h>
#include<fcntl.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>
#include<poll.h>

#define USER_LIMIT 5	/* 最大用户数量 */
#define BUFFER_SIZE 64	/* 读缓冲区的大小 */
#define FD_LIMIT 65535	/* 文件描述符数量限制 */

/* 客户数据结构体：客户端 socket 地址，待写到客户端的数据的位置，从客户端读入的数据 */
struct client_data
{
	sockaddr_in address;	/* 该客户端的 socket 地址 */
	char* write_buf;	/* 指针，指向服务器要发送给该客户端的数据的起始位置 */
	char buf[BUFFER_SIZE];  /* 存储该客户端发送给服务器的数据 */
};

int setnonblocking(int fd)
{
	int old_option = fcntl(fd, F_GETFL);
	int new_option = old_option | O_NONBLOCK;
	fcntl(fd, F_SETFL, new_option);
	return old_option;
}

int main(int argc, char* argv[])
{
	if (argc <= 2)
	{
		printf("usage: %s ip_address port_number\n",basename(argv[0]));
		return 1;
	}
	const char* ip = argv[1];
	int port = atoi(argv[2]);

	int ret=0;
	struct sockaddr_in address;
	bzero(&address, sizeof(address));
	address.sin_family = AF_INET;
	address.sin_port = htons(port);
	inet_pton(AF_INET, ip, &address.sin_addr);
	
	int listenfd = socket(PF_INET, SOCK_STREAM, 0);
	assert(listenfd >= 0);

	ret = bind(listenfd, (struct sockaddr*)&address, sizeof(address));
	assert(ret != -1);

	ret = listen(listenfd, 5);
	assert(ret != -1);

	/* 创建 user 数组，分配 FD_LIMIT 个 client_data 对象。
	 * 可以预期，每个可能的 socket 连接都可以获得一个这样的对象，并且 socket 的值可以直接作为数组的下标来索引 socket 连接对应的 client_data 对象，
	 * 这是将 socket 和客户数据关联的简单而高效的方式
	 */
	client_data* users = new client_data[FD_LIMIT];
	/* 尽管我们分佩了足够多的 client_data 对象，但为了提高 poll 的性能，仍然有必要限制用户的数量 */
	pollfd fds[USER_LIMIT + 1];			/* 监听 socket 也要放入 fds 里，所以要 + 1 */
	int user_counter = 0;				/* user_counter 是已连接的客户数量，同时也是 fds 数组中 最后一个客户的下标 */
	for (int i = 1; i <= USER_LIMIT; i++)		/* 初始化 fds */
	{
		fds[i].fd = -1;
		fds[i].events = 0;
	}
	fds[0].fd = listenfd;
	fds[0].events = POLLIN | POLLERR;
	fds[0].revents = 0;

	while (1)
	{
		ret = poll(fds, user_counter + 1, -1);		/* 阻塞的调用 poll */
		if (ret < 0)
		{/* poll 调用失败 */
			printf("poll failure\n");
			break;
		}
		
		for (int i = 0; i < user_counter + 1; i++)
		{
			if ((fds[i].fd == listenfd )&&( fds[i].revents & POLLIN))		/* 如果当前是是监听 socket，且读事件被触发 */
			{
				struct sockaddr_in client_address;
				socklen_t client_addrlength = sizeof(client_address);
				int connfd = accept(fds[i].fd, (struct sockaddr*)&client_address, &client_addrlength);
				if (connfd < 0)		/* connfd 调用失败 */
				{
					printf("errno is: %d\n", errno);
					continue;
				}
				/* 当前用户数量已达上限，关闭新到的连接 */
				if (user_counter >= USER_LIMIT)
				{
					const char* info = "too many users\n";
					printf("%s", info);
					send(connfd, info, strlen(info), 0);	/* 通知刚来的客户：客户满了，一会再连接把 */
					close(connfd);				/* 别忘记 close ！！！ */
					continue;
				}
				/* 对于新的连接，同时修改 fds 和 users 数组。前文已经提到，users[connfd] 对应于新连接文件描述符 connfd 的客户数据 */
				user_counter++;
				users[connfd].address = client_address;
				setnonblocking(connfd);				/* 所有客户端都设置为非阻塞，这样就能同时监听多个客户端了，而不是在一个客户端上死等 */
				fds[user_counter].fd = connfd;
				fds[user_counter].events = POLLIN | POLLRDHUP | POLLERR;	/* 第一次把客户端添加进来时，三种事件都要监听 */
				fds[user_counter].revents = 0;
				printf("comes a new user, now have %d users\n", user_counter);
			}
			else if (fds[i].revents & POLLERR)	/* 如果当前 socket 出现错误时，获取并清除错误状态，然后进入下一次循环 */
			{
				printf("get an error from %d\n", fds[i].fd);
				char errors[100];
				memset(errors, '\0', 100);
				socklen_t length = sizeof(errors);
				if (getsockopt(fds[i].fd, SOL_SOCKET, SO_ERROR, &errors, &length) < 0)
				{
					printf("get socket option failed\n");
				}
				continue;
			}
			else if (fds[i].revents & POLLRDHUP)	/* 如果当前 socket 关闭连接，则服务器也关闭对应的连接，并将用户总数减1 如果关闭的是中间的直接把将数量减一会让最后一个数据丢失*/
			{
				users[fds[i].fd] = users[fds[user_counter].fd];		/* 覆盖掉当前 socket 对应的客户信息 */
				close(fds[i].fd);		/* 关闭当前客户对应的 socket */
				fds[i] = fds[user_counter];	/* 离开的客户位置存储最后面客户的 fd，这样才能让 user_counter 减 1 */
				i--;
				user_counter--;
				printf("a client left\n");
			}
			else if (fds[i].revents & POLLIN)	/* 当前的 socket 不是监听 socket，且可读事件被触发 */
			{
				int connfd = fds[i].fd;
				memset(users[connfd].buf, '\0', BUFFER_SIZE);
				ret = recv(connfd, users[connfd].buf, BUFFER_SIZE - 1, 0);
				printf("get %d bytes of client data %s from %d\n",ret,users[connfd].buf,connfd);
				if (ret < 0)			/* 读取失败 */
				{
					if (errno != EAGAIN)	/* 错误码不是 EAGAIN，妥妥的出现了错误，关闭连接 */
					{
						close(connfd);
						users[connfd] = users[fds[user_counter].fd];
						fds[i] = fds[user_counter];
						i--;
						user_counter--;
					}
				}
				else if (ret == 0)	/* 客户端关闭连接了，啥都不干，交给下一次循环里的 POLLRDHUP 判断处理，当然喽，也可以在这处理，但是没必要，代码要简洁 */
				{
				}
				else	/* 顺利接收到客户数据，则通知其他 socket 连接准备写数据 */
				{
					for (int j = 1; j <= user_counter; j++)	/* 既然服务器接收到了数据，那么就要向除发送数据客户端外的所有客户端转发该数据*/
					{					/* 这个循环就是在干这件事 */
						if (fds[j].fd == connfd)	/* 跳过发来数据的客户端 */
						{
							continue;
						}
						/* 对于其他客户端，就不再监视他们的可读事件了，优先监视他们的可写事件，所以要注销 POLLIN 事件 */
						fds[j].events |= ~POLLIN;
						fds[j].events |= POLLOUT;
						users[fds[j].fd].write_buf = users[connfd].buf;
					}
				}
			}
			else if (fds[i].revents & POLLOUT)	/* 如果当前 socket 的可写事件被触发 */
			{
				int connfd = fds[i].fd;
				if (!users[connfd].write_buf)	/* 验证该 socket 确实有数据可写，也就是 write_buf 不为空 */
				{
					continue;
				}
				ret = send(connfd, users[connfd].write_buf, strlen(users[connfd].write_buf), 0);
				users[connfd].write_buf = NULL;		/* 写完了，那么当前 socket 的写入数据需要置为空 */
				/* 写完数据后需要重新注册 fds[i] 上的可读事件 */
				fds[i].events |= ~POLLOUT;
				fds[i].events |= POLLIN;
			}
		}
	}

	delete [] users;
	close(listenfd);
	return 0;
}

```
### 同时处理tcp和udp服务
服务器如果要同时监听多个端口，就必须创建多个socket，并将他们分别绑定到各个端口上
即使是同一个端口，如果服务器要同时处理该端口上的tcp和udp请求，则也需要创建两个不同的socket
# 超级服务xinetd
xinetd采用主配置文件和子配置文件来管理所有服务
主配置文件包含的都是通用选项，这些选项将被所有子配置文件继承
子配置文件可以覆盖这些选项
