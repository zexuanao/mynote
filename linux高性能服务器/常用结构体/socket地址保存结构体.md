#socket地址保存结构体
```
struct sockaddr_in
{
    sa_family_t sin_family;//地址族
    u_inet16_t sin_port;//端口号，需要使用网络字节序
    struct in_addr sin_addr;//ipv4地址结构体
};
struct in_addr
{
    u_int32_t s_addr;
};
```
```
struct sockaddr_in6
{
    sa_family_t sin6_family;//地址族
    u_int6_t sin6_port;//端口号
    u_int32_t sin6_flowinfo;//流信息，应设置为0
    struct in6_addr sin6_addr;//ipv6地址结构体
    u_int32_t sin6_scope_id;
};
struct in6_addr
{
    unsigned char sa_addr[16]
};
```
```
struct sockaddr_un
{
    sa_family_t sin_family;//地址族
    char sun_path[108];//文件路径名
};
```