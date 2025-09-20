@echo off
echo Compiling fixed-point comparator testbench...

:: Check if iverilog is available
where iverilog >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Icarus Verilog (iverilog) not found in PATH
    echo Please install Icarus Verilog: http://bleyer.org/icarus/
    pause
    exit /b 1
)

:: Compile the testbench
echo Compiling Verilog files...
iverilog -o tb_comparator.exe tb_fixed_point_comparator.v fixed_point_comparator.v

if %errorlevel% neq 0 (
    echo Compilation failed!
    pause
    exit /b 1
)

echo Compilation successful!
echo Running simulation...

:: Run the simulation
vvp tb_comparator.exe

echo.
echo Simulation complete!
echo Check tb_fixed_point_comparator.vcd for waveform analysis

pause