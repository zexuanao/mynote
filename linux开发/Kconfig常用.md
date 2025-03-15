# mainmenu
顾名思义，主菜单

# 调用其他Kconfig文件
使用source

# menu/endmenu条目
用于生成菜单

# config
菜单的具体配置项
选择了就会在.config文件中生成CONFIG_XXX
具体配置项有几种类型：

1. bool y/n
2. tristate y/n/m
3. string   
4. hex
5. int

# depends on和select
depends on a依赖b
b选中后a才能选中

select a方向依赖b
a选中了那么b也会被选中

# choice/endchoice
定义一组可配置项，里面一般还会有config，用来配置单选还是多选的


# menuconfig
menuconfig和menu很像但是他带选项
一般用法：
```
menuconfig MODULES
    bool ""
if MODULES
...
endif # MODULES
```

# comment
用于注释

