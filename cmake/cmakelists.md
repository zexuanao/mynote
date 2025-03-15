# 概述
过程：
预处理->编译->汇编->链接->可执行文件
cmake-> CMakeLists.txt->cmake->makefile->make
这会生成可执行文件，也会生成库（动态和静态）
# 编写一个简单的CMakeLists.txt文件
\#注释
\#[[]]块注释

1.cmake_minimum_required:指定使用的cmake的最低版本
2.project：定义工程名称，并可指定工程的版本、工程描述、web主页地址、支持的语言（默认情况支持所有语言），如果不需要这些都是可以忽略的，只需要指定出工程名字即可。
```
# PROJECT 指令的语法是：
project(<PROJECT-NAME> [<language-name>...])
project(<PROJECT-NAME>
       [VERSION <major>[.<minor>[.<patch>[.<tweak>]]]]
       [DESCRIPTION <project-description-string>]
       [HOMEPAGE_URL <url-string>]
       [LANGUAGES <language-name>...])
```
3.add_executable(可执行程序名 源文件名称)
源文件名称之间可以用空格或者;间隔
注意：windows上使用cmake第一次要用cmake .. -G "Unix Makefiles"，因为cmake在windows上默认编译方式不是类Unix
# 定义变量
在上面的例子中一共提供了5个源文件，假设这五个源文件需要反复被使用，每次都直接将它们的名字写出来确实是很麻烦，此时我们就需要定义一个变量，将文件名对应的字符串存储起来，在cmake里定义变量需要使用set。
## 方式1: 各个源文件之间使用空格间隔
```
set(SRC_LIST add.c  div.c   main.c  mult.c  sub.c)
```
## 方式2: 各个源文件之间使用分号 ; 间隔
```
set(SRC_LIST add.c;div.c;main.c;mult.c;sub.c)
add_executable(app  ${SRC_LIST})
```
# 指定使用的C++标准
在 CMakeLists.txt 中通过 set 命令指定
```
#增加-std=c++11
set(CMAKE_CXX_STANDARD 11)
#增加-std=c++14
set(CMAKE_CXX_STANDARD 14)
#增加-std=c++17
set(CMAKE_CXX_STANDARD 17)
在执行 cmake 命令的时候指定出这个宏的值

#增加-std=c++11
cmake CMakeLists.txt文件路径 -DCMAKE_CXX_STANDARD=11
#增加-std=c++14
cmake CMakeLists.txt文件路径 -DCMAKE_CXX_STANDARD=14
#增加-std=c++17
cmake CMakeLists.txt文件路径 -DCMAKE_CXX_STANDARD=17
```
# 指定输出的路径
在CMake中指定可执行程序输出的路径，也对应一个宏，叫做EXECUTABLE_OUTPUT_PATH，它的值还是通过set命令进行设置:

set(HOME /home/robin/Linux/Sort)
set(EXECUTABLE_OUTPUT_PATH ${HOME}/bin)
# 搜索文件
如果一个项目里边的源文件很多，在编写CMakeLists.txt文件的时候不可能将项目目录的各个文件一一罗列出来，这样太麻烦也不现实。所以，在CMake中为我们提供了搜索文件的命令，可以使用aux_source_directory命令或者file命令。
```
# aux_source_directory
aux_source_directory(< dir > < variable >)

示例：
cmake_minimum_required(VERSION 3.0)
project(MyProject)
include_directories(${PROJECT_SOURCE_DIR}/include)

# 搜索 src 目录下的所有源文件
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src SRC_LIST)

# 根据搜索到的源文件创建可执行文件
add_executable(app ${SRC_LIST})


#file
file(GLOB/GLOB_REVERSE <variable> [LIST_DIRECTORIES true[false]] [RELATIVE <path> ] [CONFIGURE_DEPENDS] [<globbing-expression> ...])
RECURSE是递归的意思


示例：
cmake_minimum_required(VERSION 3.0)
project(MyProject)

# 搜索当前目录的src目录下所有的.cpp源文件
file(GLOB MAIN_SRC "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

# 搜索当前目录的include目录下所有的头文件
file(GLOB MAIN_HEAD "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")

# 根据搜索到的源文件和头文件创建可执行文件
add_executable(app ${MAIN_SRC} ${MAIN_HEAD})

```
# 包含头文件
在编译项目源文件的时候，很多时候都需要将源文件对应的头文件路径指定出来，这样才能保证在编译过程中编译器能够找到这些头文件，并顺利通过编译。在CMake中设置要包含的目录也很简单，通过一个命令就可以搞定了，他就是include_directories
# 制作静态库或动态库
静态库：
add_library(库名称 STATIC 源文件1 [源文件2] ...) 
动态库：
add_library(库名称 SHARED 源文件1 [源文件2] ...) 

输出路径：
动态库和可执行文件都是可以通过改变executable_output_path来决定
对于静态和动态都适用的是LIBRARY_OUTPUT_PATH

链接库
静态库：
link_libraries(<static lib> [<static lib>...])
也可以直接加路径
link_directories(${PROJECT_SOURCE_DIR}/lib)
动态库：
target_link_libraries(app pthread)
动态库在生成可执行程序的链接阶段不会被打包到可执行程序中，当可执行程序被启动并且调用了动态库中的函数的时候，动态库才会被加载到内存，所以应该将命令写到生成了可执行文件之后


通过命令指定出要链接的动态库的位置，指定静态库位置使用的也是这个命令：
link_directories(path)
# 日志
##  输出一般日志信息
message(STATUS "source path: ${PROJECT_SOURCE_DIR}")
##  输出警告信息
message(WARNING "source path: ${PROJECT_SOURCE_DIR}")
## 输出错误信息
message(FATAL_ERROR "source path: ${PROJECT_SOURCE_DIR}")

# 变量操作
##  追加
```
cmake_minimum_required(VERSION 3.0)
project(TEST)
set(TEMP "hello,world")
file(GLOB SRC_1 ${PROJECT_SOURCE_DIR}/src1/*.cpp)
file(GLOB SRC_2 ${PROJECT_SOURCE_DIR}/src2/*.cpp)
```
##  追加(拼接)
```
set(SRC_1 ${SRC_1} ${SRC_2} ${TEMP})
message(STATUS "message: ${SRC_1}")
```
也可以使用list：
```
list(APPEND <list> [<element> ...])
```
## list
不仅可以用来链接（append）
也可以用来移除：
```
cmake_minimum_required(VERSION 3.0)
project(TEST)
set(TEMP "hello,world")
file(GLOB SRC_1 ${PROJECT_SOURCE_DIR}/*.cpp)
##  移除前日志
message(STATUS "message: ${SRC_1}")
##  移除 main.cpp
list(REMOVE_ITEM SRC_1 ${PROJECT_SOURCE_DIR}/main.cpp)
##  移除后日志
message(STATUS "message: ${SRC_1}")
```
关于list命令还有其它功能，但是并不常用，在此就不一一进行举例介绍了。
```
获取 list 的长度。

list(LENGTH <list> <output variable>)
LENGTH：子命令LENGTH用于读取列表长度
<list>：当前操作的列表
<output variable>：新创建的变量，用于存储列表的长度。
读取列表中指定索引的的元素，可以指定多个索引

list(GET <list> <element index> [<element index> ...] <output variable>)
<list>：当前操作的列表
<element index>：列表元素的索引
从0开始编号，索引0的元素为列表中的第一个元素；
索引也可以是负数，-1表示列表的最后一个元素，-2表示列表倒数第二个元素，以此类推
当索引（不管是正还是负）超过列表的长度，运行会报错
<output variable>：新创建的变量，存储指定索引元素的返回结果，也是一个列表。
将列表中的元素用连接符（字符串）连接起来组成一个字符串

list (JOIN <list> <glue> <output variable>)
<list>：当前操作的列表
<glue>：指定的连接符（字符串）
<output variable>：新创建的变量，存储返回的字符串
查找列表是否存在指定的元素，若果未找到，返回-1

list(FIND <list> <value> <output variable>)
<list>：当前操作的列表
<value>：需要再列表中搜索的元素
<output variable>：新创建的变量
如果列表<list>中存在<value>，那么返回<value>在列表中的索引
如果未找到则返回-1。
将元素追加到列表中

list (APPEND <list> [<element> ...])
在list中指定的位置插入若干元素

list(INSERT <list> <element_index> <element> [<element> ...])
将元素插入到列表的0索引位置

list (PREPEND <list> [<element> ...])
将列表中最后元素移除

list (POP_BACK <list> [<out-var>...])
将列表中第一个元素移除

list (POP_FRONT <list> [<out-var>...])
将指定的元素从列表中移除

list (REMOVE_ITEM <list> <value> [<value> ...])
将指定索引的元素从列表中移除

list (REMOVE_AT <list> <index> [<index> ...])
移除列表中的重复元素

list (REMOVE_DUPLICATES <list>)
列表翻转

list(REVERSE <list>)
列表排序

list (SORT <list> [COMPARE <compare>] [CASE <case>] [ORDER <order>])
COMPARE：指定排序方法。有如下几种值可选：
STRING:按照字母顺序进行排序，为默认的排序方法
FILE_BASENAME：如果是一系列路径名，会使用basename进行排序
NATURAL：使用自然数顺序排序
CASE：指明是否大小写敏感。有如下几种值可选：
SENSITIVE: 按照大小写敏感的方式进行排序，为默认值
INSENSITIVE：按照大小写不敏感方式进行排序
ORDER：指明排序的顺序。有如下几种值可选：
ASCENDING:按照升序排列，为默认值
DESCENDING：按照降序排列
```
# 宏定义
gcc test.c -DDEBUG -o app
相当于定义了一个宏
cmake也可以
add_definitions(-D宏名称)
# 常用的宏
下面的列表中为大家整理了一些CMake中常用的宏：

宏	功能
PROJECT_SOURCE_DIR	使用cmake命令后紧跟的目录，一般是工程的根目录
PROJECT_BINARY_DIR	执行cmake命令的目录
CMAKE_CURRENT_SOURCE_DIR	当前处理的CMakeLists.txt所在的路径
CMAKE_CURRENT_BINARY_DIR	target 编译目录
EXECUTABLE_OUTPUT_PATH	重新定义目标二进制可执行文件的存放位置
LIBRARY_OUTPUT_PATH	重新定义目标链接库文件的存放位置
PROJECT_NAME	返回通过PROJECT指令定义的项目名称
CMAKE_BINARY_DIR	项目实际构建路径，假设在build目录进行的构建，那么得到的就是这个目录的路径

# 嵌套的cmake
作用域：
根节点CMakeLists.txt中的变量全局有效
父节点CMakeLists.txt中的变量可以在子节点中使用
子节点CMakeLists.txt中的变量只能在当前节点中使用

如何添加子目录
add_subdirectory(source_dir [binary_dir] [EXCLUDE_FROM_ALL])
source_dir：指定了CMakeLists.txt源文件和代码文件的位置，其实就是指定子目录
binary_dir：指定了输出文件的路径，一般不需要指定，忽略即可。
EXCLUDE_FROM_ALL：在子路径下的目标默认不会被包含到父路径的ALL目标里，并且也会被排除在IDE工程文件之外。用户必须显式构建在子路径下的目标。
`一般直接add_subdirectory（子目录）就可以了`
<br>
# 流程控制
## 条件判断
if(<condition>)
  <commands>
elseif(<condition>) # 可选快, 可以重复
  <commands>
else()              # 可选快
  <commands>
endif()
## 逻辑判断
NOT
AND
OR
## 比较
LESS：如果左侧数值小于右侧，返回True
GREATER：如果左侧数值大于右侧，返回True
EQUAL：如果左侧数值等于右侧，返回True
LESS_EQUAL：如果左侧数值小于等于右侧，返回True
GREATER_EQUAL：如果左侧数值大于等于右侧，返回True
字符串的比较在前面加上STR就可以了
## 文件操作
判断文件或者目录是否存在
if(EXISTS path-to-file-or-directory)
判断是不是目录
if(IS_DIRECTORY path)
判断是不是软连接
if(IS_SYMLINK file-name)
判断是不是绝对路径
if(IS_ABSOLUTE path)
## 其他
判断某个元素是否在列表中
if(<variable|string> IN_LIST <variable>)
比较两个路径是否相等
if(<variable|string> PATH_EQUAL <variable|string>)
关于路径的比较其实就是另个字符串的比较，如果路径格式书写没有问题也可以通过下面这种方式进行比较：
if(<variable|string> STREQUAL <variable|string>)

# 循环
## foreach
使用 foreach 进行循环，语法格式如下：
```
foreach(<loop_var> <items>)
    <commands>
endforeach()
```
```
foreach(<loop_var> RANGE <start> <stop> [<step>])
```
```
foreach(<loop_var> IN [LISTS [<lists>]] [ITEMS [<items>]])
//分别对两个变量进行循环检测

```
## while
除了使用foreach也可以使用 while 进行循环，关于循环结束对应的条件判断的书写格式和if/elseif 是一样的。while的语法格式如下：
```
while(<condition>)
    <commands>
endwhile()
```
