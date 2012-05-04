#!/usr/bin/env python
# To run this script, use Python version 2.7 not version 3.x
import argparse
import struct

parser = argparse.ArgumentParser(description='Reads a binary file and creates a VHDL ROM file that can be used for simulation.')
parser.add_argument('ifile', type=argparse.FileType('rb'), help='source ROM binary file')
parser.add_argument('ofile', type=argparse.FileType('wt'), help='destination VHDL file')
args = parser.parse_args()

#seek to end
args.ifile.seek(0,2)
#get size of user binary file
bsize = args.ifile.tell()
#seek to start
args.ifile.seek(0,0)

bits = bsize-1
counter = 0
while bits>1:
	bits>>=1
	counter = counter + 1

fsize_pow2 = (2**(counter+1))
remainder = fsize_pow2 - bsize

assert bsize <= 128*1024, "File too large for practical simulation"
args.ofile.write("library ieee;\n")
args.ofile.write("\tuse ieee.std_logic_1164.all;\n")
args.ofile.write("\tuse ieee.std_logic_arith.all;\n")
args.ofile.write("\tuse ieee.std_logic_unsigned.all;\n")
args.ofile.write("\tuse ieee.numeric_std.all;\n")
args.ofile.write("\n")
args.ofile.write("entity ROM is\n")
args.ofile.write("\tport (\n")
args.ofile.write("\t\tROM_nCS :in  std_logic;\n")
args.ofile.write("\t\tROM_nOE :in  std_logic;\n")
args.ofile.write("\t\tROM_A   :in  std_logic_vector (%d downto 0); -- Address input\n" %counter)
args.ofile.write("\t\tROM_D   :out std_logic_vector ( 7 downto 0)  -- Data output\n")
args.ofile.write("\t);\n")
args.ofile.write("end entity;\n")
args.ofile.write("\n")
args.ofile.write("architecture behavioral of ROM is\n")
args.ofile.write("\ttype mem is array (0 to %d) of std_logic_vector(7 downto 0);\n" %(fsize_pow2-1))
args.ofile.write("\tconstant my_rom : mem := (\n")

counter = 0
args.ofile.write("\t\t")
while counter < bsize-1:
	data = args.ifile.read(1)
	(n,) = struct.unpack(">B", data)
	args.ofile.write("x"'"%02X"'"," %n)
	counter = counter + 1
	if counter%16 == 0:
		args.ofile.write("\n\t\t")

#last entry has no comma
data = args.ifile.read(1)
(n,) = struct.unpack(">B", data)
args.ofile.write("x"'"%02X"'"" %n)
counter = counter + 1

#unless remainder > 0
if remainder>0:
	args.ofile.write(",")

	while counter < bsize+remainder-1:
		if counter%16 == 0:
			args.ofile.write("\n\t\t")
		args.ofile.write("x"'"00"'",")
		counter = counter + 1
	
	#last entry has no comma
	args.ofile.write("x"'"00"'"")

args.ofile.write("\n\t);\n")
args.ofile.write("\n")
args.ofile.write("begin\n")
args.ofile.write("\tprocess (ROM_A)\n")
args.ofile.write("\tbegin\n")
args.ofile.write("\t\tif (ROM_nCS='1') or (ROM_nOE='1') then\n")
args.ofile.write("\t\t\tROM_D <= (others => 'Z');\n")
args.ofile.write("\t\telse\n")
args.ofile.write("\t\t\tROM_D <= my_rom(conv_integer(ROM_A)) after 10 ns;\n")
args.ofile.write("\t\tend if;\n")
args.ofile.write("\tend process;\n")
args.ofile.write("end architecture behavioral;\n")

#close up files and exit
args.ifile.close()
args.ofile.close()
