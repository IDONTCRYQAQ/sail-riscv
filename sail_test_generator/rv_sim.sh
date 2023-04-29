#!/bin/bash

#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [elf_file]"
    exit 1
fi

if [ "$1" == "all" ]; then
    for C_FILE in test_src/*.c; do
        C_FILE=$(basename "$C_FILE")
        ELF_FILE="${C_FILE%.*}.elf"
        echo "Running simulation for $ELF_FILE"
        ./rv_sim.sh "${C_FILE%.*}"
    done
    exit 0
fi

ELF_FILE="$1.elf"

if [ ! -f "test/$ELF_FILE" ]; then
    C_FILE="test_src/${ELF_FILE%.*}.c"
    if [ ! -f "$C_FILE" ]; then
        echo "Neither test/$ELF_FILE nor $C_FILE exists"
        exit 1
    else
        echo "Compiling $C_FILE..."
        make src="${ELF_FILE%.*}"
        if [ ! -f "test/${ELF_FILE%.*}.elf" ]; then
            echo "Failed to compile $C_FILE"
            exit 1
        fi
    fi
fi

# Rest of the script remains the same



ELF_FILE=$1

if [ ! -f "test/$ELF_FILE" ]; then
    C_FILE="test_src/${ELF_FILE%.*}.c"
    if [ ! -f "$C_FILE" ]; then
        echo "Neither test/$ELF_FILE nor $C_FILE exists"
        exit 1
    else
        echo "Compiling $C_FILE..."
        make src="${ELF_FILE%.*}"
        if [ ! -f "test/${ELF_FILE%.*}.elf" ]; then
            echo "Failed to compile $C_FILE"
            exit 1
        fi
    fi
fi

echo "Running simulation with Sail..."

#./riscv_sim_RV64 -p -V "test/$ELF_FILE.elf" > "results/${ELF_FILE%.*}_sail_result" 2> "results/${ELF_FILE%.*}_sail_error"
###
# 保存临时错误输出文件的名称
tmp_error_file="results/tmp_sail_error"

# 运行 RISC-V 仿真器并将错误输出保存到临时文件
./riscv_sim_RV64 -p -V "test/$ELF_FILE.elf" > "results/${ELF_FILE%.*}_sail_result" 2> "$tmp_error_file"

# 提取错误输出的第一部分和第二部分
error_part1=$(awk '/will show execution times/,/tohost located/ {print}' "$tmp_error_file")
error_part2=$(awk '/Initialization:/,/Perf:/ {print}' "$tmp_error_file")

# 将错误输出的第一部分插入到结果文件的开头
printf "%s\n" "$error_part1" | cat - "results/${ELF_FILE%.*}_sail_result" > "results/temp_sail_result" && mv "results/temp_sail_result" "results/${ELF_FILE%.*}_sail_result"

# 将错误输出的第二部分追加到结果文件的末尾
printf "%s\n" "$error_part2" >> "results/${ELF_FILE%.*}_sail_result"

# 删除临时错误输出文件
rm "$tmp_error_file"
###

echo "----------------------------------------"

echo "Running simulation with Spike..."

spike --ic=256:2:64 --dc=128:4:64 "test/$ELF_FILE.elf" > "results/${ELF_FILE%.*}_spike_result"

echo "Simulation complete!"
