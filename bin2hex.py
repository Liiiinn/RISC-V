input_file = "d:/UNI2/ICP1/RISC-V/SystemVerilog/Simulation/data.txt"
output_file = "d:/UNI2/ICP1/RISC-V/SystemVerilog/Simulation/data_hex.txt"

with open(input_file, "r") as fin, open(output_file, "w") as fout:
    for line in fin:
        line = line.strip()
        # 跳过空行和注释
        if not line or line.startswith("//"):
            continue
        # 判断是二进制
        if all(c in "01" for c in line) and len(line) == 32:
            hex_str = hex(int(line, 2))[2:].zfill(8)
            # 每2位加空格并大写
            formatted = " ".join([hex_str[i:i+2].upper() for i in range(0, 8, 2)])
            fout.write(formatted + "\n")
            print(formatted)