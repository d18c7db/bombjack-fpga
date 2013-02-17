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
         FLASH_CS    : out std_logic;
         FLASH_SI    : out std_logic;
         FLASH_SO    : in  std_logic := '0';
         FLASH_CK    : out std_logic;
			--
         SRAM_A		: out	std_logic_vector(17 downto 0);
         SRAM_D		: inout	std_logic_vector(15 downto 0);
         SRAM_nCS		: out	std_logic;
         SRAM_nWE		: out	std_logic;
         SRAM_nOE		: out	std_logic;
         SRAM_nBE		: out	std_logic;
			--
			O_VIDEO_R	: out		std_logic_vector(3 downto 0);
			O_VIDEO_G	: out		std_logic_vector(3 downto 0);
			O_VIDEO_B	: out		std_logic_vector(3 downto 0);
			O_HSYNC		: out		std_logic;
			O_VSYNC		: out		std_logic;
			--
         O_AUDIO_L	: out	std_logic;
         O_AUDIO_R	: out	std_logic;
			--
			-- Active high external buttons
			I_SW			: in		std_logic_vector(3 downto 0);		-- input switches
			I_RESET		: in		std_logic;								-- push button (not used as reset here)

         CLK_IN      : in  std_logic := '0'
        );
    end component;

   --Inputs
   signal clock    : std_logic := '0';
   signal FLASH_SO : std_logic := '1';
   signal CLK_IN   : std_logic := '0';
   signal RESET    : std_logic := '0';

 	--Outputs
   signal FLASH_CS : std_logic := '0';
   signal FLASH_SI : std_logic := '0';
   signal FLASH_CK : std_logic := '0';

   signal SRAM_nCS : std_logic := '0';
   signal SRAM_nWE : std_logic := '0';
   signal SRAM_nOE : std_logic := '0';
   signal SRAM_nBE : std_logic := '0';
   signal SRAM_A : std_logic_vector(17 downto 0) := (others => '0');
   signal SRAM_D : std_logic_vector(15 downto 0) := (others => '0');

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
		FLASH_CS => FLASH_CS,
		FLASH_SI => FLASH_SI,
		FLASH_SO => FLASH_SO,
		FLASH_CK => FLASH_CK,
		SRAM_A	 => SRAM_A,
		SRAM_D	 => SRAM_D,
		SRAM_nCS => SRAM_nCS,
		SRAM_nWE => SRAM_nWE,
		SRAM_nOE => SRAM_nOE,
		SRAM_nBE => SRAM_nBE,
		O_VIDEO_R	=> open,
		O_VIDEO_G	=> open,
		O_VIDEO_B	=> open,
		O_HSYNC		=> open,
		O_VSYNC		=> open,
		O_AUDIO_L	=> open,
		O_AUDIO_R	=> open,

		I_RESET		=> '0',
		I_SW(0)		=> RESET,
		I_SW(1)		=> RESET,
		I_SW(2)		=> RESET,
		I_SW(3)		=> RESET,

		CLK_IN   => CLK_IN
  );

	CLK_IN <= clock;
   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
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
		RESET <= '1';
		wait for 3*clock_period;
		RESET <= '0';
		wait;
   end process;

end;
