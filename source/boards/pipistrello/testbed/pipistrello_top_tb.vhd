--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:16:24 02/15/2013
-- Design Name:   
-- Module Name:   C:/Users/alex/workspace/bombjack_pipistrello/source/testbed/bombjack_top_tb.vhd
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

entity PIPISTRELLO_TB is
end PIPISTRELLO_TB;
 
architecture behavior of PIPISTRELLO_TB is 
 
	-- Component Declaration for the Unit Under Test (UUT)
	component PIPISTRELLO_TOP
	port(
		I_RESET   : in     std_logic;
		--
		O_VIDEO_R : out    std_logic_vector( 3 downto 0);
		O_VIDEO_G : out    std_logic_vector( 3 downto 0);
		O_VIDEO_B : out    std_logic_vector( 3 downto 0);
		O_HSYNC   : out    std_logic;
		O_VSYNC   : out    std_logic;
		--
		O_AUDIO_L : out    std_logic;
		O_AUDIO_R : out    std_logic;
		--
		PS2CLK1		: inout	std_logic;
		PS2DAT1		: inout	std_logic;
		--
		CLK_IN    : in     std_logic
	);
	end component;

	--Inputs
	signal I_RESET   : std_logic := '0';
	signal CLK_IN    : std_logic := '0';

	signal PS2CLK1   : std_logic;
	signal PS2DAT1   : std_logic;

	--Outputs
	signal O_VIDEO_R : std_logic_vector(3 downto 0);
	signal O_VIDEO_G : std_logic_vector(3 downto 0);
	signal O_VIDEO_B : std_logic_vector(3 downto 0);
	signal O_HSYNC   : std_logic;
	signal O_VSYNC   : std_logic;
	signal O_AUDIO_L : std_logic;
	signal O_AUDIO_R : std_logic;

	-- Clock period definitions
	constant CLK_IN_period : time := 20 ns;

begin
	-- Instantiate the Unit Under Test (UUT)
	uut: PIPISTRELLO_TOP port map (
		I_RESET   => I_RESET,
		O_VIDEO_R => O_VIDEO_R,
		O_VIDEO_G => O_VIDEO_G,
		O_VIDEO_B => O_VIDEO_B,
		O_HSYNC   => O_HSYNC,
		O_VSYNC   => O_VSYNC,
		O_AUDIO_L => O_AUDIO_L,
		O_AUDIO_R => O_AUDIO_R,
		PS2CLK1   => PS2CLK1,
		PS2DAT1   => PS2DAT1,
		CLK_IN    => CLK_IN
	);

	-- Clock process definitions
	CLK_IN_process :process
	begin
		CLK_IN <= '0';
		wait for CLK_IN_period/2;
		CLK_IN <= '1';
		wait for CLK_IN_period/2;
	end process;


	-- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		I_RESET <= '1';
		wait for CLK_IN_period*16;
		I_RESET <= '0';

		wait for CLK_IN_period*16;

		-- insert stimulus here 

		wait;
	end process;

end;
