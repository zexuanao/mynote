# 序
linux服务器必须要处理的三类事：
1. io事件
2. 信号
3. 定时时间
需要考虑：
1. 统一事件源 利用io复用系统调用来管理所有事件
2. 可移植性 不同操作系统具有不同的io复用方式
3. 对并发编程的支持 避免竞态条件
# io框架库概述
组间关系
1. 句柄
io框架库要处理的对象，io事件，信号，定时事件，统一称为事件源
在linux环境下，io事件对应的句柄是文件描述符，信号事件对应的句柄就是信号值
2. 事件多路分发器
I/O框架库 一般将系统支持的各种I/O复用系统 调用封装成统 一的接又，称为事件多路分发器
需要实现的方法：
`demultiplex`方法是等待事件的核心函数，其内部调用的是select、poll、epoll_wait等函数
`register_event`
`remove_event`
3. 事件处理器和具体事件处理器
事件处理器通常包含一个或多个`handle_event`回调函数，在时间循环中被执行，通常，这只是一个接口，具体回调函数必须要用户自己实现，所以一般被声明为虚函数
`get_handle`方法，返回与该事件处理器关联的句柄
4. Reactor
这是io框架库的核心，提供的主要方法：
`handle_events`：执行时间循环
`register_handler`：调用多路分发器的`register_event`来往多路分发器中注册一个事件
`remove_handler`：调用`remove_event`方法来删除事件多路分发器中的一个事件
# Libevent库的主要逻辑
1. 调用`event_init()`函数创建`event_base`对象。一个`event_base`相当于一个Reactor实例
2. 创建具体的事件处理器，并设置他们所从属的Reactor实例。`evsignal_new`和`evtimer_new`分别用于创建信号事件处理器和定时事件处理器
这两个函数的统一入口是`event_new`函数，这是EventHandler的函数，其定义是：
```
struct event* event_new(struct evet_base* base,evutil_socket_t fd,short events,void(*cb)(evutil_socket_t,short,void*),void* arg)
```
base指定新创建的事件处理器从属的Reactor
fd参数指定与该事件处理器关联的句柄：
事件|传递给fd的类型
----|--------------
io事件|传递文件描述符值
信号事件|传递信号值
定时事件|传递-1
events参数指定事件类型，其可选值：
```
#define EV_TIMEOUT  0x01 定时事件
#define EV_READ     0x02 可读事件
#define EV_WRITE    0x04 可写事件
#define EV_SIGNAL   0x08 信号事件
#define EV_PERSIST  0x10 永久事件
#define EV_ET       0x20 
```
`EV_PERSIST`,事件被触发后，自动重新对这个event调用`event_add`函数
cb参数指定目标事件对应的回调函数，相当于`handle_event`方法
arg参数是Reactor传递给回调函数的参数
返回值 event 不是事件而是事件处理器
3. 调用`event_add`函数，将事件处理器添加到注册事件队列中，并将该事件处理器对应的事件添加到事件多路分发器中。相当于`register_handler`方法
4. 调用`event_base_dispatch`来执行事件循环
5. 时间循环结束后，使用`*_free`系列函数来释放系统资源
# event结构体
事件处理器，封装了句柄、事件类型、回调函数，以及其他必要的标志和数据
```
struct event {
    TAILQ_ENTRY(event) ev_active_next; // 活动事件的下一个节点
    TAILQ_ENTRY(event) ev_next; // 事件队列中的下一个节点
    union {
        TAILQ_ENTRY(event) ev_next_with_common_timeout; // 下一个具有相同超时时间的事件节点
        int min_heap_idx; // 最小堆索引
    } ev_timeout_pos;
    evutil_socket_t ev_fd; // 事件关联的文件描述符
    struct event_base *ev_base; // 事件所属的事件基础（event base）
    union {
        struct {
            TAILQ_ENTRY(event) ev_10_next; // 10倍扩大的超时时间的下一个节点
            struct timeval ev_timeout; // 超时时间
        } ev_io;
        struct {
            TAILQ_ENTRY(event) ev_signal_next; // 信号事件的下一个节点
            short ev_ncalls; // 回调函数调用次数
            short *ev_pncalls; // 回调函数调用次数的指针
        } ev_signal;
    } _ev;
    short ev_events; // 事件类型（比如读、写等）
    short ev_res; // 事件结果
    short ev_flags; // 事件标志
    ev_uint8_t ev_pri; // 事件优先级
    ev_uint8_t ev_closure; // 事件闭包
    struct timeval ev_timeout; // 超时时间
    void (*ev_callback)(evutil_socket_t, short, void *arg); // 事件回调函数
    void *ev_arg; // 事件回调函数的参数
};

```
`ev_events`代表事件类型（见Libevent库的主要逻辑）的按位或，当然，互斥的不能一起设置
`ev_next`所有已经注册的事件处理器通过该成员串联成一个尾队列，我们称之为注册事件队列，宏TAILQ_ENTRY是尾队列中的节点类型
`ev_active_next`所有被激活的事件处理器通过该成员串联成一个尾队列，我们称之为活动事件队列
`ev_timrout_pos`这是一个联合体，仅用于定时事件处理器，可以自由选择时间堆或者简单的链表
`_ev`这是一个联合体，分为io事件和信号事件，将相同文件描述符值的io事件处理器串联成一个io时间队列，将所有具有相同信号值的信号事件处理器串联成一个事件队列
`ev_fd`对于io，是文件描述符值，对于信号事件处理器，他是信号值
`ev_base`事件处理器从属的`event_base`实例
`ev_res`记录当前激活时间的类型
`ev_flags`一些事件标志，可选址如下：
```
#define EVLIST_TIMEOUT 0x01 /* 事件处理器从属于通用定时器队列或时间坡 */
#define EVLIST_INSERTED 0x02 /* 事件处理器从属于注册事件队列 */
#define EVLIST_SIGNAL 0x04 /* 没有使用 */
#define EVLIST_ACTIVE 0x08 /* 事件处理器从属于活动事件队列 */
#define EVLIST_INTERNAL 0x10 /* 内部使用 */
#define EVLIST_INIT 0x80 /* 事件处理器已经被初始化 */
#define EVLIST_ALL (0xf000 | 0x9f) /* 定义所有标志 */

```
`ev_pri`指定事件处理器优先级，值越小优先级越高
`ev_closure`执行事件处理器的回调函数时的行为，可选值如下：
```
/* 默认行为 */
#define EV_CLOSURE_NONE 0

/* 当执行信号事件处理器的回调函数时，调用ev.ev_signal.ev_ncalls次该回调函数 */
#define EV_CLOSURE_SIGNAL 1

/* 执行完回调函数后，再次将事件处理器加入注册事件队列中 */
#define EV_CLOSURE_PERSIST 2

```
`ev_timeout`仅对定时器有效，指定定时器的超时值
`ev_callback`事件处理器的回调函数
`ev_arg`回调函数的参数
# 往注册事件队列中添加事件处理器
event对象创建好之后，应用程序需要调用`event_add`函数将其添加到注册事件队列中，并将对应的事件注册到事件多路分发器上，`event_add`主要是调用领娃一个内部函数`event_add_internal`,其中重要函数如下：
1. `evmap_io_add` 将io事件添加到事件多路分发器中，并将对应的事件处理器
添加到io事件队列中，并建立io事件和io事件处理器之间的映射关系
2. `evmap_signal_add`
将信号事件添加到事件多路分发器中，并将事件处理器添加到信号事件队列中，同时建立信号事件和信号事件处理器之前的映射关系
3. `event_quene_insert`
将事件处理器添加到各种事件队列中
# eventop结构体
```
struct eventop {
    /* 后端I/O复用技术的名称 */
    const char *name;
    /* 初始化方法 */
    void *(*init)(struct event_base *);
    /* 注册事件 */
    int (*add)(struct event_base *, evutil_socket_t fd, short old, short events, void *fdinfo);
    /* 删除事件 */
    int (*del)(struct event_base *, evutil_socket_t fd, short old, short events, void *fdinfo);
    /* 等待事件 */
    int (*dispatch)(struct event_base *, struct timeval *);
    /* 释放 I/O 复用机制使用的资源 */
    void (*dealloc)(struct event_base *);
    /* 程序调用 EorK 之后是否需要重新初始化 event_base */
    int need_reinit;

    /* 事件方法的特性，比如支持边缘触发、水平触发等 */
    enum event_method_feature features;
    /* 有的 I/O 复用机制需要为每个 I/O 事件队列和信号事件队列分配额外的内存，以避免同一个文长 */
    size_t fdinfo_len;
};
```
# event_base结构体
```
struct event_base {
     /** Function pointers and other data to describe this event_base's
      * backend. */
     /**
      * 实际使用后台方法的句柄，实际上指向的是静态全局数组变量，从静态全局变量eventops中选择
      */
     const struct eventop *evsel;
     /** Pointer to backend-specific data. */
     /**
      * 指向后台特定的数据，是由evsel->init返回的句柄
      * 实际上是对实际后台方法所需数据的封装，void出于兼容性考虑
      */
     void *evbase;
     /** List of changes to tell backend about at next dispatch.  Only used
      * by the O(1) backends. */
     // 告诉后台方法下一次调度的变化列表
     struct event_changelist changelist;
     /** Function pointers used to describe the backend that this event_base
      * uses for signals */
     // 用于描述当前event_base用于信号的后台方法
     const struct eventop *evsigsel;
     /** Data to implement the common signal handler code. */
     // 用于实现公用信号句柄的代码
     struct evsig_info sig;
     /** Number of virtual events */
     // 虚拟事件的数量
     int virtual_event_count;
     /** Maximum number of virtual events active */
     // 虚拟事件的最大数量
     int virtual_event_count_max;
     /** Number of total events added to this event_base */
     // 添加到event_base上事件总数
     int event_count;
     /** Maximum number of total events added to this event_base */
     // 添加到event_base上的最大个数
     int event_count_max;
     /** Number of total events active in this event_base */
     // 当前event_base中活跃事件的个数
     int event_count_active;
     /** Maximum number of total events active in this event_base */
     // 当前event_base中活跃事件的最大个数
     int event_count_active_max;
     /** Set if we should terminate the loop once we're done processing
      * events. */
     // 一旦我们完成处理事件了，如果我们应该终止loop，可以设置这个
     int event_gotterm;
     /** Set if we should terminate the loop immediately */
     // 如果需要中止loop，可以设置这个变量
     int event_break;
     /** Set if we should start a new instance of the loop immediately. */
     // 如果启动新实例的loop，可以设置这个
     int event_continue;
     /** The currently running priority of events */
     // 当前运行事件的优先级
     int event_running_priority;
     /** Set if we're running the event_base_loop function, to prevent
      * reentrant invocation. */
     // 防止event_base_loop重入的
     int running_loop;
     /** Set to the number of deferred_cbs we've made 'active' in the
      * loop.  This is a hack to prevent starvation; it would be smarter
      * to just use event_config_set_max_dispatch_interval's max_callbacks
      * feature */
     /**
      * 设置已经在loop中设置为’active’的deferred_cbs的个数，这是为了避免
      * 饥饿的hack方法；只需要使用event_config_set_max_dispatch_interval’s的
      * max_callbacks特征就可以变的更智能
      */
     int n_deferreds_queued;
     /* Active event management. // 活跃事件管理*/
     /** An array of nactivequeues queues for active event_callbacks (ones
      * that have triggered, and whose callbacks need to be called).  Low
      * priority numbers are more important, and stall higher ones.
      * 存储激活事件的event_callbacks的队列，这些event_callbacks都需要调用；
      * 数字越小优先级越高
      */
     struct evcallback_list *activequeues;
     /** The length of the activequeues array 活跃队列的长度*/
     int nactivequeues;
     /** A list of event_callbacks that should become active the next time
      * we process events, but not this time. */
     // 下一次会变成激活状态的回调函数的列表，但是当前这次不会调用
     struct evcallback_list active_later_queue;
     /* common timeout logic // 公用超时逻辑*/
     /** An array of common_timeout_list* for all of the common timeout
      * values we know.
      * 公用超时事件列表，这是二级指针，每个元素都是具有同样超时
      * 时间事件的列表，
      */
     struct common_timeout_list **common_timeout_queues;
     /** The number of entries used in common_timeout_queues */
     // 公用超时队列中的项目个数
     int n_common_timeouts;
     /** The total size of common_timeout_queues. */
     // 公用超时队列的总个数
     int n_common_timeouts_allocated;
     /** Mapping from file descriptors to enabled (added) events */
     // 文件描述符和事件之间的映射表
     struct event_io_map io;
     /** Mapping from signal numbers to enabled (added) events. */
     // 信号数字和事件之间映射表
     struct event_signal_map sigmap;
     /** Priority queue of events with timeouts. */
     // 事件超时的优先级队列，使用最小堆实现
     struct min_heap timeheap;
     /** Stored timeval: used to avoid calling gettimeofday/clock_gettime
      * too often. */
     // 存储时间：用来避免频繁调用gettimeofday/clock_gettime
     struct timeval tv_cache;
     // monotonic格式的时间
     struct evutil_monotonic_timer monotonic_timer;
     /** Difference between internal time (maybe from clock_gettime) and
      * gettimeofday. */
     // 内部时间（可以从clock_gettime获取）和gettimeofday之间的差异
     struct timeval tv_clock_diff;
     /** Second in which we last updated tv_clock_diff, in monotonic time. */
     // 更新内部时间的间隔秒数
     time_t last_updated_clock_diff;
 #ifndef EVENT__DISABLE_THREAD_SUPPORT
     /* threading support */
     /** The thread currently running the event_loop for this base */
     unsigned long th_owner_id;
     /** A lock to prevent conflicting accesses to this event_base */
     void *th_base_lock;
     /** A condition that gets signalled when we're done processing an
      * event with waiters on it. */
     void *current_event_cond;
     /** Number of threads blocking on current_event_cond. */
     int current_event_waiters;
 #endif
     /** The event whose callback is executing right now */
     // 当前执行的回调函数
     struct event_callback *current_event;
 #ifdef _WIN32
     /** IOCP support structure, if IOCP is enabled. */
     struct event_iocp_port *iocp;
 #endif
     /** Flags that this base was configured with */
     // event_base配置的特征值
      // 多线程调用是不安全的，单线程非阻塞模式
     // EVENT_BASE_FLAG_NOLOCK = 0x01,
      // 忽略检查EVENT_*等环境变量
     // EVENT_BASE_FLAG_IGNORE_ENV = 0x02,
      // 只用于windows
     // EVENT_BASE_FLAG_STARTUP_IOCP = 0x04,
      // 不使用缓存的时间，每次回调都会获取系统时间
     // EVENT_BASE_FLAG_NO_CACHE_TIME = 0x08,
      // 如果使用epoll方法，则使用epoll内部的changelist
     // EVENT_BASE_FLAG_EPOLL_USE_CHANGELIST = 0x10,
      // 使用更精确的时间，但是可能性能会降低
     // EVENT_BASE_FLAG_PRECISE_TIMER = 0x20
     enum event_base_config_flag flags;
     // 最大调度时间间隔
     struct timeval max_dispatch_time;
     // 最大调度的回调函数个数
     int max_dispatch_callbacks;
     // 优先级设置之后，对于活跃队列中子队列个数的限制
     // 但是当子队列个数超过这个限制之后，会以实际的回调函数个数为准
     int limit_callbacks_after_prio;
     /* Notify main thread to wake up break, etc. */
     /** True if the base already has a pending notify, and we don't need
      * to add any more. */
     //如果为1表示当前可以唤醒主线程，否则不能唤醒主线程
     int is_notify_pending;
     /** A socketpair used by some th_notify functions to wake up the main
      * thread. */
     // 一端读、一端写，用来触发唤醒事件
     evutil_socket_t th_notify_fd[2];
     /** An event used by some th_notify functions to wake up the main
      * thread. */
     // 唤醒event_base的event，被添加到监听集合中的对象
     struct event th_notify;
     /** A function used to wake up the main thread from another thread. */
     //执行唤醒操作的函数（不是唤醒event的回调函数）
     int (*th_notify_fn)(struct event_base *base);
     /** Saved seed for weak random number generator. Some backends use
      * this to produce fairness among sockets. Protected by th_base_lock. */
     // 保存弱随机数产生器的种子。某些后台方法会使用这个种子来公平的选择sockets。
     struct evutil_weakrand_state weakrand_seed;
     /** List of event_onces that have not yet fired. */
     LIST_HEAD(once_event_list, event_once) once_events;
 };
```
# 事件循环
事件循环。Libevcnt 中实现事件循环的函 数是event _base_loop。该函数首先调用1/O事件多路分发器的事件监听函数，以等待事件; 当有事件发生时，就依次处理之。