@echo off
setlocal

:: ---------------------------------------------------------
:: 1. 环境检查与配置 (对应 Linux 的 if source ... bashrc)
:: ---------------------------------------------------------
:: Windows 安装 ADS 后通常会自动设置 HPEESOF_DIR 环境变量。
:: 如果没有设置，请手动取消下行的注释并修改为你的安装路径：
:: set HPEESOF_DIR=C:\Program Files\Keysight\ADS2022

if "%HPEESOF_DIR%"=="" (
    echo Error: HPEESOF_DIR environment variable is not defined.
    echo Please set HPEESOF_DIR to your ADS installation folder.
    goto :EOF
)

:: ---------------------------------------------------------
:: 2. 修改 PATH 环境变量 (对应 Linux 的 export PATH/LD_LIBRARY_PATH)
:: ---------------------------------------------------------
:: Windows 中 DLL 和 Exe 都通过 PATH 查找，所以只需设置 PATH
:: 注意：ADS 在 Windows 下的二进制目录通常是 bin 而不是 bin/linux_x86_64
set SIMARCH=bin
set PATH=%HPEESOF_DIR%\%SIMARCH%;%HPEESOF_DIR%\lib\win32_64;%PATH%

:: ---------------------------------------------------------
:: 3. 启动仿真引擎 (对应 Linux 的 hpeesofsim ... &)
:: ---------------------------------------------------------
:: netlist.log : 网表文件
:: -T32        : 线程数
:: start /B    : 在后台启动应用程序而不打开新窗口 (对应 Linux 的 &)
:: /MIN        : 最小化窗口 (可选)

echo Starting ADS Simulation (hpeesofsim)...

:: 使用 WMIC 启动进程以获取 PID (Windows Batch 获取 PID 的一种方法)
:: 如果不需要 PID 文件，可以直接使用: start /B hpeesofsim.exe netlist.log -T32 > output.log 2>&1

for /f "tokens=2 delims==;" %%I in ('wmic process call create "hpeesofsim.exe netlist.log -T32" ^| find "ProcessId"') do set PID=%%I

:: ---------------------------------------------------------
:: 4. 记录 PID (对应 Linux 的 echo $pid > pidfile)
:: ---------------------------------------------------------
if defined PID (
    echo Simulation started with PID: %PID%
    echo %PID% > pidfile
    echo Output is being redirected to output.log
) else (
    echo Failed to start simulation or retrieve PID.
)

endlocal