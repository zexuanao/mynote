```
struct stat {

        mode_t     st_mode;       //文件对应的模式，文件，目录等

        ino_t      st_ino;       //inode节点号

        dev_t      st_dev;        //设备号码

        dev_t      st_rdev;       //特殊设备号码

        nlink_t    st_nlink;      //文件的连接数

        uid_t      st_uid;        //文件所有者

        gid_t      st_gid;        //文件所有者对应的组

        off_t      st_size;       //普通文件，对应的文件字节数

        time_t     st_atime;      //文件最后被访问的时间

        time_t     st_mtime;      //文件内容最后被修改的时间

        time_t     st_ctime;      //文件状态改变时间

        blksize_t st_blksize;    //文件内容对应的块大小

        blkcnt_t   st_blocks;     //伟建内容对应的块数量

      };
```
stat结构体中的st_mode 则定义了下列数种情况：
    S_IFMT   0170000    文件类型的位遮罩
    S_IFSOCK 0140000    scoket
    S_IFLNK 0120000     符号连接
    S_IFREG 0100000     一般文件
    S_IFBLK 0060000     区块装置
    S_IFDIR 0040000     目录
    S_IFCHR 0020000     字符装置
    S_IFIFO 0010000     先进先出

    S_ISUID 04000     文件的(set user-id on execution)位
    S_ISGID 02000     文件的(set group-id on execution)位
    S_ISVTX 01000     文件的sticky位

    S_IRUSR(S_IREAD) 00400     文件所有者具可读取权限
    S_IWUSR(S_IWRITE)00200     文件所有者具可写入权限
    S_IXUSR(S_IEXEC) 00100     文件所有者具可执行权限

    S_IRGRP 00040             用户组具可读取权限
    S_IWGRP 00020             用户组具可写入权限
    S_IXGRP 00010             用户组具可执行权限

    S_IROTH 00004             其他用户具可读取权限
    S_IWOTH 00002             其他用户具可写入权限
    S_IXOTH 00001             其他用户具可执行权限

    上述的文件类型在POSIX中定义了检查这些类型的宏定义：
    S_ISLNK (st_mode)    判断是否为符号连接
    S_ISREG (st_mode)    是否为一般文件
    S_ISDIR (st_mode)    是否为目录
    S_ISCHR (st_mode)    是否为字符装置文件
    S_ISBLK (s3e)        是否为先进先出
    S_ISSOCK (st_mode)   是否为socket