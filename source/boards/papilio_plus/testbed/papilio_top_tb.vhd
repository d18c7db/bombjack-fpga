--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   21:55:32 08/22/2011
-- Design Name:
-- Module Name:   C:/Users/alex/workspace/bombjack_papilio/source/bj_tb.vhd
-- Project Name:  bombjack
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: BOMB_JACK_TOP
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_textio.all;

library std;
	use std.textio.all;

library unisim;
	use unisim.vcomponents.all;

entity bj_tb is
		generic(stim_file: string :="..\source\boards\papilio_plus\testbed\stim.txt");
end bj_tb;
 
architecture behavior of bj_tb is
 
    component ROM is
    port (
        ROM_nCS :in  std_logic;
        ROM_nOE :in  std_logic;
        ROM_A   :in  std_logic_vector (16 downto 0); -- Address input
        ROM_D   :out std_logic_vector ( 7 downto 0)  -- Data output
    );
    end component;

    -- Component Declaration for the Unit Under Test (UUT)
    component PAPILIO_TOP
	port(
		I_RESET		: in		std_logic;								-- active high reset

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
		PS2CLK1		: inout	std_logic;
		PS2DAT1		: inout	std_logic;

		-- 32MHz clock
		CLK_IN		: in		std_logic := '0'						-- System clock 32Mhz

	);
end component;
	signal I_RESET		: std_logic := '0';
	signal CLK_IN		: std_logic := '0';
	signal FLASH_SO	: std_logic := '0';

	signal FLASH_CS	: std_logic := '0';
	signal FLASH_SI	: std_logic := '0';
	signal FLASH_CK	: std_logic := '0';

	signal SRAM_A		: std_logic_vector(17 downto 0) := (others => '0');
	signal SRAM_D		: std_logic_vector(15 downto 0) := (others => '0');
	signal SRAM_nCS	: std_logic := '0';
	signal SRAM_nWE	: std_logic := '0';
	signal SRAM_nOE	: std_logic := '0';
	signal SRAM_nBE	: std_logic := '0';

	signal O_VIDEO_R	: std_logic_vector(3 downto 0);
	signal O_VIDEO_G	: std_logic_vector(3 downto 0);
	signal O_VIDEO_B	: std_logic_vector(3 downto 0);
	signal O_HSYNC		: std_logic := '0';
	signal O_VSYNC		: std_logic := '0';

	signal O_AUDIO_L	: std_logic := '0';
	signal O_AUDIO_R	: std_logic := '0';

	signal PS2CLK1		: std_logic := '0';
	signal PS2DAT1		: std_logic := '0';

	file stimulus: TEXT open read_mode is stim_file;
	signal counter : std_logic_vector(5 downto 0) := (others => '0');
	constant clock_period : time := 31.25 ns;

begin
    static_rom: ROM port map (
        ROM_nCS => SRAM_nCS,
        ROM_nOE => SRAM_nOE,
        ROM_A   => SRAM_A(16 downto 0),
        ROM_D   => SRAM_D( 7 downto 0)
    );

	SRAM_D(15 downto 8) <= x"00";

	-- Instantiate the unit under test (uut)
	uut: PAPILIO_TOP port map (
		I_RESET	 =>   I_RESET,

		FLASH_CS	 =>   FLASH_CS,
		FLASH_SI	 =>   FLASH_SI,
		FLASH_CK	 =>   FLASH_CK,
		FLASH_SO	 =>   FLASH_SO,

		SRAM_A	 =>   SRAM_A,
		SRAM_D	 =>   SRAM_D,
		SRAM_nCS	 =>   SRAM_nCS,
		SRAM_nWE	 =>   SRAM_nWE,
		SRAM_nOE	 =>   SRAM_nOE,
		SRAM_nBE	 =>   SRAM_nBE,

		O_VIDEO_R =>   O_VIDEO_R,
		O_VIDEO_G =>   O_VIDEO_G,
		O_VIDEO_B =>   O_VIDEO_B,
		O_HSYNC	 =>   O_HSYNC,
		O_VSYNC	 =>   O_VSYNC,

		O_AUDIO_L =>   O_AUDIO_L,
		O_AUDIO_R =>   O_AUDIO_R,

		PS2CLK1	 =>   PS2CLK1,
		PS2DAT1	 =>   PS2DAT1,

		CLK_IN	 =>   CLK_IN
	);

	-- Clock process definitions
	clock_process :process
	begin
		CLK_IN <= '0';
		wait for clock_period/2;
		CLK_IN <= '1';
		wait for clock_period/2;
	end process;

	process(FLASH_CS, FLASH_CK)
	begin
		if FLASH_CS = '1' then
			counter <= (others => '0');
		elsif rising_edge(FLASH_CK) then
			if (counter <= "100111") then
				counter <= counter + 1;
			end if;
		end if;
	end process;

	-- Stimulus process
   stim_proc: process(FLASH_CK)
		variable inline:line;
		variable bv:std_logic_vector(7 downto 0) := (others => '0');
		variable i :std_logic_vector(2 downto 0) := (others => '0');
   begin		
		if not endfile(stimulus) then
			if falling_edge(FLASH_CK) and (counter > "100111") then 
				if i="000" then
					readline(stimulus, inline);
					hread(inline, bv);
				end if;
				i := i - 1;
				FLASH_SO <= bv(conv_integer(i));
			end if;
		else
			FLASH_SO <= '1';
		end if;
   end process;

	main : process
	begin
		I_RESET <= '1';
		wait for 16*clock_period;
		I_RESET <= '0';
		wait;
	end process;

end;
