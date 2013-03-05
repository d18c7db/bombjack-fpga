--------------------------------------------------------------------------------
-- the sound board appears to work as follows
-- the unlabeled signal going into the 2J flip flop was determined experimentally to be vsync so the regular
-- NMI generated "plays" the sound that is selected by writing one of the values below to the 2L latch

-- First column is the sound ID to write to the latch 2L, next column is which PSG is actively playing it.
-- 01 123 resets all sounds to silence
-- 10 --3 add credit (coin) sound
-- 11 -23 
-- 13 -23 ? (continuous, must be reset with 01)
-- 14 -2- dead jack
-- 15 --3 spawn new enemy
-- 16 --3 robot fall
-- 17 --3 
-- 18 -23 aquire bomb
-- 19 -23 
-- 1A 12- aquire power bonus
-- 1B 12- bonus update (continuous, must be reset with 01)
-- 1D -23 fast fall (leaves a high pitched noise on B, must be reset with 01)
-- 1F -23 
-- 20 12- title screen music
-- 22 12- level 3 background music
-- 23 12- level 1 background music
-- 24 12- level 2 background music
-- 25 12- init stage end
-- 26 123 game over
-- 27 1-- update dying sequence (noise gen)
-- 28 12- bonus
-- 29 123 first place
-- 2a 12- high score entry
-- 2b 123 special bonus screen (continuous)
-- 2c --3 aquire killable (noise gen)
-- 2d --3 robot state
-- 2e 12- (continuous, must be reset with 01)

-- From MAME, the following channels are active
--    1A 1B 1C 2A 2B 2C 3A 3B 3C
-- 10  -  -  -  -  -  -  -  X  X add credit (coin) sound
-- 20  X  X  X  X  X  -  -  -  - title music
-- 23  X  X  X  X  -  -  -  -  - level 1 background music
-- 24  X  X  X  X  -  -  -  -  - level 2 background music
--------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

library unisim;
	use unisim.vcomponents.all;

entity PAPILIO_TOP is
	port(
		-- FLASH
		FLASH_CS		: out		std_logic;								-- Active low FLASH chip select
		FLASH_SI		: out		std_logic;								-- Serial output to FLASH chip SI pin
		FLASH_CK		: out		std_logic;								-- FLASH clock
		FLASH_SO		: in		std_logic := '0';						-- Serial input from FLASH chip SO pin

		-- SRAM
		SRAM_A		: out		std_logic_vector(17 downto 0);	-- SRAM address bus
		SRAM_D		: inout	std_logic_vector(15 downto 0);	-- SRAM data bus
		SRAM_nCS		: out		std_logic;								-- SRAM chip select active low
		SRAM_nWE		: out		std_logic;								-- SRAM write enable active low
		SRAM_nOE		: out		std_logic;								-- SRAM output enable active low
		SRAM_nBE		: out		std_logic;								-- SRAM byte enables active low

		-- VGA monitor output
		O_VIDEO_R	: out		std_logic_vector(3 downto 0);
		O_VIDEO_G	: out		std_logic_vector(3 downto 0);
		O_VIDEO_B	: out		std_logic_vector(3 downto 0);
		O_HSYNC		: out		std_logic;
		O_VSYNC		: out		std_logic;

		-- Sound out
		O_AUDIO_L	: out		std_logic;
		O_AUDIO_R	: out		std_logic;

		-- Active high external buttons
		I_SW			: in		std_logic_vector(3 downto 0);		-- input switches
		I_RESET		: in		std_logic;								-- push button (not used as reset here)

		-- 32MHz clock
		CLK_IN		: in		std_logic := '0'						-- System clock 32Mhz

	);
end PAPILIO_TOP;

architecture RTL of PAPILIO_TOP is
	-- debug signals
	signal cycle 				: std_logic_vector(19 downto 0) := (others => '0');
	signal edge 				: std_logic_vector( 1 downto 0) := (others => '0');
	signal da_hold				: std_logic_vector(23 downto 0) := (others => '0');
	signal dd_hold				: std_logic_vector( 7 downto 0) := (others => '0');
	signal digit_en			: std_logic_vector( 7 downto 0) := (others => '0');
	signal HCnt					: std_logic_vector( 9 downto 0) := (others => '0');
	signal VCnt					: std_logic_vector( 9 downto 0) := (others => '0');
	signal buttons_in			: std_logic_vector( 4 downto 0) := (others => '0');
	signal buttons_deb		: std_logic_vector( 4 downto 0) := (others => '0');
	signal buttons_deb_last	: std_logic_vector( 4 downto 0) := (others => '0');
	signal svalue				: std_logic_vector( 7 downto 0) := (others => '0');
	signal s_audio				: std_logic_vector( 7 downto 0) := (others => '0');
	signal s_chen				: std_logic_vector( 8 downto 0) := (others => '1');
	signal VideoR				: std_logic_vector( 3 downto 0);
	signal VideoG				: std_logic_vector( 3 downto 0);
	signal VideoB				: std_logic_vector( 3 downto 0);
	signal dummy				: std_logic_vector( 3 downto 0);
	signal HSync				: std_logic := '1';
	signal VSync				: std_logic := '1';
	signal s_dac_out			: std_logic := '1';

	signal ext_reset			: std_logic := '0';

	signal psg_data_out		: std_logic_vector( 7 downto 0) := (others => '0');
	signal psg_data_in		: std_logic_vector( 7 downto 0) := (others => '0');
	signal s_psg1_n			: std_logic := '0';
	signal s_psg2_n			: std_logic := '0';
	signal s_psg3_n			: std_logic := '0';
	signal s_swr_n				: std_logic := '0';
	signal s_srd_n				: std_logic := '0';
	signal s_sa0				: std_logic := '0';

	signal clk_4M_en			: std_logic := '0';
	signal clk_6M_en			: std_logic := '0';
	signal clk_12M				: std_logic := '0';
	signal clk_48M				: std_logic := '0';
	signal s_mewr_n			: std_logic := '1';

	signal s_cs_b800_n		: std_logic := '1';

	signal ram_state_ctr		: std_logic_vector( 3 downto 0) := (others => '0');
	signal my_ctr				: std_logic_vector( 2 downto 0) := (others => '0');

	signal cpu_data_out		: std_logic_vector( 7 downto 0) := (others => '0');
	signal RESETn				: std_logic := '1';

	signal s_hsync_n			: std_logic := '1';
	signal s_vsync_n			: std_logic := '1';

	signal s_1H					: std_logic := '0';
	signal s_2H					: std_logic := '0';
	signal s_4H					: std_logic := '0';
	signal s_8H					: std_logic := '0';
	signal s_16H				: std_logic := '0';
	signal s_32H				: std_logic := '0';
	signal s_64H				: std_logic := '0';
	signal s_128H				: std_logic := '0';
	signal s_256H_n			: std_logic := '1';

	signal s_1V_r				: std_logic := '0';
	signal s_1V_n_r			: std_logic := '0';
	signal s_256H_r			: std_logic := '0';
	signal s_contrlda_n		: std_logic := '1';
	signal s_contrldb_n		: std_logic := '1';

begin
	-----------------------------------------------
	-- DCM generates all the system clocks required
	-----------------------------------------------
	clockgen : entity work.CLOCKGEN
	port map(
		I_CLK			=> CLK_IN,
		I_RST			=> ext_reset,
		O_CLK_4M		=> clk_4M_en,
		O_CLK_6M		=> clk_6M_en,
		O_CLK_12M	=> clk_12M,
--		O_CLK_24M	=> open,
--		O_CLK_32M	=> open,
		O_CLK_48M	=> clk_48M
	);
	da : for i in 0 to 5 generate
	begin
		dad : entity work.digit
		port map (
			clk		=> clk_12M,
			offsetx	=> 20,
			offsety	=> 40,
			index		=> i,
			seglen	=> 16,
			gap		=> 4,
			hcnt		=> HCnt,
			vcnt		=> VCnt,
			value		=> da_hold( ((6-i)*4-1) downto ((6-i)*4-4) ),
			enable	=> digit_en(i)
		);
	end generate;

	dd : for i in 0 to 1 generate
	begin
		dda : entity work.digit
		port map (
			clk	=> clk_12M,
			offsetx	=> 160, -- offsetx above 8 + (6 digits + 1 space digit) * (seglen + gap)
			offsety	=> 40,
			index		=> i,
			seglen	=> 16,
			gap		=> 4,
			hcnt		=> HCnt,
			vcnt		=> VCnt,
			value		=> dd_hold( ((2-i)*4-1) downto ((2-i)*4-4) ),
			enable	=> digit_en(i+6)
		);
	end generate;

	-- Use existing H and V sync signals to sync our digits with video
	hvcount : process
	begin
		wait until rising_edge(clk_12M);
		if (VSync = '0') and (HSync = '0') then
			HCnt <= (others => '0');
			VCnt <= (others => '0');
		elsif (HCnt = 383) then
			HCnt <= (others => '0');
			if (VCnt = 624) then
				VCnt <= (others => '0');
			else
				VCnt <= VCnt + 1;
			end if;
		else
			HCnt <= HCnt + 1;
		end if;

		-- if any digit enable is set superimpose digits on video
		if HSync = '0' or VSync = '0' then
			O_VIDEO_G <= (others => '0');
			O_VIDEO_R <= (others => '0');
			O_VIDEO_B <= (others => '0');
		else
			if digit_en > 0 then
				O_VIDEO_G <= "1111";
				O_VIDEO_R <= "0000";
				O_VIDEO_B <= "0000";
			else
				O_VIDEO_G <= VideoG;
				O_VIDEO_R <= VideoR;
				O_VIDEO_B <= VideoB;
			end if;
		end if;
	end process;

	SRAM_D		<= (others=> '0');
	SRAM_A		<= (others=> '0');
	SRAM_nCS		<= '1';
	SRAM_nWE		<= '1';
	SRAM_nOE		<= '1';
	SRAM_nBE		<= '1';
	FLASH_CS		<= '1';
	FLASH_SI		<= '1';
	FLASH_CK		<= '1';
	O_HSYNC		<= HSync;
	O_VSYNC		<= VSync;
	RESETn		<= not ext_reset;
	ext_reset	<= (I_SW(0) and I_SW(1) and I_SW(2) and I_SW(3));	-- active high reset when all buttons pressed (active low buttons)

	-- video scan doubler required to display video on VGA hardware
	scan_dbl : entity work.VGA_SCANDBL
	port map (
		I_VIDEO					=> x"0000",
		I_HSYNC					=> s_hsync_n,
		I_VSYNC					=> s_vsync_n,
		--
		O_VIDEO(15 downto 12)=> dummy,
		O_VIDEO(11 downto 8)	=> VideoR,
		O_VIDEO( 7 downto 4)	=> VideoG,
		O_VIDEO( 3 downto 0)	=> VideoB,
		O_HSYNC					=> HSync,
		O_VSYNC					=> VSync,
		--
		CLK						=> clk_6M_en,
		CLK_X2					=> clk_12M
	);

	-- page 3 schematic - video and timing signal generator
	p3 : entity work.timing
	port map (
		I_CLK_6M_EN			=> clk_6M_en,
		I_FLIP				=> '1',
		I_CS_9A00_n			=> '1',
		I_MEWR_n				=> '1',
		I_AB					=> '0',
		I_DB					=> (others => '0'),
		--
		O_SLOAD_n			=> open,
--		O_SLOAD				=> open,
		O_SL1_n				=> open,
		O_SL2_n				=> open,
		O_SW_n				=> open,
		O_SS					=> open,
		O_HBL					=> open,
		O_CONTROLDB_n		=> open,
		O_CONTROLDA_n		=> open,
		O_VPL_n				=> open,
		O_CDL_n				=> open,
		O_MDL_n				=> open,
		O_SEL					=> open,
		O_1V_r				=> open,
		O_1V_n_r				=> open,
		O_256H_r				=> open,
		O_CMPBLK_n_r		=> open,
		O_CMPBLK_n			=> open,
--		O_CMPBLK				=> open,
		O_VBLANK_n			=> open,
		O_VBLANK				=> open,
--		O_TVSYNC_n			=> open,
		O_HSYNC_n 			=> s_hsync_n,

		O_1H					=> s_1H,
		O_2H					=> s_2H,
		O_4H					=> open,
		O_8H					=> open,
		O_16H					=> open,
		O_32H					=> open,
		O_64H					=> open,
		O_128H				=> open,
		O_256H_n 			=> open,

		O_8H_X				=> open,
		O_16H_X				=> open,
		O_32H_X				=> open,
		O_64H_X				=> open,
		O_128H_X 			=> open ,

		O_1V_X				=> open,
		O_2V_X				=> open,
		O_4V_X				=> open,
		O_8V_X				=> open,
		O_16V_X				=> open,
		O_32V_X				=> open,
		O_64V_X				=> open,
		O_128V_X				=> open,
		O_VSYNC_n			=> s_vsync_n
	);

	-----------------------------------------
	-- page 9 schematic - audio CPU, ROM, RAM
	-----------------------------------------
	p9 : entity work.audio
	port map (
		I_RESET_n			=> RESETn,
		I_CLK_3M				=> s_1H,
		I_VSYNC_n			=> s_vsync_n,
		I_CS_B800_n			=> s_cs_b800_n,
		I_MERW_n				=> s_mewr_n,
		I_DB_CPU				=> cpu_data_out,
		I_SD					=> psg_data_out,
		O_SD					=> psg_data_in,
		O_SA0					=> s_sa0,
		O_PSG1_n				=> s_psg1_n,
		O_PSG2_n				=> s_psg2_n,
		O_PSG3_n				=> s_psg3_n,
		O_SWR_n				=> s_swr_n,
		O_SRD_n				=> s_srd_n
	);

	----------------------------------------------------
	-- page 10 schematic - programmable sound generators
	----------------------------------------------------
	p10 : entity work.psgs
	port map (
		I_RST_n				=> RESETn,
		I_CLK					=> s_1H,
		I_SWR_n				=> s_swr_n,
		I_SRD_n				=> s_srd_n,
		I_SA0					=> s_sa0,
		I_PSG1_n				=> s_psg1_n,
		I_PSG2_n				=> s_psg2_n,
		I_PSG3_n				=> s_psg3_n,
		I_CHEN				=> s_chen,
		I_SD					=> psg_data_in,
		O_SD					=> psg_data_out,
		O_AUDIO				=> s_audio
	);

	----------------------
	-- 1 bit D/A converter
	----------------------
	dac : entity work.DAC
	port map (
		clk_i		=> clk_48M, -- the higher the clock the better
		res_n_i	=> RESETn,
		dac_i		=> s_audio,
		dac_o		=> s_dac_out
	);

	O_AUDIO_L <= s_dac_out;
	O_AUDIO_R <= s_dac_out;

	buttons_in <= I_SW & I_RESET;

	debounce: entity work.debounce
	generic map (
		G_WIDTH => 5
	)
	port map (
		I_BUTTON          => buttons_in, -- active high
		O_BUTTON          => buttons_deb,
		CLK               => s_2H
	);

	process(s_vsync_n)
	begin
		if rising_edge(s_vsync_n) then
			if		(buttons_deb_last(2) = '0') and (buttons_deb(2) = '1') then -- up (val ++)
				svalue(5 downto 0) <= svalue(5 downto 0) + 1;
			elsif	(buttons_deb_last(3) = '0') and (buttons_deb(3) = '1') then -- down (val --)
				svalue(5 downto 0) <= svalue(5 downto 0) - 1;
			end if;
			buttons_deb_last <= buttons_deb;
		end if;
	end process;

	-- display debug information on vga screen
	da_hold <= '0' & s_chen(8) & s_chen(7) & s_chen(6) & "0" & s_chen(5) & s_chen(4) & s_chen(3) & "0" & s_chen(2) & s_chen(1) & s_chen(0) & x"0" & svalue;

	toggle : process(s_vsync_n)
	begin
		if rising_edge(s_vsync_n) then
			if (buttons_deb_last(4) = '0') and (buttons_deb(4) = '1') then -- rising edge (toggle)
				if svalue < x"0a" then
					case svalue is
						when x"01" => s_chen(8) <= not s_chen(8);
						when x"02" => s_chen(7) <= not s_chen(7);
						when x"03" => s_chen(6) <= not s_chen(6);
						when x"04" => s_chen(5) <= not s_chen(5);
						when x"05" => s_chen(4) <= not s_chen(4);
						when x"06" => s_chen(3) <= not s_chen(3);
						when x"07" => s_chen(2) <= not s_chen(2);
						when x"08" => s_chen(1) <= not s_chen(1);
						when x"09" => s_chen(0) <= not s_chen(0);
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;

	-- reset and advance the state machine
	state_init : process(s_1H, buttons_deb(3), buttons_deb(2))
	begin
		if rising_edge(s_1H) then
			if (buttons_deb(1) = '1') then -- left (set)
				if svalue > x"09" then -- values 1 through 9 are for toggling respective channels on/off - no useable sounds there anyway
					ram_state_ctr <= (others => '0');
				end if;
			elsif (buttons_deb(0) = '1') then -- reset
				ram_state_ctr <= "1000";
			end if;

			if ram_state_ctr(2) = '0' then
				ram_state_ctr <= ram_state_ctr + 1;
			end if;
		end if;
	end process;

	-- perform a SRAM read from a specific address depending on which state we're currently in
	ram_read : process(s_1H)
	begin
		if falling_edge(s_1H) then
			case ram_state_ctr is
				when "0000" => s_cs_b800_n <= '1';
				when "0001" => s_cs_b800_n <= '0'; cpu_data_out <= svalue;
				when "0010" => s_mewr_n <= '0'; dd_hold <= cpu_data_out;
				when "0011" => s_mewr_n <= '1'; s_cs_b800_n <= '1';

				when "1000" => s_cs_b800_n <= '1';
				when "1001" => s_cs_b800_n <= '0'; cpu_data_out <= x"01";
				when "1010" => s_mewr_n <= '0'; dd_hold <= cpu_data_out;
				when "1011" => s_mewr_n <= '1'; s_cs_b800_n <= '1';
				when others   => null;
			end case;
		end if;
	end process;
end RTL;
