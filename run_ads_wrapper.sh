# 检查是否存在 ADS 2022 的环境配置文件 (-f 表示判断文件是否存在)
if [ -f "/eda/agilent/agi_cfg/bashrc.agi_2022" ]; then
    # 如果存在，加载该配置 (source 命令会执行文件中的设置，如 HPEESOF_DIR 变量)
    source /eda/agilent/agi_cfg/bashrc.agi_2022
# 如果 2022 不存在，检查是否存在 ADS 2021 的配置文件
elif [ -f "/eda/agilent/agi_cfg/bashrc.agi_2021" ]; then
    # 如果存在，加载该配置
    source /eda/agilent/agi_cfg/bashrc.agi_2021
else
    # 如果两个版本的配置文件都找不到，打印错误提示
    echo "can not find ADS install folder"
fi

# 定义系统架构变量，指定为 64位 Linux
export SIMARCH=linux_x86_64

# 修改 PATH 环境变量：
# 将 ADS 的各种可执行文件目录 (bin) 和库目录添加到 PATH 的【最前面】
# 这样系统在运行 hpeesofsim 时会优先使用 ADS 自带的工具，而不是系统默认的
export PATH=$HPEESOF_DIR/lib/$SIMARCH:$HPEESOF_DIR/bin:$HPEESOF_DIR/circuit/lib.$SIMARCH:$HPEESOF_DIR/circuit/$SIMARCH:$HPEESOF_DIR/adsptolemy/lib/circuit/$SIMARCH:$HPEESOF_DIR/adsptolemy/lib/circuit/lib.$SIMARCH:$HPEESOF_DIR/tiburonda/tools/$SIMARCH:$PATH

# 修改 LD_LIBRARY_PATH 环境变量：
# 将 ADS 的动态链接库目录添加到最前面
# 这是解决 "libptgem.so not found" 或 MATLAB 库冲突的关键步骤！
export LD_LIBRARY_PATH=$HPEESOF_DIR/adsptolemy/lib.linux_x86_64:$LD_LIBRARY_PATH

# 启动 ADS 核心仿真引擎 hpeesofsim
# netlist.log : 读取当前目录中的网表文件
# -T32           : 启用 32 线程并行仿真 (加速)
# > output.log   : 将标准输出 (日志) 重定向写入到当前目录的 output.log 文件
# 2>&1           : 将标准错误输出也重定向到标准输出 (即错误信息也写进 output.log)
# &              : 让命令在后台运行，不会卡住当前终端
hpeesofsim netlist.log -T32 > output.log 2>&1 &

# 获取上一个后台命令 (即 hpeesofsim) 的进程 ID (PID)
pid=$!

# 将该进程从 Shell 的作业控制中脱离
# 这样即使你关闭了当前的终端窗口，仿真进程也不会被杀掉，会继续运行
disown $pid

# 将进程 ID 写入到一个名为 pidfile 的文件中
# 方便后续如果需要强制停止仿真，可以读取这个文件知道要 kill 哪个进程
echo $pid > pidfile