import serial
import time
import os

def read_and_rearrange(file_path):
    """读取文件并解析十六进制字符串为字节数据"""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    byte_data = []
    for line in lines:
        hex_list = line.strip().split()
        try:
            byte_line = [int(h, 16) for h in hex_list]
            if len(byte_line) not in [2, 4]:
                raise ValueError(f"行长度不为2或4个字节: {line.strip()}")
            byte_data.append(byte_line)
        except ValueError:
            raise ValueError(f"文件中包含非合法十六进制或格式错误：{line.strip()}")
        
    byte_data.append([0x11, 0x11])
    
    
    """
    将数据重排为每行4字节
    """
    result = []
    temp = [0x00, 0x00, 0x00, 0x00]
    temp_next = [0x00, 0x00, 0x00, 0x00]
    fill_counter = 1

    for index, line in enumerate(byte_data):
        if len(line) == 2:
            if fill_counter == 1:
                temp[2] = line[0]
                temp[3] = line[1]
                fill_counter = 0
                if index == len(byte_data) - 1:
                    temp[0] = 0x00
                    temp[1] = 0x00
                    result.append(temp.copy())
            elif fill_counter == 0:
                temp[0] = line[0]
                temp[1] = line[1]
                fill_counter = 1
                result.append(temp.copy())
        elif len(line) == 4:
            if fill_counter == 1:
                temp = line
                result.append(temp.copy())
            elif fill_counter == 0:
                temp[0] = line[2]
                temp[1] = line[3]
                temp_next[2] = line[0]
                temp_next[3] = line[1]
                result.append(temp.copy())
                temp = temp_next
                temp_next = [0x00, 0x00, 0x00, 0x00]
                if index == len(byte_data) - 1:
                    result.append(temp.copy())

    return result

def write_rearranged_file(file_path, rearranged_data):
    """写入重新排列的数据，每行4个字节"""
    with open(file_path, 'w') as f:
        for row in rearranged_data:
            hex_str = ' '.join(f"{b:02X}" for b in row)
            f.write(hex_str + '\n')

def send_uart_data(port, baudrate, data, byte_interval=0):
    """通过串口逐字节发送数据"""
    try:
        with serial.Serial(port, baudrate=baudrate, bytesize=serial.EIGHTBITS,
                           parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,
                           timeout=1) as ser:
            for i, byte in enumerate(data):
                ser.write(bytes([byte]))
                print(f"已发送字节 {i+1}/{len(data)}: 0x{byte:02X}")
                time.sleep(byte_interval)
            print(f"全部数据发送完毕，总共 {len(data)} 字节。")
    except serial.SerialException as e:
        print(f"串口通信错误：{e}")

if __name__ == "__main__":
    file_path = "D:\ETIN35-ICp1\Phase2\data.txt"
    serial_port = "COM10"
    baudrate = 115200
    byte_interval = 0.1

    try:
        data = read_and_rearrange(file_path)

        rearranged_file_path = os.path.join(os.path.dirname(file_path), "data_rearranged.txt")
        write_rearranged_file(rearranged_file_path, data)
        print(f"数据已重新排列并写入: {rearranged_file_path}")

        #flat_data = [b for row in data for b in row]
        #send_uart_data(serial_port, baudrate, flat_data, byte_interval)

    except Exception as e:
        print(f"错误：{e}")
