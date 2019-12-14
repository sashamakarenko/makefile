
ifeq ($(PRJ_NAME),)
    $(error PRJ_NAME must be defined)
endif

ifeq ($(PRJ_BRANCH),)
    $(error PRJ_BRANCH must be defined)
endif

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

CPP_FILES := $(wildcard $(SRCDIR)/$(PRJ_NAME)/*.$(CPPEXT))
OBJ_FILES := $(CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(OBJDIR)/%.$(OBJEXT))
DEP_FILES := $(CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(DEPDIR)/%.$(DEPEXT))


TESTDIR := tests
TEST_CPP_FILES    := $(wildcard $(SRCDIR)/$(TESTDIR)/Test*.$(CPPEXT))
TEST_ALLCPP_FILES := $(wildcard $(SRCDIR)/$(TESTDIR)/*.$(CPPEXT))
TEST_OBJ_FILES := $(TEST_CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(OBJDIR)/%.$(OBJEXT))
TEST_DEP_FILES := $(TEST_ALLCPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(DEPDIR)/%.$(DEPEXT))
TEST_TARGETS   := $(TEST_CPP_FILES:$(SRCDIR)/%.$(CPPEXT)=$(BINDIR)/%.$(TESTEXT))
TEST_RUNS      := $(TEST_TARGETS:$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)=test-%)
TEST_GDBS      := $(TEST_TARGETS:$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)=gdb-test-%)
TEST_INDICATORS:= $(TEST_TARGETS:%.$(TESTEXT)=%.$(TESTIND))
TEST_NAMES     := $(TEST_TARGETS:$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)=%)

testdeps = $(BINDIR)/$(TESTDIR)/Test$(1).$(TESTEXT): $(OBJDIR)/$(TESTDIR)/Test$(1).$(OBJEXT) $(TEST_EXTRA_OBJS_$(1)) $(TARGET) $(TEST_EXTRA_DEPENDENCY)

$(foreach n,$(TEST_NAMES),$(eval TEST_EXTRA_CPPS_$(n):=$(wildcard $(SRCDIR)/$(TESTDIR)/$(n)*.$(CPPEXT))))
$(foreach n,$(TEST_NAMES),$(eval TEST_EXTRA_OBJS_$(n):=$(patsubst $(SRCDIR)/$(TESTDIR)/%.$(CPPEXT),$(OBJDIR)/$(TESTDIR)/%.$(OBJEXT),$(TEST_EXTRA_CPPS_$(n)))))

TARGET :=
ifeq ($(PRJ_TYPE),lib)
    LIB_NAME     := lib$(PRJ_NAME)-$(PRJ_BRANCH).so
    TARGET       := $(LIBDIR)/$(LIB_NAME)
    LINK_OPTIONS += -shared -Wl,--no-undefined -Wl,-soname,$(LIB_NAME)
endif
ifeq ($(PRJ_TYPE),exe)
    EXE_NAME     := $(PRJ_NAME)
    TARGET       := $(BINDIR)/$(EXE_NAME)
    LINK_OPTIONS += 
endif

ifeq ($(TARGET),)
    $(error PRJ_TYPE must be either lib or exe)
endif

SUBMAKE = $(V)$(MAKE) -s --no-print-directory

####################### c++ #########################

COMPILER  := c++
CPP_STD   ?= -std=c++17

ifeq ($(BUILD_MODE),release)
    CPP_OPTIM := -O2 -DNDEBUG
else
    CPP_OPTIM := -O0
endif

CPP_PLT      := -fno-plt
CPP_INCLUDES += -I$(SRCDIR)
CPP_OPTIONS  += $(CPP_STD) $(CPP_OPTIM) -fPIC $(CPP_PLT) -g $(CPP_INCLUDES) $(CPP_DEFINES) $(CPP_EXTRA_FLAGS)

V=@

####################### rules #########################

all: $(TARGET)


$(TARGET): $(OBJ_FILES) $(TARGET_EXTRA_DEPENDENCY)
	$(V)if test ! -d $(@D); then mkdir -p $(@D); fi
	$(V)echo "  linking $@"
	$(V)$(COMPILER) $(CPP_OPTIM) $(LINK_OPTIONS) $(CPP_PLT) -g -o $@  $(OBJ_FILES)

$(OBJDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(CPPEXT)
	$(V)echo "  compiling $<"
	$(V)if test ! -d $(dir $(DEPDIR)/$*); then mkdir -p $(dir $(DEPDIR)/$*); fi
	$(V)$(COMPILER) $(CPP_OPTIONS) -MT $@ -MM -MP -MF $(DEPDIR)/$*.$(DEPEXT) $<
	$(V)sed "s%$@:%$@ $(DEPDIR)/$*.$(DEPEXT):%g" -i $(DEPDIR)/$*.$(DEPEXT)
	$(V)if test ! -d $(@D)  ; then mkdir -p $(@D); fi
	$(V)$(COMPILER) $(CPP_OPTIONS) -c -o $@  $<

$(DEPDIR)/$(TESTDIR)/Test$*.$(DEPEXT): $(OBJDIR)/$(TESTDIR)/Test%.$(OBJEXT)
	
.SECONDARY:

$(OBJDIR)/$(TESTDIR)/Test%.$(OBJEXT): CPP_INCLUDES += $(TEST_INCLUDES)
$(OBJDIR)/$(TESTDIR)/Test%.$(OBJEXT): CPP_DEFINES  += $(TEST_DEFINES)

	
$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT): TEST_CPP_EXTRA_FILES = $(wildcard $(SRCDIR)/$(TESTDIR)/$**.$(CPPEXT))
$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT): TEST_OBJ_EXTRA_FILES = $(TEST_CPP_EXTRA_FILES:$(SRCDIR)/%.$(CPPEXT)=$(OBJDIR)/%.$(OBJEXT))
$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT): 
$(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT):
	$(V)if test ! -d $(@D); then mkdir -p $(@D); fi
	$(V)echo "  linking $@"
	$(V)$(COMPILER) $(CPP_OPTIM) $(CPP_PLT) -g -o $@  $< $(TEST_OBJ_EXTRA_FILES) -L$(LIBDIR) -l$(PRJ_NAME)-$(PRJ_BRANCH) $(TEST_EXTRA_LINK_LIBS)

$(BINDIR)/$(TESTDIR)/Test%.$(TESTIND): $(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)
	$(V)echo; echo; echo "########################### testing $* ###########################"
	$(V)export LD_LIBRARY_PATH=$(LIBDIR):$(TEST_EXTRA_LD_PATH):$$LD_LIBRARY_PATH; ./$< $(TEST_ARGS_$*)
	$(V)echo; echo; echo "########################### end of test $* ###########################"; echo; echo
	$(V)touch $@

test-%: $(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)
	$(V)export LD_LIBRARY_PATH=$(LIBDIR):$(TEST_EXTRA_LD_PATH):$$LD_LIBRARY_PATH; ./$< $(TEST_ARGS_$*)

gdb-test-%: $(BINDIR)/$(TESTDIR)/Test%.$(TESTEXT)
	$(V)export LD_LIBRARY_PATH=$(LIBDIR):$(TEST_EXTRA_LD_PATH):$$LD_LIBRARY_PATH; gdb ./$<

ifneq ($(TEST_DEP_FILES),)

$(foreach n,$(TEST_NAMES),$(eval $(call testdeps,$(n))))

-include $(TEST_DEP_FILES)

endif

.PHONY: check

check: $(TEST_INDICATORS)

recheck: clean-test-indicators
	$(SUBMAKE) check

clean-test-indicators:
	$(V)rm -f $(TEST_INDICATORS)

clean-tests:
	$(V)rm -rf $(BINDIR)/$(TESTDIR) $(OBJDIR)/$(TESTDIR) $(DEPDIR)/$(TESTDIR)

clean:
	$(V)rm -rf $(BUILDDIR)

-include $(DEP_FILES)

