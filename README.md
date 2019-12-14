# makefile
Flexible and simple makefile for c++ projects

## How-to

If somewhere in devdir your c++ projects are as

 ```
 devdir
 |
 +___ prj1
 |
 +___ prj2
```

Then clone this project next to your projects

```
 devdir
 |
 +___ prj1
 |
 +___ prj2
 |
 +___ makefile
```

Put your code into src/projectname

```
 devdir
 |
 +___ prj1
 |    |
 |    +___ Makefile
 |    |
 |    +___ src
 |         |
 |         +___ prj1
 |         |    |
 |         |    +___ MyCode.cpp
 |         |
 |         +___ tests
 |              |
 |              +___ TestMyCode.cpp
 |
 +___ prj2
 |
 +___ makefile
```

In every devdir/projectname create a simple Makefile

```makefile
PRJ_NAME    := prj1
PRJ_BRANCH  := 1.0
PRJ_VERSION := $(PRJ_BRANCH).0
PRJ_TYPE    := lib

TEST_EXTRA_LINK_LIBS = -lrt

include ../makefile/Makefile
```

Type make
