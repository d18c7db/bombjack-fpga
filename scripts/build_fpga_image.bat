@echo off
set ROMS=..\roms\bombjack
copy/b %ROMS%\01_h03t.bin + %ROMS%\02_p04t.bin + %ROMS%\02_p04t.bin + %ROMS%\03_e08t.bin + %ROMS%\03_e08t.bin + %ROMS%\04_h08t.bin + %ROMS%\04_h08t.bin + %ROMS%\05_k08t.bin + %ROMS%\05_k08t.bin + %ROMS%\06_l08t.bin + %ROMS%\07_n08t.bin + %ROMS%\08_r08t.bin + %ROMS%\09_j01b.bin + %ROMS%\10_l01b.bin + %ROMS%\11_m01b.bin + %ROMS%\12_n01b.bin + %ROMS%\13.1r + %ROMS%\14_j07b.bin + %ROMS%\15_l07b.bin + %ROMS%\16_m07b.bin roms.bin >NUL
bitmerge.py ..\build\bomb_jack_top.bit roms.bin fpga.bit
del roms.bin
echo done
pause
