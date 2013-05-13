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
--	Top level for Bomb Jack game targeted for Pipistrello board, basic h/w specs:
--		Spartan 6 LX45
--		50Mhz xtal oscillator
--		32Mx16 LPDDR DRAM (not used)
--		128Mbit serial Flash
--

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

library unisim;
	use unisim.vcomponents.all;

entity PIPISTRELLO_TOP is
	port(
		I_RESET		: in		std_logic;								-- active high reset

		-- VGA monitor output
--		O_VIDEO_R	: out   std_logic_vector(3 downto 0);
--		O_VIDEO_G	: out   std_logic_vector(3 downto 0);
--		O_VIDEO_B	: out   std_logic_vector(3 downto 0);
--		O_HSYNC		: out   std_logic;
--		O_VSYNC		: out   std_logic;

		-- HDMI monitor output
		TMDS_P		: out   std_logic_vector(3 downto 0);
		TMDS_N		: out   std_logic_vector(3 downto 0);

		-- Sound out
		O_AUDIO_L	: out   std_logic;
		O_AUDIO_R	: out   std_logic;

		-- Active high external buttons
		PS2CLK1		: inout std_logic;
		PS2DAT1		: inout std_logic;

		-- 50MHz clock
		CLK_IN		: in    std_logic := '0'						-- System clock 50Mhz

	);
end PIPISTRELLO_TOP;

architecture RTL of PIPISTRELLO_TOP is
	-- video
	signal VideoR				: std_logic_vector(3 downto 0);
	signal VideoG				: std_logic_vector(3 downto 0);
	signal VideoB				: std_logic_vector(3 downto 0);
	signal HSync				: std_logic := '1';
	signal VSync				: std_logic := '1';

-- Bomb Jack signals
	signal ext_reset			: std_logic := '0';
	signal clk_4M_en			: std_logic := '0';
	signal clk_6M_en			: std_logic := '0';
	signal clk_12M				: std_logic := '0';
	signal clk_24M				: std_logic := '0';
	signal clk_48M				: std_logic := '0';

	signal s_red				: std_logic_vector( 3 downto 0) := (others => '0');
	signal s_grn				: std_logic_vector( 3 downto 0) := (others => '0');
	signal s_blu				: std_logic_vector( 3 downto 0) := (others => '0');
	signal dummy				: std_logic_vector( 3 downto 0) := (others => '0');

	signal i_rom_4P_data		: std_logic_vector( 7 downto 0) := (others => '0');
	signal o_rom_4P_addr		: std_logic_vector(12 downto 0) := (others => '0');
	signal o_rom_4P_ena		: std_logic := '1';

	signal i_rom_7JLM_data	: std_logic_vector(23 downto 0) := (others => '0');
	signal o_rom_7JLM_addr	: std_logic_vector(12 downto 0) := (others => '0');
	signal o_rom_7JLM_ena	: std_logic := '1';

	signal i_rom_8KHE_data	: std_logic_vector(23 downto 0) := (others => '0');
	signal o_rom_8KHE_addr	: std_logic_vector(12 downto 0) := (others => '0');
	signal o_rom_8KHE_ena	: std_logic := '1';

	signal i_rom_8RNL_data	: std_logic_vector(23 downto 0) := (others => '0');
	signal o_rom_8RNL_addr	: std_logic_vector(12 downto 0) := (others => '0');
	signal o_rom_8RNL_ena	: std_logic := '1';

	signal s_audio				: std_logic_vector( 7 downto 0) := (others => '0');

	signal s_cmpblk_n			: std_logic := '1';
	signal s_cmpblk_x4_n		: std_logic := '1';
	signal s_dac_out			: std_logic := '1';
	signal s_hsync_n			: std_logic := '1';
	signal s_vsync_n			: std_logic := '1';
	signal ps2_codeready		: std_logic := '1';
	signal ps2_scancode		: std_logic_vector( 9 downto 0) := (others => '0');

   signal red_s				: std_logic := '0';
   signal grn_s				: std_logic := '0';
   signal blu_s				: std_logic := '0';

   signal clk_dvi_p			: std_logic := '0';
   signal clk_dvi_n			: std_logic := '0';
   signal clk_s				: std_logic := '0';
   signal s_blank				: std_logic := '0';

	-- buttons
	signal
		p1_start, p1_coin, p1_jump, p1_down, p1_up, p1_left, p1_right,
		p2_start, p2_coin, p2_jump, p2_down, p2_up, p2_left, p2_right : std_logic := '0';
begin
	-----------------------------------------------
	-- DCM generates all the system clocks required
	-----------------------------------------------
	clockgen : entity work.CLOCKGEN
	generic map (
		C_CLKFX_DIVIDE   => 25,
		C_CLKFX_MULTIPLY => 24,
		C_CLKIN_PERIOD   => 20.0
	)
	port map(
		I_CLK			=> CLK_IN,
		I_RST			=> ext_reset,
		O_CLK_4M		=> clk_4M_en,
		O_CLK_6M		=> clk_6M_en,
		O_CLK_12M	=> clk_12M,
		O_CLK_24M	=> clk_24M,
--		O_CLK_32M	=> open,
		O_CLK_48M	=> clk_48M
	);

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- USER portion begins here
------------------------------------------------------------------------------
----------------------------------------------------------------------------
	O_AUDIO_L	<= s_dac_out;
	O_AUDIO_R	<= s_dac_out;

	-- uncomment for VGA output
--	O_VIDEO_R	<= VideoR;
--	O_VIDEO_G	<= VideoG;
--	O_VIDEO_B	<= VideoB;
--	O_HSYNC		<= HSync;
--	O_VSYNC		<= VSync;

	ext_reset	<= I_RESET;				-- active high reset

	-----------------------------------------------------------------------------
	-- Keyboard - active low buttons
	-----------------------------------------------------------------------------
	kbd_inst : entity work.Keyboard
	port map (
		Reset     => ext_reset,
		Clock     => clk_12M,
		PS2Clock  => PS2CLK1,
		PS2Data   => PS2DAT1,
		CodeReady => ps2_codeready,  --: out STD_LOGIC;
		ScanCode  => ps2_scancode    --: out STD_LOGIC_VECTOR(9 downto 0)
	);

-- ScanCode(9)          : 1 = Extended  0 = Regular
-- ScanCode(8)          : 1 = Break     0 = Make
-- ScanCode(7 downto 0) : Key Code
	process(clk_12M)
	begin
		if rising_edge(clk_12M) then
			if ext_reset = '1' then
				p1_start <= '0';
				p1_coin  <= '0';
				p1_jump  <= '0';
				p1_down  <= '0';
				p1_up    <= '0';
				p1_left  <= '0';
				p1_right <= '0';
				p2_start <= '0';
				p2_coin  <= '0';
				p2_jump  <= '0';
				p2_down  <= '0';
				p2_up    <= '0';
				p2_left  <= '0';
				p2_right <= '0';
			elsif (ps2_codeready = '1') then
				case (ps2_scancode(7 downto 0)) is
					when x"05" =>	p1_coin  <= not ps2_scancode(8);     -- P1 coin "F1"
					when x"04" =>	p2_coin  <= not ps2_scancode(8);     -- P2 coin "F3"

					when x"06" =>	p1_start <= not ps2_scancode(8);     -- P1 start "F2"
					when x"0c" =>	p2_start <= not ps2_scancode(8);     -- P2 start "F4"

					when x"43" =>	p1_jump  <= not ps2_scancode(8);     -- P1 jump "I"
										p2_jump  <= not ps2_scancode(8);     -- P2 jump "I"

					when x"75" =>	p1_up    <= not ps2_scancode(8);     -- P1 up arrow
										p2_up  	<= not ps2_scancode(8);     -- P2 up arrow

					when x"72" =>	p1_down  <= not ps2_scancode(8);     -- P1 down arrow
										p2_down  <= not ps2_scancode(8);     -- P2 down arrow

					when x"6b" =>	p1_left  <= not ps2_scancode(8);     -- P1 left arrow
										p2_left  <= not ps2_scancode(8);     -- P2 left arrow

					when x"74" =>	p1_right <= not ps2_scancode(8);     -- P1 right arrow
										p2_right <= not ps2_scancode(8);     -- P2 right arrow

					when others => null;
				end case;
			end if;
		end if;
	end process;

	bombjack_inst : entity work.BOMB_JACK
	port map(
		-- player 1 controls
		I_P1(7 downto 5)	=> "000",					-- P1 unused
		I_P1(4)				=> p1_jump, 				-- P1 jump
		I_P1(3)				=> p1_down, 				-- P1 down
		I_P1(2)				=> p1_up, 					-- P1 up
		I_P1(1)				=> p1_left, 				-- P1 left
		I_P1(0)				=> p1_right, 				-- P1 right

		-- player 2 controls
		I_P2(7 downto 5)	=> "000",					-- P2 unused
		I_P2(4)				=> p2_jump,					-- P2 jump
		I_P2(3)				=> p2_down,					-- P2 down
		I_P2(2)				=> p2_up,					-- P2 up
		I_P2(1)				=> p2_left,					-- P2 left
		I_P2(0)				=> p2_right,				-- P2 right

		-- system inputs
		I_SYS(7 downto 4)	=> "1111",					-- unused
		I_SYS(3)				=> p2_start,				-- P2 start
		I_SYS(2)				=> p1_start,				-- P1 start
		I_SYS(1)				=> p2_coin,					-- P2 coin
		I_SYS(0)				=> p1_coin,					-- P1 coin

		-- SW1 presets
		I_SW1(7)				=> '1',						-- demo sounds 1=on, 0=off
		I_SW1(6)				=> '0',						-- orientation 1=upright, 0=cocktail
		I_SW1(5 downto 4)	=> "00",						-- lives 00=3, 01=4, 10=5, 11=2
		I_SW1(3 downto 2)	=> "00",						-- coin b 00=1Coin/1Credit, 01=2Coins/1Credit, 10=1Coin/2Credits, 11=1Coin/3Credits
		I_SW1(1 downto 0)	=> "00",						-- coin a 00=1Coin/1Credit, 01=1Coin/2Credits, 10=1Coin/3Credits, 11=1Coin/6Credits
                           
		-- SW2 presets       
		I_SW2(7)				=> '0',						-- special coin 0=easy, 1=hard
		I_SW2(6 downto 5)	=> "00",						-- enemies number and speed 00=easy, 01=medium, 10=hard, 11=insane
		I_SW2(4 downto 3)	=> "00",						-- bird speed 00=easy, 01=medium, 10=hard, 11=insane
		I_SW2(2 downto 0)	=> "000",					-- bonus life 000=none, 001=every 100k, 010=every 30k, 011=50k only, 100=100k only, 101=50k and 100k, 110=100k and 300k, 111=50k and 100k and 300k

		-- Audio out
		O_AUDIO				=> s_audio,

		-- VGA monitor output
		O_VIDEO_R			=> s_red,
		O_VIDEO_G			=> s_grn,
		O_VIDEO_B			=> s_blu,
		O_HSYNC				=> s_hsync_n,
		O_VSYNC				=> s_vsync_n,
		O_CMPBLK_n			=> s_cmpblk_n,

		-- external ROMs
		I_ROM_4P_DATA		=> i_rom_4P_data,
		O_ROM_4P_ADDR		=> o_rom_4P_addr,
		O_ROM_4P_ENA		=> o_rom_4P_ena,
                           
		I_ROM_7JLM_DATA	=> i_rom_7JLM_data,
		O_ROM_7JLM_ADDR	=> o_rom_7JLM_addr,
		O_ROM_7JLM_ENA		=> o_rom_7JLM_ena,
                           
		I_ROM_8KHE_DATA	=> i_rom_8KHE_data,
		O_ROM_8KHE_ADDR	=> o_rom_8KHE_addr,
		O_ROM_8KHE_ENA		=> o_rom_8KHE_ena,
                           
		I_ROM_8RNL_DATA	=> i_rom_8RNL_data,
		O_ROM_8RNL_ADDR	=> o_rom_8RNL_addr,
		O_ROM_8RNL_ENA		=> o_rom_8RNL_ena,

		-- Active high reset
		I_RESET				=> ext_reset,

		-- Clocks
		I_CLK_4M				=> clk_4M_en,
		I_CLK_6M				=> clk_6M_en,
		I_CLK_12M			=> clk_12M
	);

	-----------------------------------------------------------------
	-- video scan converter required to display video on VGA hardware
	-----------------------------------------------------------------
	-- game native resolution 224x256
	-- take note: the values below are relative to the CLK_X4 period not standard VGA clock period
	scan_conv : entity work.VGA_SCANCONV
	generic map (
		hA				=>  16,	-- h front porch
		hB				=>  92,	-- h sync
		hC				=>  46,	-- h back porch
		hres			=> 512,	-- visible video
		hpad			=>  51,	-- padding either side to reach standard VGA resolution (hres + 2*hpad = hD)

		vB				=>   2,	-- v sync
		vC				=>  32,	-- v back porch
		vres			=> 448,	-- visible video
		vpad			=>  16,	-- padding either side to reach standard VGA resolution (vres + vpad = vD)

		cstart      =>  56,  -- composite sync start
		clength     => 256   -- composite sync length
	)
	port map (
		I_VIDEO(15 downto 12)=> "0000",
		I_VIDEO(11 downto 8) => s_red,
		I_VIDEO( 7 downto 4) => s_grn,
		I_VIDEO( 3 downto 0) => s_blu,
		I_HSYNC					=> s_hsync_n,
		I_VSYNC					=> s_vsync_n,
		--
		O_VIDEO(15 downto 12)=> dummy,
		O_VIDEO(11 downto 8) => VideoR,
		O_VIDEO( 7 downto 4) => VideoG,
		O_VIDEO( 3 downto 0) => VideoB,
		O_HSYNC					=> HSync,
		O_VSYNC					=> VSync,
		O_CMPBLK_N				=> s_cmpblk_x4_n,
		--
		CLK						=> clk_6M_en,
		CLK_X4					=> clk_24M
	);

	OBUFDS_clk : OBUFDS port map ( O => TMDS_P(3), OB => TMDS_N(3), I => clk_s );
	OBUFDS_grn : OBUFDS port map ( O => TMDS_P(2), OB => TMDS_N(2), I => red_s );
	OBUFDS_red : OBUFDS port map ( O => TMDS_P(1), OB => TMDS_N(1), I => grn_s );
	OBUFDS_blu : OBUFDS port map ( O => TMDS_P(0), OB => TMDS_N(0), I => blu_s );

	s_blank <= not s_cmpblk_x4_n;

	inst_dcm : DCM_SP
		generic map (
			CLKFX_MULTIPLY => 12,
			CLKFX_DIVIDE   => 5,
			CLKIN_PERIOD   => 20.0
		 )
		port map (
			CLKIN    => CLK_IN,
			CLKFX    => clk_dvi_p,
			CLKFX180 => clk_dvi_n
		 );

	inst_dvid: entity work.dvid
	port map(
      clk_p     => clk_dvi_p,
      clk_n     => clk_dvi_n, 
      clk_pixel => clk_24M,
      red_p(  7 downto 4) => VideoR,
      red_p(  3 downto 0) => x"0",
      green_p(7 downto 4) => VideoG,
      green_p(3 downto 0) => x"0",
      blue_p( 7 downto 4) => VideoB,
      blue_p( 3 downto 0) => x"0",
      blank     => s_blank,
      hsync     => HSync,
      vsync     => VSync,
      -- outputs to TMDS drivers
      red_s     => red_s,
      green_s   => grn_s,
      blue_s    => blu_s,
      clock_s   => clk_s
   );

	----------------------
	-- 1 bit D/A converter
	----------------------
	dac : entity work.DAC
	port map (
		clk_i		=> clk_48M, -- the higher the clock the better
		res_i		=> ext_reset,
		dac_i		=> s_audio,
		dac_o		=> s_dac_out
	);

	---------------------------------
	-- page 4 schematic - sprite ROMS
	---------------------------------
	-- chip 7J page 4
	ROM_7J : entity work.ROM_7J
	port map (
		CLK	=> clk_12M,
		ENA	=> o_rom_7JLM_ena,
		ADDR	=> o_rom_7JLM_addr,
		DATA	=> i_rom_7JLM_data(23 downto 16)
	);

	-- chip 7L page 4
	ROM_7L : entity work.ROM_7L
	port map (
		CLK	=> clk_12M,
		ENA	=> o_rom_7JLM_ena,
		ADDR	=> o_rom_7JLM_addr,
		DATA	=> i_rom_7JLM_data(15 downto  8)
	);

	-- chip 7M page 4
	ROM_7M : entity work.ROM_7M
	port map (
		CLK	=> clk_12M,
		ENA	=> o_rom_7JLM_ena,
		ADDR	=> o_rom_7JLM_addr,
		DATA	=> i_rom_7JLM_data( 7 downto  0)
	);

	----------------------------------------------
	-- page 6 schematic - character generator ROMs
	----------------------------------------------
	-- chip 8K page 6
	ROM_8K : entity work.ROM_8K
	port map (
		CLK	=> clk_12M,
		ENA	=> o_rom_8KHE_ena,
		ADDR	=> o_rom_8KHE_addr(11 downto 0),
		DATA	=> i_rom_8KHE_data(23 downto 16)
	);

	-- chip 8H page 6
	ROM_8H : entity work.ROM_8H
	port map (
		CLK	=> clk_12M,
		ENA	=> o_rom_8KHE_ena,
		ADDR	=> o_rom_8KHE_addr(11 downto 0),
		DATA	=> i_rom_8KHE_data(15 downto  8)
	);

	-- chip 8E page 6
	ROM_8E : entity work.ROM_8E
	port map (
		CLK	=> clk_12M,
		ENA	=> o_rom_8KHE_ena,
		ADDR	=> o_rom_8KHE_addr(11 downto 0),
		DATA	=> i_rom_8KHE_data( 7 downto  0)
	);

	-------------------------------------------
	-- page 7 schematic - background tiles ROMs
	-------------------------------------------
	-- chip 4P page 7
	ROM_4P : entity work.ROM_4P
	port map (
		CLK	=> clk_12M,
		ENA	=> o_rom_4P_ena,
		ADDR	=> o_rom_4P_addr(11 downto 0),
		DATA	=> i_rom_4P_data
	);

	-- chip 8R page 7
	ROM_8R : entity work.ROM_8R
	port map (
		CLK	=> clk_12M,
		ENA   => o_rom_8RNL_ena,
		ADDR	=> o_rom_8RNL_addr,
		DATA  => i_rom_8RNL_data(23 downto 16)
	);

	-- chip 8N page 7
	ROM_8N : entity work.ROM_8N
	port map (
		CLK	=> clk_12M,
		ENA   => o_rom_8RNL_ena,
		ADDR	=> o_rom_8RNL_addr,
		DATA  => i_rom_8RNL_data(15 downto  8)
	);

	-- chip 8L page 7
	ROM_8L : entity work.ROM_8L
	port map (
		CLK	=> clk_12M,
		ENA   => o_rom_8RNL_ena,
		ADDR	=> o_rom_8RNL_addr,
		DATA  => i_rom_8RNL_data( 7 downto  0)
	);

end RTL;
