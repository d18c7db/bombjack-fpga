--	(c) 2012 d18c7db(a)hotmail
--
--	This program is free software; you can redistribute it and/or modify it under
--	the terms of the GNU General Public License version 3 or, at your option,
--	any later version as published by the Free Software Foundation.
--
--	This program is distributed in the hope that it will be useful,
--	but WITHOUT ANY WARRANTY; without even the implied warranty of
--	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- For full details, see the GNU General Public License at www.gnu.org/licenses

--------------------------------------------------------------------------------
-- Video scan converter
--
--	Horizonal Timing
-- _____________              ______________________              _____________________
-- VIDEO (last) |____________|         VIDEO        |____________|         VIDEO (next)
-- -hD----------|-hA-|hB|-hC-|----------hD----------|-hA-|hB|-hC-|----------hD---------
-- __________________|  |________________________________|  |__________________________
-- HSYNC             |__|              HSYNC             |__|              HSYNC

-- Vertical Timing
-- _____________              ______________________              _____________________
-- VIDEO (last)||____________||||||||||VIDEO|||||||||____________||||||||||VIDEO (next)
-- -vD----------|-vA-|vB|-vC-|----------vD----------|-vA-|vB|-vC-|----------vD---------
-- __________________|  |________________________________|  |__________________________
-- VSYNC             |__|              VSYNC             |__|              VSYNC

-- Scan converter input and output timings compared to standard VGA
--	Resolution   - Frame   | Pixel      | Front     | HSYNC      | Back       | Active      | HSYNC    | Front    | VSYNC    | Back     | Active    | VSYNC
--              - Rate    | Clock      | Porch hA  | Pulse hB   | Porch hC   | Video hD    | Polarity | Porch vA | Pulse vB | Porch vC | Video vD  | Polarity
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--  In  256x224 - 59.18Hz |  6.000 MHz | 38 pixels |  32 pixels |  58 pixels |  256 pixels | negative | 16 lines | 8 lines  | 16 lines | 224 lines | negative
--  Out 640x480 - 59.18Hz | 24.000 MHz |  2 pixels |  92 pixels |  34 pixels |  640 pixels | negative | 17 lines | 2 lines  | 29 lines | 480 lines | negative
--  VGA 640x480 - 60.00Hz | 25.175 MHz | 16 pixels |  96 pixels |  48 pixels |  640 pixels | negative | 11 lines | 2 lines  | 31 lines | 480 lines | negative

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

--pragma translate_off
	use ieee.std_logic_textio.all;
	use std.textio.all;
--pragma translate_on

library UNISIM;
	use UNISIM.Vcomponents.all;

entity VGA_SCANCONV is
	port (
		I_VIDEO				: in  std_logic_vector(15 downto 0);
		I_HSYNC				: in  std_logic;
		I_VSYNC				: in  std_logic;
		I_CMPBLK_N			: in  std_logic;
		--
		O_VIDEO				: out std_logic_vector(15 downto 0);
		O_HSYNC				: out std_logic;
		O_VSYNC				: out std_logic;
		O_CMPBLK_N			: out std_logic;
		--
		CLK					: in  std_logic;
		CLK_X4				: in  std_logic
	);
end;

architecture RTL of VGA_SCANCONV is
	--
	-- input timing
	--
	signal ihsync_last	: std_logic := '0';
	signal ivsync_last	: std_logic := '0';
	signal out_cmpblk_n	: std_logic := '1';
	signal out_cmpblk1_n	: std_logic := '1';
	signal hpos_i			: std_logic_vector( 8 downto 0) := (others => '0');

	--
	-- output timing
	--
	signal ovsync_last	: std_logic := '0';
	signal in_cmpblk_n	: std_logic := '1';
	signal hpos_o			: std_logic_vector( 9 downto 0) := (others => '0');

	signal vcnt				: integer range 0 to 1023 := 0;
	signal hcnt				: integer range 0 to 1023 := 0;

	signal bank				: std_logic := '0';
	signal bank_n			: std_logic := '1';

	constant hB				: integer range 0 to 1023 :=  92;	-- h sync
	constant hC				: integer range 0 to 1023 :=  96;	-- h back porch
	constant hres			: integer range 0 to 1023 := 512;	-- visible video
	constant hpad			: integer range 0 to 1023 :=  64;	-- padding either side to reach standard VGA resolution (hres + hpad = hD)

	constant vB				: integer range 0 to 1023 :=   2;	-- v sync
	constant vC				: integer range 0 to 1023 :=  48;	-- v back porch
	constant vres			: integer range 0 to 1023 := 448;	-- visible video
	constant vpad			: integer range 0 to 1023 :=  16;	-- padding either side to reach standard VGA resolution (vres + vpad = vD)

--pragma translate_off
	signal qidx				: std_logic_vector( 7 downto 0) := (others => '0');
	file qfile				: TEXT open write_mode is "..\screens\qvga0.ppm";
--pragma translate_on
begin
-- debug: write .ppm format video frames to output files
-- pragma translate_off
	p_debug : process(CLK)
		variable rising_h		: boolean;
		variable rising_v		: boolean;
		variable armed			: boolean;
		variable s				: line; -- debug
	begin
		if rising_edge (CLK) then
			rising_h  := (I_HSYNC = '1') and (ihsync_last = '0');
			rising_v  := (I_VSYNC = '1') and (ivsync_last = '0');
			ihsync_last <= I_HSYNC;
			ivsync_last <= I_VSYNC;

			if rising_v then					-- at start of frame
				armed := true;
			end if;

			if rising_h and armed then		-- at start of frame
				armed := false;
				qidx <= qidx + 1;				-- frame number
				file_close(qfile);
				write(s,"..\screens\qvga"); write(s,conv_integer(qidx)); write(s,".ppm");
				file_open(qfile,s.all, WRITE_MODE);
				writeline(output,s);
				--	# The P3 means colors are in ASCII, then 352 columns and 256 rows, then 15 for max color, then RGB triplets
				write(s,"P3");						writeline(qfile,s);	--	P3
				write(s,"# "); write(s, now);	writeline(qfile,s);	-- sim time
				write(s,"352 256");				writeline(qfile,s);	--	352 256
				write(s,"15");						writeline(qfile,s);	--	15
			end if;

			if (I_HSYNC = '1' and I_VSYNC = '1') then
				write(s, conv_integer(I_VIDEO(11 downto 8)) ); write(s," ");	-- R
				write(s, conv_integer(I_VIDEO( 7 downto 4)) ); write(s," ");	-- G
				write(s, conv_integer(I_VIDEO( 3 downto 0)) );						-- B
				writeline(qfile,s);
			end if;
		end if;
	end process;
-- pragma translate_on

	bank_n <= not bank;

	u_ram : RAMB16_S18_S18
		generic map (INIT_A => X"00000", INIT_B => X"00000", SIM_COLLISION_CHECK => "NONE")  -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL"
		port map (
			-- input
			DOA					=> open,
			DIA					=> I_VIDEO,
			DOPA					=> open,
			DIPA					=> "00",
			ADDRA(9)				=> bank,
			ADDRA(8 downto 0)	=> hpos_i,
			WEA					=> '1',
			ENA					=> '1',
			SSRA					=> '0',
			CLKA					=> CLK,

			-- output
			DOB					=> O_VIDEO,
			DIB					=> x"0000",
			DOPB					=> open,
			DIPB					=> "00",
			ADDRB(9)				=> bank_n,
			ADDRB(8 downto 0)	=> hpos_o(9 downto 1),
			WEB					=> '0',
			ENB					=> '1',
			SSRB					=> '0',
			CLKB					=> CLK_X4
		);

	-- alternate RAM banks every new horizontal line
	p_bank : process(I_HSYNC)
	begin
		if falling_edge(I_HSYNC) then
			bank <= not bank;
		end if;
	end process;

	-- increment write position during active video
	p_ram_in : process(CLK)
	begin
		if rising_edge (CLK) then
			-- delay input cmpblk to match input video
			in_cmpblk_n <= I_CMPBLK_N; -- 1 clock delay

			if in_cmpblk_n = '0' then
				hpos_i <= (others => '0');
			else
				hpos_i <= hpos_i + 1;
			end if;
		end if;
	end process;

	-- VGA H and V counters, synchronized to input frame V sync
	p_out_ctrs : process(CLK_X4)
	begin
		if rising_edge (CLK_X4) then
			ovsync_last <= I_VSYNC;

			if (I_VSYNC = '0') and (ovsync_last = '1') then
				hcnt <= 0;
				vcnt <= 0;
			else
				hcnt <= hcnt + 1;
				if hcnt = 767 then
					hcnt <= 0;
					vcnt <= vcnt + 1;
				end if;
			end if;
		end if;
	end process;

	-- generate hsync
	p_gen_hsync : process(CLK_X4)
	begin
		if rising_edge (CLK_X4) then
			-- H sync timing
			if (hcnt < hB) then
--			if (hcnt < 96) then
				O_HSYNC <= '0';
			else
				O_HSYNC <= '1';
			end if;
		end if;
	end process;

	-- generate vsync
	p_gen_vsync : process(CLK_X4)
	begin
		if rising_edge (CLK_X4) then
			-- V sync timing
			if (vcnt < vB) then
--			if (vcnt < 2) then
				O_VSYNC <= '0';
			else
				O_VSYNC <= '1';
			end if;
		end if;
	end process;

	-- generate active output video
	p_gen_active_vid : process(CLK_X4)
	begin
		if rising_edge (CLK_X4) then
			-- visible video area 512x448 (doubled from the original game's 256x224)
			if ((vcnt >= (vB + vC)) and (vcnt < (vB + vC + vres))) and ((hcnt >= (hB + hC)) and (hcnt < (hB + hC + hres))) then
--			if ((vcnt >= ( 2 + 48)) and (vcnt < ( 2 + 48 +  448))) and ((hcnt >= (96 + 96)) and (hcnt < (96 + 96 +  512))) then
				hpos_o <= hpos_o + 1;
			else
				hpos_o <= (others => '0');
			end if;
		end if;
	end process;

	-- generate blanking signal including additional borders to pad the input signal to standard VGA resolution
	p_gen_blank : process(CLK_X4)
	begin
		if rising_edge (CLK_X4) then
			-- active video area 640x480 (VGA) after padding with blank borders
			if ((vcnt >= (vB + vC - vpad)) and (vcnt < (vB + vC + vres + vpad))) and ((hcnt >= (hB + hC - hpad)) and (hcnt < (hB + hC + hres + hpad))) then
--			if ((vcnt >= ( 2 + 48 -   16)) and (vcnt < ( 2 + 48 + 448  +   16))) and ((hcnt >= (96 + 96 -   64)) and (hcnt < (96 + 96 +  512 +   64))) then
				out_cmpblk_n <= '1';
			else
				out_cmpblk_n <= '0';
			end if;

			-- delay output cmpblk to match output video
			out_cmpblk1_n <= out_cmpblk_n;	-- 1 clock delay
			O_CMPBLK_N    <= out_cmpblk1_n;	-- 2 clock delay
		end if;
	end process;

end architecture RTL;
