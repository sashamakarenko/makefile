PRJ_NAME    := peugeot
PRJ_BRANCH  := 207.0
PRJ_VERSION := $(PRJ_BRANCH).0
PRJ_TYPE    := exe
PRJ_DEPENDENCIES := ../04-dll-car

# for vscode generation dev only

# see defines in c_cpp_properties.json
CPP_DEFINES  = -DABC   -DAN_INCLUDE="<$(PRJ_NAME)/ExtraInclude.h>" -DTITLE='"Tile with wite spaces"'  	-DXYZ=123

# see includePath in c_cpp_properties.json
CPP_INCLUDES = -I . -I./src/$(PRJ_NAME) -I"/usr/include"

# for debuging in launch.json
# ARGS := test

include ../../Makefile
