----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:03:45 11/21/2011 
-- Design Name: 
-- Module Name:    digit - RTL 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;

entity digit is
    port (
			clk     : in   std_logic := '0'; -- module clock
			offsetx : in   integer := 0; -- screen horiz coordinate to place digit
			offsety : in   integer := 0; -- screen vert  coordinate to place digit
			index   : in   integer := 0; -- unique index of digit (further horiz offsets digits so as not to overlap others)
			seglen  : in   integer := 0; -- segment length in pixels, determines overall size of digit
			gap     : in   integer := 0; -- inter digit gap in pixels
			hcnt    : in   std_logic_vector (9 downto 0) := (others => '0'); -- VGA counter, current horiz pixel being drawn
			vcnt    : in   std_logic_vector (9 downto 0) := (others => '0'); -- VGA counter, current vert addr of pixel being drawn
			value   : in   std_logic_vector (3 downto 0) := (others => '0'); -- value to display on the seven segments
			enable  : out  std_logic -- pixel on/off signal
	 );
end digit;

architecture RTL of digit is
	signal   sseg    : std_logic_vector (6 downto 0) := (others => '0'); -- seven segment display enables, order: a,b,c,d,e,f,g
begin
	-- binary to seven segment decoder, determines shape to display
	with value select sseg <=
		"1111110" when x"0",
		"0110000" when x"1",
		"1101101" when x"2",
		"1111001" when x"3",
		"0110011" when x"4",
		"1011011" when x"5",
		"1011111" when x"6",
		"1110000" when x"7",
		"1111111" when x"8",
		"1111011" when x"9",
		"1110111" when x"a",
		"0011111" when x"b",
		"1001110" when x"c",
		"0111101" when x"d",
		"1001111" when x"e",
		"1000111" when x"f",
		"0000000" when others;

	digit : process
		variable xpos    : integer := offsetx+(index*(seglen+gap)); -- adjusted horiz position
		variable ypos    : integer := offsety;                      -- vert position
	begin
		wait until rising_edge(clk);
		if -- draw the seven segments of the digit based on the sseg enables
			( (sseg(6)='1') and (hcnt<=xpos+seglen) and (hcnt>=xpos) and (vcnt =ypos           )                         ) or -- segment a
			( (sseg(5)='1') and (hcnt =xpos+seglen)                  and (vcnt<=ypos+ seglen   ) and (vcnt>=ypos       ) ) or -- segment b
			( (sseg(4)='1') and (hcnt =xpos+seglen)                  and (vcnt<=ypos+(seglen*2)) and (vcnt>=ypos+seglen) ) or -- segment c
			( (sseg(3)='1') and (hcnt<=xpos+seglen) and (hcnt>=xpos) and (vcnt =ypos+(seglen*2))                         ) or -- segment d
			( (sseg(2)='1') and (hcnt =xpos       )                  and (vcnt<=ypos+(seglen*2)) and (vcnt>=ypos+seglen) ) or -- segment e
			( (sseg(1)='1') and (hcnt =xpos       )                  and (vcnt<=ypos+ seglen   ) and (vcnt>=ypos       ) ) or -- segment f
			( (sseg(0)='1') and (hcnt<=xpos+seglen) and (hcnt>=xpos) and (vcnt =ypos+ seglen   )                         )    -- segment g
		then
			enable <= '1';
		else
			enable <= '0';
		end if;
	end process digit;
end RTL;
