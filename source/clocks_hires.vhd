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
	port (
		I_CLK						: in	std_logic;
		I_RST						: in	std_logic;
		O_CLK_4M					: out	std_logic;
		O_CLK_6M					: out	std_logic;
		O_CLK_12M				: out	std_logic;
--		O_CLK_24M				: out	std_logic;
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
	signal clk_6m				: std_logic := '1';
	signal clk_12m				: std_logic := '1';
--	signal clk_24m				: std_logic := '1';
	signal counter				: std_logic_vector(2 downto 0) := (others => '0');
	signal counter1			: std_logic_vector(3 downto 0) := (others => '1');

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
	clkf_buf		: BUFG  port map (I => clk0,  O => clkfb);
	clkout1_buf	: BUFG  port map (I => clkfx, O => clkfx_buf);

	dcm_sp_inst: DCM_SP
	generic map(
		CLK_FEEDBACK				=> "1X",
		CLKDV_DIVIDE				=> 2.0,
		CLKFX_DIVIDE				=> 2,  -- 32Mhz / 2 = 16Mhz
		CLKFX_MULTIPLY				=> 3,  -- 16Mhz * 3 = 48Mhz
		CLKIN_DIVIDE_BY_2			=> FALSE,
		CLKIN_PERIOD				=> 31.25,
		CLKOUT_PHASE_SHIFT		=> "NONE",
		DESKEW_ADJUST				=> "SYSTEM_SYNCHRONOUS",
		DSS_MODE						=> "NONE",
		DFS_FREQUENCY_MODE		=> "LOW",	-- deprecated
		DLL_FREQUENCY_MODE		=> "LOW",	-- deprecated
		DUTY_CYCLE_CORRECTION	=> TRUE,		-- deprecated
		FACTORY_JF					=> x"C080",	-- deprecated
		PHASE_SHIFT					=> 0,
		STARTUP_WAIT				=> FALSE
	)
	port map (
		-- Input clock
		CLKIN			=> clkin1,
		CLKFB			=> clkfb,
		-- Output clocks
		CLK0			=> clk0,
		CLK90			=> open,
		CLK180		=> open,
		CLK270		=> open,
		CLK2X			=> open,
		CLK2X180		=> open,
		CLKFX			=> clkfx,
		CLKFX180		=> open,
		CLKDV			=> open,
		-- Ports for dynamic phase shift
		PSCLK			=> '0',
		PSEN			=> '0',
		PSINCDEC		=> '0',
		PSDONE		=> open,
		-- Other control and status signals
--		LOCKED		=> locked_internal,
--		STATUS		=> status_internal,
		RST			=> I_RST,
		-- Unused pin, tie low
		DSSEN			=> '0'
	);

	-- route clocks to global low skew connections

	clk4m_bufg_inst  : bufg  port map (i=>clk_4m,  o=>O_CLK_4M);
	clk6m_bufg_inst  : bufg  port map (i=>clk_6m,  o=>O_CLK_6M);
	clk12m_bufg_inst : bufg  port map (i=>clk_12m, o=>O_CLK_12M);
--	clk24m_bufg_inst : bufg  port map (i=>clk_24m, o=>O_CLK_24M);

	-- generate 4Mhz clk enable
	gen_clk : process(clkfx_buf, I_RST)
	begin
		if I_RST = '1' then
			counter1 <= (others => '1');
			counter <= (others => '0');
			clk_4m <= '1';
		elsif rising_edge(clkfx_buf) then
			counter <= counter - 1;
			if counter1 = "1010" then
				counter1 <= (others => '1');
				clk_4m <= not clk_4m;
			else
				counter1 <= counter1 - 1;
			end if;
		end if;
	end process gen_clk;

	-- generate 6Mhz clk enable
	clk_6m  <= counter(2);
	-- generate 12Mhz clk enable
	clk_12m <= counter(1);
	-- generate 24Mhz clk
--	clk_24m <= counter(0);
end RTL;
