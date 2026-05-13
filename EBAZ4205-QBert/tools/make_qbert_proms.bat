copy /b qb-bg0.bin + qb-bg1.bin BG_ROM.bin
make_vhdl_prom BG_ROM.bin BG_ROM.vhd

copy /b qb-fg0.bin + qb-fg0.bin FG_ROM_0.bin
make_vhdl_prom FG_ROM_0.bin FG_ROM_0.vhd

copy /b qb-fg1.bin + qb-fg1.bin FG_ROM_1.bin
make_vhdl_prom FG_ROM_1.bin FG_ROM_1.vhd

copy /b qb-fg2.bin + qb-fg2.bin FG_ROM_2.bin
make_vhdl_prom FG_ROM_2.bin FG_ROM_2.vhd

copy /b qb-fg3.bin + qb-fg3.bin FG_ROM_3.bin
make_vhdl_prom FG_ROM_3.bin FG_ROM_3.vhd

make_vhdl_prom qb-rom0.bin PRG_ROM_0.vhd
make_vhdl_prom qb-rom1.bin PRG_ROM_1.vhd
make_vhdl_prom qb-rom2.bin PRG_ROM_2.vhd

make_vhdl_prom qb-snd1.bin SND_ROM_1.vhd
make_vhdl_prom qb-snd2.bin SND_ROM_2.vhd

pause
