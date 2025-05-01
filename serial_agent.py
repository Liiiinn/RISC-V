import serial
import time

def read_hex_file(file_path):
    """读取文件并解析十六进制字符串为字节数据"""
    with open(file_path, 'r') as f:
        content = f.read()
    # 替换常见分隔符为空格，然后分割
    hex_str = content.replace('\n', ' ').replace('\r', ' ').replace('\t', ' ')
    hex_list = hex_str.strip().split()
    try:
        byte_data = [int(h, 16) for h in hex_list]
    except ValueError:
        raise ValueError("文件中包含非合法的十六进制字符串")
    return byte_data

def send_uart_data(port, baudrate, data, byte_interval=0):
    """通过UART逐字节发送数据，可设置字节间隔"""
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
    file_path = "D:\ETIN35-ICp1\Phase2\data.txt"       # 文件路径
    serial_port = "COM8"         # 串口号（根据实际修改）
    baudrate = 115200              # 波特率
    byte_interval = 0.1          # 每个字节之间的延时（单位：秒）

    try:
        data = read_hex_file(file_path)
        send_uart_data(serial_port, baudrate, data, byte_interval)
    except Exception as e:
        print(f"错误：{e}")