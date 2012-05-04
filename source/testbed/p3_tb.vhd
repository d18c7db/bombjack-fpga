library ieee;
use ieee.std_logic_1164.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity p3_tb is
end p3_tb;
 
architecture behavior of p3_tb is 
 
    -- component declaration for the unit under test (uut)
 
    component timing
    port(
         I_CLK_6M_EN : IN  std_logic;
         I_FLIP : IN  std_logic;
         I_CS_9A00_n : IN  std_logic;
         I_MEWR_n : IN  std_logic;
         I_AB : IN  std_logic;
         I_DB : IN  std_logic_vector(3 downto 0);
         O_SLOAD_n : OUT  std_logic;
         O_SLOAD : OUT  std_logic;
         O_SL1_n : OUT  std_logic;
         O_SL2_n : OUT  std_logic;
         O_SW_n : OUT  std_logic;
         O_SS : OUT  std_logic;
         O_HBL : OUT  std_logic;
         O_CONTROLDB_n : OUT  std_logic;
         O_CONTROLDA_n : OUT  std_logic;
         O_VPL_n : OUT  std_logic;
         O_CDL_n : OUT  std_logic;
         O_MDL_n : OUT  std_logic;
         O_SEL : OUT  std_logic;
         O_1V_r : OUT  std_logic;
         O_1V_n_r : OUT  std_logic;
         O_256H_r : OUT  std_logic;
         O_CMPBLK_n_r : OUT  std_logic;
         O_CMPBLK_n : OUT  std_logic;
         O_CMPBLK : OUT  std_logic;
         O_VBLANK_n : OUT  std_logic;
         O_VBLANK : OUT  std_logic;
         O_TVSYNC_n : OUT  std_logic;
         O_HSYNC_n : OUT  std_logic;
         O_1H : OUT  std_logic;
         O_2H : OUT  std_logic;
         O_4H : OUT  std_logic;
         O_8H : OUT  std_logic;
         O_16H : OUT  std_logic;
         O_32H : OUT  std_logic;
         O_64H : OUT  std_logic;
         O_128H : OUT  std_logic;
         O_256H_n : OUT  std_logic;
         O_8H_X : OUT  std_logic;
         O_16H_X : OUT  std_logic;
         O_32H_X : OUT  std_logic;
         O_64H_X : OUT  std_logic;
         O_128H_X : OUT  std_logic;
         O_1V_X : OUT  std_logic;
         O_2V_X : OUT  std_logic;
         O_4V_X : OUT  std_logic;
         O_8V_X : OUT  std_logic;
         O_16V_X : OUT  std_logic;
         O_32V_X : OUT  std_logic;
         O_64V_X : OUT  std_logic;
         O_128V_X : OUT  std_logic;
         O_VSYNC_n : OUT  std_logic
        );
    end component;
    

   --Inputs
   signal I_CLK_6M_EN : std_logic := '0';
   signal I_FLIP : std_logic := '0';
   signal I_CS_9A00_n : std_logic := '0';
   signal I_MEWR_n : std_logic := '0';
   signal I_AB : std_logic := '0';
   signal I_DB : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal O_SLOAD_n : std_logic;
   signal O_SLOAD : std_logic;
   signal O_SL1_n : std_logic;
   signal O_SL2_n : std_logic;
   signal O_SW_n : std_logic;
   signal O_SS : std_logic;
   signal O_HBL : std_logic;
   signal O_CONTROLDB_n : std_logic;
   signal O_CONTROLDA_n : std_logic;
   signal O_VPL_n : std_logic;
   signal O_CDL_n : std_logic;
   signal O_MDL_n : std_logic;
   signal O_SEL : std_logic;
   signal O_1V_r : std_logic;
   signal O_1V_n_r : std_logic;
   signal O_256H_r : std_logic;
   signal O_CMPBLK_n_r : std_logic;
   signal O_CMPBLK_n : std_logic;
   signal O_CMPBLK : std_logic;
   signal O_VBLANK_n : std_logic;
   signal O_VBLANK : std_logic;
   signal O_TVSYNC_n : std_logic;
   signal O_HSYNC_n : std_logic;
   signal O_1H : std_logic;
   signal O_2H : std_logic;
   signal O_4H : std_logic;
   signal O_8H : std_logic;
   signal O_16H : std_logic;
   signal O_32H : std_logic;
   signal O_64H : std_logic;
   signal O_128H : std_logic;
   signal O_256H_n : std_logic;
   signal O_8H_X : std_logic;
   signal O_16H_X : std_logic;
   signal O_32H_X : std_logic;
   signal O_64H_X : std_logic;
   signal O_128H_X : std_logic;
   signal O_1V_X : std_logic;
   signal O_2V_X : std_logic;
   signal O_4V_X : std_logic;
   signal O_8V_X : std_logic;
   signal O_16V_X : std_logic;
   signal O_32V_X : std_logic;
   signal O_64V_X : std_logic;
   signal O_128V_X : std_logic;
   signal O_VSYNC_n : std_logic;
   signal clock : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 166.666 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: timing PORT MAP (
          I_CLK_6M_EN => clock,
          I_FLIP => I_FLIP,
          I_CS_9A00_n => I_CS_9A00_n,
          I_MEWR_n => I_MEWR_n,
          I_AB => I_AB,
          I_DB => I_DB,
          O_SLOAD_n => O_SLOAD_n,
          O_SLOAD => O_SLOAD,
          O_SL1_n => O_SL1_n,
          O_SL2_n => O_SL2_n,
          O_SW_n => O_SW_n,
          O_SS => O_SS,
          O_HBL => O_HBL,
          O_CONTROLDB_n => O_CONTROLDB_n,
          O_CONTROLDA_n => O_CONTROLDA_n,
          O_VPL_n => O_VPL_n,
          O_CDL_n => O_CDL_n,
          O_MDL_n => O_MDL_n,
          O_SEL => O_SEL,
          O_1V_r => O_1V_r,
          O_1V_n_r => O_1V_n_r,
          O_256H_r => O_256H_r,
          O_CMPBLK_n_r => O_CMPBLK_n_r,
          O_CMPBLK_n => O_CMPBLK_n,
          O_CMPBLK => O_CMPBLK,
          O_VBLANK_n => O_VBLANK_n,
          O_VBLANK => O_VBLANK,
          O_TVSYNC_n => O_TVSYNC_n,
          O_HSYNC_n => O_HSYNC_n,
          O_1H => O_1H,
          O_2H => O_2H,
          O_4H => O_4H,
          O_8H => O_8H,
          O_16H => O_16H,
          O_32H => O_32H,
          O_64H => O_64H,
          O_128H => O_128H,
          O_256H_n => O_256H_n,
          O_8H_X => O_8H_X,
          O_16H_X => O_16H_X,
          O_32H_X => O_32H_X,
          O_64H_X => O_64H_X,
          O_128H_X => O_128H_X,
          O_1V_X => O_1V_X,
          O_2V_X => O_2V_X,
          O_4V_X => O_4V_X,
          O_8V_X => O_8V_X,
          O_16V_X => O_16V_X,
          O_32V_X => O_32V_X,
          O_64V_X => O_64V_X,
          O_128V_X => O_128V_X,
          O_VSYNC_n => O_VSYNC_n
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		I_FLIP		<= '1';
		I_CS_9A00_n <= '0';
		I_MEWR_n		<= '1';
		I_DB			<= x"0";

      wait for clock_period*10;

		I_AB			<= '0';
      wait until rising_edge(O_2V_X); I_DB <= x"0"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"1"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"2"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"3"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"4"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"5"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"6"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"7"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"8"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"9"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"a"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"b"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"c"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"d"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"e"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"f"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';

		I_AB			<= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"0"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"1"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"2"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"3"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"4"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"5"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"6"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"7"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"8"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"9"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"a"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"b"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"c"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"d"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"e"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"f"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';


		I_AB			<= '0';
      wait until rising_edge(O_2V_X); I_DB <= x"6"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';

		I_AB			<= '1';
      wait until rising_edge(O_2V_X); I_DB <= x"d"; wait until rising_edge(clock); I_MEWR_n <= '0'; wait until rising_edge(clock); I_MEWR_n <= '1';

		
      -- insert stimulus here 

      wait;
   end process;

END;
