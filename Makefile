# Copyright (c) 2021 sashamakarenko
# https://github.com/sashamakarenko/makefile/blob/main/LICENSE

MAKEFILE_UUID=2620b733ccdf47f1bd1b569d96f0d92d

define checkvar
ifeq ($$($1),)
    $$(error $(1) must be defined)
endif
ifneq ($$($1),$$(word 1,$$($1)))
    $$(error $(1) may not contain white spaces)
endif
endef

$(foreach var,PRJ_NAME PRJ_BRANCH PRJ_VERSION PRJ_TYPE,$(eval $(call checkvar,$(var))))

####################### files #########################

SRCDIR := src
CPPEXT := cpp
OBJEXT := o
DEPEXT := mk
TESTEXT:= exe
TESTIND:= done

BUILDDIR   := build
BUILD_MODE ?= release

OBJDIR := $(BUILDDIR)/obj/$(BUILD_MODE)
DEPDIR := $(BUILDDIR)/dep/$(BUILD_MODE)
LIBDIR := $(BUILDDIR)/lib/$(BUILD_MODE)
BINDIR := $(BUILDDIR)/bin/$(BUILD_MODE)

CPP_FILES := $(wildcard $(SRCDIR)/$(PRJ_NAME)/*.$(CPPEXT)) $(GENERATED_CPP_FILES)
ifneq ($(SRCSUBDIRS),)
    CPP_FILES := $(CPP_FILES) $(foreach dir,$(SRCSUBDIRS),$(wildcard $(SRCDIR)/$(PRJ_NAME)/$(dir)/*.$(CPPEXT)))
endif

OBJ_FILES := $(CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(OBJDIR)/%.$(OBJEXT))
DEP_FILES := $(CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(DEPDIR)/%.$(DEPEXT))

ifneq ($(IS_SUBMAKE),true)
TESTDIR := tests
TEST_CPP_DISABLED := $(foreach n,$(DISABLED_TESTS),$(SRCDIR)/$(TESTDIR)/Test$(n).$(CPPEXT))
TEST_CPP_FILES    := $(filter-out $(TEST_CPP_DISABLED),$(wildcard $(SRCDIR)/$(TESTDIR)/Test*.$(CPPEXT)))
TEST_ALLCPP_FILES := $(wildcard $(SRCDIR)/$(TESTDIR)/*.$(CPPEXT))
TEST_OBJ_FILES    := $(TEST_CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(OBJDIR)/%.$(OBJEXT))
TEST_DEP_FILES    := $(TEST_ALLCPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(DEPDIR)/%.$(DEPEXT))
TEST_TARGETS      := $(TEST_CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(BINDIR)/%.$(TESTEXT))
TEST_RUNS         := $(TEST_TARGETS:$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)=test-%)
TEST_GDBS         := $(TEST_TARGETS:$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)=gdb-test-%)
TEST_INDICATORS   := $(TEST_TARGETS:%.$(TESTEXT)=%.$(TESTIND))
TEST_NAMES        := $(filter-out $(DISABLED_TESTS),$(TEST_TARGETS:$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)=%))

testdeps = $(BINDIR)/$(TESTDIR)/Test$(1).$(TESTEXT): $(OBJDIR)/$(TESTDIR)/Test$(1).$(OBJEXT) $(TEST_EXTRA_OBJS_$(1)) $(TARGET) $(TEST_EXTRA_DEPENDENCY) $(Test$(1)_EXTRA_DEPENDENCY)

$(foreach n,$(TEST_NAMES),$(eval TEST_EXTRA_CPPS_$(n):=$(wildcard $(SRCDIR)/$(TESTDIR)/$(n)*.$(CPPEXT))))
$(foreach n,$(TEST_NAMES),$(eval TEST_EXTRA_OBJS_$(n):=$(patsubst $(SRCDIR)/$(TESTDIR)/%.$(CPPEXT),$(OBJDIR)/$(TESTDIR)/%.$(OBJEXT),$(TEST_EXTRA_CPPS_$(n)))))
endif

TARGET :=
TARGET_IS_DYMANIC := true
ifeq ($(PRJ_TYPE),lib)
    ifeq ($(PRJ_BRANCH),)
        $(error PRJ_BRANCH must be defined for libraries)
    endif
    ifeq ($(PRJ_LIB_TYPE),)
        PRJ_LIB_TYPE := dynamic
    endif
    LIB_BASE_NAME    := $(PRJ_NAME)-$(PRJ_BRANCH)
	LIB_NAME         :=
    ifeq ($(PRJ_LIB_TYPE),dynamic)
        LIB_NAME     := lib$(LIB_BASE_NAME).so
        TARGET       := $(LIBDIR)/$(LIB_NAME)
        LINK_OPTIONS += -shared -Wl,--no-undefined -Wl,-soname,$(LIB_NAME)
        SRC_GDB_PRINTER := $(wildcard $(SRCDIR)/gdb/printers.py)
        ifneq ($(SRC_GDB_PRINTER),)
            GDB_PRINTER := $(TARGET)-gdb.py
        endif
    endif
    ifeq ($(PRJ_LIB_TYPE),static)
        LIB_NAME          := lib$(LIB_BASE_NAME).a
        TARGET            := $(LIBDIR)/$(LIB_NAME)
		TARGET_IS_DYMANIC := false
    endif
    ifeq ($(LIB_NAME),)
	    $(error PRJ_LIB_TYPE must be either dynamic or static)
    endif
    LINK_MY_LIB  := -L$(CURDIR)/$(LIBDIR) -l$(LIB_BASE_NAME)
endif

ifeq ($(PRJ_TYPE),exe)
    EXE_NAME     := $(PRJ_NAME)
    TARGET       := $(BINDIR)/$(EXE_NAME)
    LINK_OPTIONS +=
	PRJ_LIB_TYPE :=
endif

ifeq ($(TARGET),)
    $(error PRJ_TYPE must be either lib or exe)
endif

MAKECMD = $(MAKE) -s --no-print-directory
SUBMAKE = $(MAKECMD) IS_SUBMAKE=true
REMAKE  = +$(V)$(MAKECMD)

####################### deps #########################

DEP_DIRS :=
DEPVARS  := $(BUILDDIR)/dependencies.mk

ifneq ($(PRJ_DEPENDENCIES),)

-include $(DEPVARS)

ifeq ($(DEP_DIRS),)
    DEP_DIRECT_DIRS := $(foreach d,$(PRJ_DEPENDENCIES),$(shell readlink -e $d)) 
    DEP_DEP_DIRS    := $(foreach d,$(PRJ_DEPENDENCIES),$(shell $(SUBMAKE) -C $d show-var-DEP_DIRECT_DIRS show-var-DEP_DEP_DIRS))
	ifneq ($(IS_SUBMAKE),true)
        depdirs = DEP_DIRS:=$(filter-out $(1),$(DEP_DIRS)) $(1)
	    blank  :=
	    space  := $(blank) $(blank)
        $(foreach d,$(DEP_DIRECT_DIRS) $(DEP_DEP_DIRS),$(eval $(call depdirs,$(d)) ) )
        DEP_LINK_OPTIONS:= $(foreach d,$(DEP_DIRS),$(shell $(SUBMAKE) -C $d show-var-LINK_MY_LIB))
        DEP_INCLUDES    := $(foreach d,$(DEP_DIRS),-I$d/src)
        DEP_TARGETS     := $(foreach d,$(DEP_DIRS),$d/$(shell $(SUBMAKE) -C $d show-var-TARGET))
        DEP_LD_LIB_PATH := $(foreach d,$(DEP_DIRS),$d/$(LIBDIR):)
	    DEP_LD_LIB_PATH := $(subst $(space),,$(DEP_LD_LIB_PATH))
	endif
#$(warning $(PRJ_NAME):DEP_DIRS=$(DEP_DIRS))
#$(info DEP_LINK_OPTIONS=$(DEP_LINK_OPTIONS))
#$(info DEP_TARGETS=$(DEP_TARGETS))
#$(warning $(IS_SUBMAKE) $(CURDIR) / $(DEP_DIRS))
endif

BUILD_DEPS := build-deps

endif

####################### c++ #########################

COMPILER  := c++
CPP_STD   ?= -std=c++17

ifeq ($(BUILD_MODE),release)
    CPP_OPTIM := -O3 -DNDEBUG
else
    CPP_OPTIM := -O0
endif

CPP_PLT      := -fno-plt
CPP_PIC      ?= -fPIC
CPP_OPTIONS  += $(CPP_STD) $(CPP_OPTIM) $(CPP_PIC) $(CPP_PLT) -g -I$(SRCDIR) $(CPP_INCLUDES) $(DEP_INCLUDES) $(CPP_DEFINES) $(CPP_EXTRA_FLAGS)

V=@

####################### rules #########################

all: $(TARGET)

debug release:
	$(REMAKE) BUILD_MODE=$@

$(TARGET): $(OBJ_FILES) $(DEP_TARGETS) $(TARGET_EXTRA_DEPENDENCY) $(GDB_PRINTER) | $(BUILD_DEPS)
	$(V)mkdir -p $(@D)
	$(V)echo "  linking $@"
ifeq ($(PRJ_LIB_TYPE),static)
	$(V)ar csr $@  $(OBJ_FILES)
else
	$(V)$(COMPILER) $(CPP_OPTIM) $(LINK_OPTIONS) $(CPP_PLT) -g -o $@ $(OBJ_FILES) $(DEP_LINK_OPTIONS) $(LINK_EXTRA_LIBS)
endif
ifneq ($(PRJ_POSTBUILD_TARGET),)
	$(REMAKE) $(PRJ_POSTBUILD_TARGET)
endif

ifneq ($(SRC_GDB_PRINTER),)
$(GDB_PRINTER): $(SRC_GDB_PRINTER)
	$(V)mkdir -p $(@D)
	$(V)echo "  making $@"
	$(V)cp -f $< $@
	$(V)sed -e "s/__PRJ_NAME__/$(PRJ_NAME)/g" -e "s/__PRJ_BRANCH__/$(PRJ_BRANCH)/g" -i $@
endif

$(OBJDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(CPPEXT)
	$(V)echo "  [$(BUILD_MODE)] compiling $<"
	$(V)mkdir -p $(dir $(DEPDIR)/$*)
	$(V)$(COMPILER) $(CPP_OPTIONS) -MT $@ -MM -MP -MF $(DEPDIR)/$*.$(DEPEXT) $<
	$(V)sed "s%$@:%$@ $(DEPDIR)/$*.$(DEPEXT):%g" -i $(DEPDIR)/$*.$(DEPEXT)
	$(V)mkdir -p $(@D)
	$(V)$(COMPILER) $(CPP_OPTIONS) -c -o $@  $$PWD/$<

$(DEPDIR)/$(TESTDIR)/Test%.$(DEPEXT): $(OBJDIR)/$(TESTDIR)/Test%.$(OBJEXT)

ifneq ($(PRJ_DEPENDENCIES),)
$(DEPVARS): Makefile
	$(V)mkdir -p $(@D)
	$(V)echo "DEP_DIRS=$(DEP_DIRS)" > $@
	$(V)echo "DEP_INCLUDES=$(DEP_INCLUDES)" >> $@
	$(V)echo "DEP_LINK_OPTIONS=$(DEP_LINK_OPTIONS)" >> $@
	$(V)echo "DEP_LD_LIB_PATH=$(DEP_LD_LIB_PATH)" >> $@
	$(V)echo "DEP_TARGETS=$(DEP_TARGETS)" >> $@
endif

####################### dependencies #########################

.PHONY: build-deps clean-deps rebuild-all rebuild

ifneq ($(DEP_DIRS),)

define deplib
$(1):
	@echo "  Building $(1)"; $(MAKECMD) -C $(2)
endef
$(foreach d,$(DEP_DIRS),$(eval $(call deplib,$d/$(shell $(SUBMAKE) -C $d show-var-TARGET),$d)) )

build-deps:
	+$(V)for d in $(DEP_DIRS); do $(MAKECMD) -C $$d; done

clean-deps:
	+$(V)for d in $(DEP_DIRS); do $(MAKECMD) -C $$d clean; done

clean-all: clean-deps clean

else

build-deps clean-deps:

endif

rebuild:
	$(REMAKE) clean
	$(REMAKE)

rebuild-all:
	$(REMAKE) clean-deps clean
	$(REMAKE)

####################### tests #########################

.SECONDARY:

$(OBJDIR)/$(TESTDIR)/Test%.$(OBJEXT): CPP_INCLUDES    += $(TEST_INCLUDES)
$(OBJDIR)/$(TESTDIR)/Test%.$(OBJEXT): CPP_DEFINES     += $(TEST_DEFINES)
$(OBJDIR)/$(TESTDIR)/Test%.$(OBJEXT): CPP_EXTRA_FLAGS += $($(*F)_EXTRA_CPP_FLAGS)

$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT): TEST_CPP_EXTRA_FILES = $(wildcard $(SRCDIR)/$(TESTDIR)/$**.$(CPPEXT))
$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT): TEST_OBJ_EXTRA_FILES = $(TEST_CPP_EXTRA_FILES:$(SRCDIR)/%.$(CPPEXT)=$(OBJDIR)/%.$(OBJEXT))
$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT): TEST_SPECIFIC_LINK   = $(Test$(*F)_EXTRA_LINK_FLAGS)
$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT): $(Test$*_EXTRA_DEPENDENCY)
	$(V)mkdir -p $(@D)
	$(V)echo "  linking $@"
	$(V)$(COMPILER) $(CPP_OPTIM) $(CPP_PLT) -g -o $@  $< $(TEST_OBJ_EXTRA_FILES) $(LINK_MY_LIB) $(DEP_LINK_OPTIONS) $(LINK_EXTRA_LIBS) $(TEST_EXTRA_LINK_LIBS) $(TEST_SPECIFIC_LINK)

$(BINDIR)/$(TESTDIR)/Test%.$(TESTIND): $(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)
	$(V)echo; echo; str="########################### testing $* ###########################"; if test -t 1; then printf "\e[36;1m$$str\e[0m\n"; else echo "$$str"; fi
	$(V)export LD_LIBRARY_PATH=$(LIBDIR):$(DEP_LD_LIB_PATH)$(TEST_EXTRA_LD_PATH):$(Test$*_EXTRA_LD_PATH):$$LD_LIBRARY_PATH; $(TEST_LAUNCHER) $(Test$*_EXTRA_LAUNCHER) ./$< $(TEST_ARGS_$*)
	$(V)echo; echo; echo "########################### end of test $* ###########################"; echo; echo
	$(V)touch $@

test-%: $(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)
	$(V)export LD_LIBRARY_PATH=$(LIBDIR):$(DEP_LD_LIB_PATH)$(TEST_EXTRA_LD_PATH):$(Test$*_EXTRA_LD_PATH):$$LD_LIBRARY_PATH; $(TEST_LAUNCHER) $(Test$*_EXTRA_LAUNCHER) ./$< $(TEST_ARGS_$*)

gdb-test-%: $(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)
	$(V)export LD_LIBRARY_PATH=$(LIBDIR):$(DEP_LD_LIB_PATH)$(TEST_EXTRA_LD_PATH):$$LD_LIBRARY_PATH; gdb ./$<

ifneq ($(TEST_DEP_FILES),)

$(foreach n,$(TEST_NAMES),$(eval $(call testdeps,$(n))))

build-all-tests: $(TEST_TARGETS)

-include $(TEST_DEP_FILES)

endif

####################### internals #########################

.PHONY: find-makefile-dir #show-var-DEP_DIRECT_DIRS show-var-DEP_DEP_DIRS show-var-LINK_MY_LIB show-var-TARGET

show-var-%:
	$(V)echo $($*)

find-makefile-dir:
	$(V)for f in $(MAKEFILE_LIST); do \
	if test Makefile = $$(basename $$f) -a "x$(MAKEFILE_UUID)" = "x$$(sed -n '/^MAKEFILE_UUID=/s/.*=\(.*\)/\1/gp' $$f)"; then \
	    readlink -e $$(dirname $$f); \
		break; \
	fi;\
	done

generate-vscode: MAKEFILE_DIR=$(shell $(SUBMAKE) find-makefile-dir)
generate-vscode:
	$(V)$(MAKEFILE_DIR)/generate-vscode.sh $(CURDIR) $(DEP_DIRS)

####################### launching #########################

.PHONY: check go ldd recheck clean-test-indicators clean-tests build-all-tests

ifeq ($(PRJ_TYPE),exe)
go: $(TARGET)
	$(V)export LD_LIBRARY_PATH=$(LD_PATH):$(DEP_LD_LIB_PATH):$$LD_LIBRARY_PATH; ./$< $(ARGS)
else
go:
	$(V)echo "project is not an executable"
	$(V)false
endif

gdb-%:
	$(REMAKE) BUILD_MODE=$* gdb

ifeq ($(PRJ_TYPE),exe)
gdb: $(TARGET)
	$(V)export LD_LIBRARY_PATH=$(LD_PATH):$(DEP_LD_LIB_PATH):$$LD_LIBRARY_PATH; gdb ./$<
else
gdb:
	$(V)echo "project is not an executable"
	$(V)false
endif

ifeq ($(TARGET_IS_DYMANIC),true)
ldd: $(TARGET)
	$(V)export LD_LIBRARY_PATH=$(LD_PATH):$(DEP_LD_LIB_PATH):$$LD_LIBRARY_PATH; ldd ./$<
else
ldd:
	$(V)echo "project is neither executable nor dynamic library"
	$(V)false
endif

check: $(TEST_INDICATORS)

recheck: clean-test-indicators
	$(REMAKE) check

####################### cleaning #########################

clean-test-indicators:
	$(V)rm -f $(TEST_INDICATORS)

clean-tests::
	$(V)rm -rf $(BINDIR)/$(TESTDIR) $(OBJDIR)/$(TESTDIR) $(DEPDIR)/$(TESTDIR)

clean-test-%:
	$(V)rm -f $(OBJDIR)/$(TESTDIR)/Test$*.$(OBJEXT) $(BINDIR)/$(TESTDIR)/Test$*.$(TESTEXT)

clean::
	$(V)rm -rf $(BUILDDIR)

-include $(DEP_FILES)

