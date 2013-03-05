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

library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.ALL;

library unisim;
	use unisim.vcomponents.all;

entity CLOCKGEN is
	generic (
		C_CLKFX_DIVIDE   : integer := 2;
		C_CLKFX_MULTIPLY : integer := 3;
		C_CLKIN_PERIOD   : real    := 31.25
	);
	port (
		I_CLK						: in	std_logic;
		I_RST						: in	std_logic;
		O_CLK_4M					: out	std_logic;
		O_CLK_6M					: out	std_logic;
		O_CLK_12M				: out	std_logic;
--		O_CLK_32M				: out	std_logic;
		O_CLK_48M				: out	std_logic
--		STATUS					: out	std_logic_vector(7 downto 0);
--		LOCKED					: out	std_logic
	);
end CLOCKGEN;

architecture RTL of CLOCKGEN is
	signal clkfx_buf			: std_logic := '0';
	signal clkfb_buf			: std_logic := '0';
	signal clk_4m				: std_logic := '1';
	signal ctr_even			: std_logic_vector(2 downto 0) := (others => '0');
	signal ctr_odd				: std_logic_vector(3 downto 0) := (others => '0');

	-- Input clock buffering
	signal clkin1				: std_logic := '0';
	-- Output clock buffering
	signal clkfb				: std_logic := '0';
	signal clk0					: std_logic := '0';
	signal clkfx				: std_logic := '0';
--	signal locked_internal	: std_logic := '0';
--	signal status_internal	: std_logic_vector(7 downto 0)  := (others => '0');
begin

--	STATUS <= status_internal;
--	LOCKED <= locked_internal;

--	O_CLK_32M <= clkin1;
	O_CLK_48M <= clkfx_buf;
	clkin1_buf	: IBUFG port map (I => I_CLK, O => clkin1);
	clkout1_buf	: BUFG  port map (I => clkfx, O => clkfx_buf);

	dcm_sp_inst: DCM_SP
	generic map(
		CLKFX_DIVIDE				=> C_CLKFX_DIVIDE  ,
		CLKFX_MULTIPLY				=> C_CLKFX_MULTIPLY,
		CLKIN_PERIOD				=> C_CLKIN_PERIOD

	)
	port map (
		-- Input clock
		CLKIN			=> clkin1,
		CLKFB			=> clkfb,
		-- Output clocks
		CLK0			=> clkfb,
		CLKFX			=> clkfx,
		-- Other control and status signals
--		LOCKED		=> locked_internal,
--		STATUS		=> status_internal,
		RST			=> I_RST
	);

	-- generate clocks
	--          ___         ___         ___
	--   4M ___/   \_______/   \_______/   \_
	--          ___     ___     ___     ___
	--   6M ___/   \___/   \___/   \___/   \_
	--        _   _   _   _   _   _   _   _   
	--  12M _/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_

	gen_clk : process(clkfx_buf, I_RST)
	begin
		if I_RST = '1' then
			ctr_odd  <= (others => '0');
			ctr_even <= (others => '0');
		elsif rising_edge(clkfx_buf) then
			ctr_even <= ctr_even + 1;
			if ctr_odd = x"b" then
				ctr_odd <= (others => '0');
			else
				ctr_odd <= ctr_odd + 1;
			end if;
		end if;
	end process gen_clk;
	-- generate 4Mhz clk enable
	O_CLK_4M <= ctr_odd(2);
	-- generate 6Mhz clk enable
	O_CLK_6M <= ctr_even(2);
	-- generate 12Mhz clk enable
	clk12m_bufg_inst : bufg  port map (I=>ctr_even(1), O=>O_CLK_12M);

end RTL;
