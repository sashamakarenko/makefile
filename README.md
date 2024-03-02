# makefile
Flexible and simple makefile for c++ projects.

It is basically designed for my personal projects but could be suitable for people who don't want to dive into `GNU Make` or `CMake`.

## Features

- It builds projects of type `lib` and `exe`.
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

The variable `PRJ_TYPE` in your `Makefile` must be either `lib` or `exe`.

### Convention

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
+--- src                             ### Hand written code
|    |
|    +--- prja
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

### Cleaning

### Binary names and version management

### Variables

## Unit tests

build-all-tests

### Extra files

### Dependencies

### Conditions

### Running

### Cleaning

## Bash completion

## Generating vscode workspace

## Examples


[![](https://hits.dwyl.com/sashamakarenko/makefile.svg?style=flat-square&show=unique)](http://hits.dwyl.com/sashamakarenko/makefile)

