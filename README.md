# makefile
Flexible and simple makefile for c++ projects.

It is basically designed for my personal projects but could be suitable for people who don't want to dive into `GNU Make` or `CMake`.

## Features

- It builds projects of type `lib`, `exe` and `inc`.
- Supports `release` and `debug` compilation modes.
- Builds and launches unit tests.
- Launches exe and unit tests with GDB.
- Supports pretty printers for GDB.
- Supports parallel builds.
- Works by convention. No need to list source files etc.
- Produces dynamic libraries with the project's branch in name to allow patches.
- bash completion is available.
- Supports [vscode](https://code.visualstudio.com/) workspace generation.

## How-to

If somewhere in `devdir` your c++ projects are as

```
 devdir
 |
 +--- prja
 |
 +--- prjb
```

Then clone this project next to your projects

```
 devdir
 |
 +--- prja
 |
 +--- prjb
 |
 +--- makefile
```

Put your code into `src/projectname`

```
 devdir
 |
 +--- prja
 |    |
 |    +--- Makefile
 |    |
 |    +--- src
 |         |
 |         +--- prja
 |         |    |
 |         |    +--- MyCode.h
 |         |    |
 |         |    +--- MyCode.cpp
 |         |
 |         +--- tests
 |         |    |
 |         |    +--- TestMyCode.cpp
 |         |
 |         +--- gdb
 |              |
 |              +--- printers.py
 |
 +--- prjb
 |
 +--- makefile
```

In every `devdir/projectname` create a simple `Makefile`

```makefile
PRJ_NAME    := prja
PRJ_BRANCH  := 1.0
PRJ_VERSION := $(PRJ_BRANCH).0
PRJ_TYPE    := lib

include ../makefile/Makefile
```

Type make to build your binary.

## Compilation

The variable `PRJ_TYPE` in your `Makefile` must be `lib`, `exe` or `inc`.

### Project layout convention

|directory|project types|optional|contents|
|---------|-------------|--------|-----------|
| `src/$(PRJ_NAME)` | all | no | .h and .cpp files to compile |
| `src/tests` | `lib` `inc` | yes | unit tests |
| `src/gdb` | `lib` `exe` | yes | pretty printers |
| `build` | all | - | build results and temporary files |


### Build mode

The variable `BUILD_MODE` controls compilation options. It can be either `release` or `debug` and defaults to `release`.

```bash
# release:
$> make
# is the same as
$> make BUILD_MODE=release
# or
$> make release

# debug:
$> make debug
# is the same as
$> make BUILD_MODE=debug
```

The compilation result and temporary files will all go into the `build` directory.

For instance, the project `prja` depicted above, after building the library and unit tests will become as follows:

```
prja
|
+--- Makefile
|
+--- src                             ### Source code
|    |
|    +--- prja
|    |    |
|    |    +--- PrjInfo.h             ### Generated project meta information
|    |    |
|    |    +--- MyCode.h
|    |    |
|    |    +--- MyCode.cpp
|    |
|    +--- tests
|    |    |
|    |    +--- TestMyCode.cpp
|    |
|    +--- gdb
|         |
|         +--- printers.py
|
+--- build                           ### Build directory
     |
     +--- dep                        ### C++ dependencies
     |    |
     |    +--- debug
     |    |    |
     |    |    +--- prja
     |    |    |    |
     |    |    |    +--- MyCode.mk
     |    |    |
     |    |    +--- tests
     |    |         |
     |    |         +--- TestMyCode.mk
     |    |
     |    +--- release
     |         |
     |         +--- prja
     |         |    |
     |         |    +--- MyCode.mk
     |         |
     |         +--- tests
     |              |
     |              +--- TestMyCode.mk
     |
     +--- obj                        ### Objects
     |    |
     |    +--- debug
     |    |    |
     |    |    +--- prja
     |    |    |    |
     |    |    |    +--- MyCode.o
     |    |    |
     |    |    +--- tests
     |    |         |
     |    |         +--- TestMyCode.o
     |    |
     |    +--- release
     |         |
     |         +--- prja
     |         |    |
     |         |    +--- MyCode.o
     |         |
     |         +--- tests
     |              |
     |              +--- TestMyCode.o
     |
     +--- lib                        ### Target libraries if project types is lib
     |    |
     |    +--- debug
     |    |    |
     |    |    +--- libprja-1.0.so
     |    |    |
     |    |    +--- libprja-1.0.so-gdb.py
     |    |
     |    +--- release
     |         |
     |         +--- libprja-1.0.so
     |         |
     |         +--- libprja-1.0.so-gdb.py
     |
     +--- bin                        ### Unit tests if the project is a lib otherwise
          |                          ### target executables
          +--- debug
          |    |
          |    +--- tests
          |         |
          |         +--- TestMyCode.exe
          |
          +--- release
               |
               +--- tests
                    |
                    +--- TestMyCode.exe

```

Thus putting `build` into `.gitignore` will easily exclude all temporary files.

`Makefile` will create `src/$(PRJ_NAME)/PrjInfo.h` file.
If you want to disable this feature do this:
```Makefile
PRJ_INFO :=
```
### Source in sub-directories

You can set the variable `SRCSUBDIRS` if you have to keep some of your code in sub-directories.
For example for a project like:
```
prja
|
+--- src
|    |
|    +--- prja
|    |    |
|    |    +--- impl
|    |    |    |
|    |    |    +--- generated
|    |    |    |    |
|    |    |    |    +--- Stub.h
|    |    |    |    |
|    |    |    |    +--- Stub.cpp
|    |    |    |
|    |    |    +--- ApiImpl.h
|    |    |    |
|    |    |    +--- ApiImpl.cpp
|    |    |
|    |    +--- Api.h
|    |    |
|    |    +--- Api.cpp
|    |
```

you will need:

```Makefile
SRCSUBDIRS = impl impl/generated
```

### Running

- `make go` will launch your executable.
- `make gdb` will start GDB with your executable and `LD_LIBRARY_PATH` set properly.
- `make ldd` will launch ldd with your binary and `LD_LIBRARY_PATH` set properly.

### Cleaning

- `make clean` will remove `./build`
- `make clean-deps` will clean dependencies
- `make clean-all` will clean dependencies and your project

### Binary names and version management

### Other variables

| variable             | default value       |description|
|----------------------|---------------------|-----------|
| CPPEXT               | cpp                 | C++ files extension |
| COMPILER             | c++                 | Compiler command |
| CPP_STD              | -std=c++17          | C++ standard |
| CPP_OPTIM            | -O0 or -O3 -DNDEBUG | Optimization options |
| CPP_PLT              | -fno-plt            | PLT option |
| CPP_PIC              | -fPIC               | PIC option |
| CPP_DEFINES          |                     | passed to the compiler |
| CPP_INCLUDES         |                     | passed to the compiler |
| CPP_EXTRA_FLAGS      |                     | passed to the compiler |
| LINK_EXTRA_LIBS      |                     | passed to the linker |
| PRJ_POSTBUILD_TARGET |                     | any post build target |

### GDB pretty printers

Write your pretty printers in `src/gdb/printers.py` and it will be copied next to your binary so that GDB will recognize it. See `examples/02-dll-engine/src/gdb/printers.py`.

## Unit tests

All unit test files `src/tests/Test*.cpp` are automatically detected. They are considered as separate executables.
For instance a `TestXXX.cpp` will be built as `bin/release/tests/TestXXX.exe`.

- `make check` will build and launch all unit tests. Running it again will not launch the tests already done. 
- `make recheck` will build if necessary and launch all unit tests.
- `make test-XXX` will build and launch only `bin/release/tests/TestXXX.exe`. Typing `make test-[TAB][TAB]` will propose all available tests if the bash completion has been activated.
- `make test-XXX BUILD_MODE=debug` will build and launch only `bin/debug/tests/TestXXX.exe`
- `make build-all-tests` will only build all unit tests.
- `make gdb-test-XXX [BUILD_MODE=debug]` will build and launch your tests in GDB.
- `make clean-tests` will clean only test related files.

### Extra source files

If a unit test `TestXXX.cpp` requires extra files write them as `XXX*.cpp` and they will be compiled and linked along with `TestXXX.cpp`.
Example `examples/02-dll-engine/src/tests/TestAnything.cpp`.

### Variables

| variable                 |applies to test|description|
|--------------------------|----------------|-----------|
| TEST_INCLUDES            | all  | passed to the compiler  |
| TEST_DEFINES             | all  | passed to the compiler  |
| TEST_EXTRA_LINK_LIBS     | all  | passed to the linker  |
| TEST_EXTRA_DEPENDENCY    | all  | built before all unit tests  |
| TestXXX_EXTRA_LD_PATH    | XXX  | injected into `LD_LIBRARY_PATH` for launching the test XXX |
| TestXXX_EXTRA_DEPENDENCY | XXX  | built before the test XXX |


### Disabling specific tests

If fore some reasons you have to disable unit tests XXX and YYY do this:

```Makefile
DISABLED_TESTS = XXX YYY
```

### Trivial helper

One can use any unit test framework. Just feed properly the variables `TEST_INCLUDES` and `TEST_EXTRA_LINK_LIBS`.
If a very simple condition verification is enough, you can use the trivial helper file coming with this makefile.

```c++
#include <utests/TrivialHelper.h>
...
CHECK( engine max power, engine.getMaxPower(), >100 )
CHECK( battery charged, battery.getCharge(), >20 )
...
```

The default behavior is to display all check results independently wether they fail or not.
If you want to stop execution on the very first failed condition.
```makefile
TEST_DEFINES = -DEXIT_ON_ERROR
```

## Bash completion

## Generating vscode workspace

## Examples


[![](https://hits.dwyl.com/sashamakarenko/makefile.svg?style=flat-square&show=unique)](http://hits.dwyl.com/sashamakarenko/makefile)

