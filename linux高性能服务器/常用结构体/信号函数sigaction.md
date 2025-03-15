```
struct sigaction {
    #ifdef _USE_POSIX199309
    union {
        _sighandler_t sa_handler;
        void (*sa_sigaction)(int, siginfo_t*, void*);
    } _handler;
    #define sa_handler _handler.sa_handler
    #define sa_sigaction _handler.sa_sigaction
    #else
    _sighandler_t sa_handler;
    #endif
    _sigset_t sa_mask;
    int sa_flags;
    void (*sa_restorer)(void);
};

```