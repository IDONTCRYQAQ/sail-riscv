CFLAGS := -Os -march=rv64imac -mabi=lp64 -mcmodel=medany -ffunction-sections -fdata-sections -Ienv -Ilib/include
LDFLAGS := -nostartfiles -nostdlib -nostdinc -static -lgcc
CROSS_COMPILE ?= riscv64-unknown-elf-
AR = $(CROSS_COMPILE)ar
CC = $(CROSS_COMPILE)gcc

src_dir ?= test_src
test_dir ?= test
build_dir ?= build

src_files := $(wildcard $(src_dir)/*.c)
elf_files := $(patsubst $(src_dir)/%.c,$(test_dir)/%.elf,$(src_files))

ifeq ($(src),)
all: $(elf_files)
else
all: $(test_dir)/$(src).elf
endif

$(test_dir)/%.elf: $(build_dir)/%.o $(build_dir)/lib/crt.o $(build_dir)/lib/setup.o $(build_dir)/lib/lib.a | $(test_dir)
	$(CC) $(CFLAGS) $(LDFLAGS) -Tenv/default.lds $^ -o $@

$(build_dir)/%.o: $(src_dir)/%.c | $(build_dir)
	$(CC) $(CFLAGS) -c $< -o $@

$(build_dir)/lib/crt.o: env/crt.s | $(build_dir)/lib
	$(CC) $(CFLAGS) -c $< -o $@

$(build_dir)/lib/setup.o: env/setup.c | $(build_dir)/lib
	$(CC) $(CFLAGS) -c $< -o $@

###

lib_dirs = lib/std lib/drivers lib/arch
lib_src = $(sort $(foreach d,$(lib_dirs),$(wildcard $(d)/*.c)))
lib_asm = $(sort $(foreach d,$(lib_dirs),$(wildcard $(d)/*.s)))
lib_objs = $(patsubst %.s,%.o,$(lib_asm)) \
                     $(patsubst %.c,%.o,$(lib_src))

$(build_dir)/obj/%.o: %.c | $(build_dir)/obj
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

$(build_dir)/obj/%.o: %.s | $(build_dir)/obj
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

$(build_dir)/lib/lib.a: $(addprefix $(build_dir)/obj/,$(lib_objs)) | $(build_dir)/lib
	@$(AR) cr $@ $^

###
$(build_dir)/lib:
	mkdir -p $@

$(build_dir)/obj:
	mkdir -p $@

$(build_dir):
	mkdir -p $@

$(test_dir):
	mkdir -p $@

clean:
	rm -rf $(test_dir)

.PHONY: all clean $(test_dir)
