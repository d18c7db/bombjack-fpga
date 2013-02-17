--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:53:49 07/05/2011
-- Design Name:   
-- Module Name:   C:/Users/alex/workspace/spi/u_flash_tb.vhd
-- Project Name:  spi
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SPI_FLASH
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY spi_flash_tb IS
END spi_flash_tb;
 
ARCHITECTURE behavior OF spi_flash_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT SPI_FLASH
	port (
		O_FLASH_CK		: out std_logic;
		O_FLASH_CS		: out std_logic;
		O_FLASH_SI		: out std_logic;
		O_FLASH_DONE	: out std_logic := '1';
		O_FLASH_DATA	: out std_logic_vector ( 7 downto 0) := (others => '0');
		I_FLASH_SO		: in  std_logic := '0';
		I_FLASH_CLK		: in  std_logic := '0';
		I_FLASH_INIT	: in  std_logic := '0';
		I_FLASH_ADDR	: in  std_logic_vector (23 downto 0) := (others => '0')
	);
	END COMPONENT;
    

   --Inputs
   signal I_FLASH_SO : std_logic := '0';
   signal flash_clk : std_logic := '0';
   signal flash_init : std_logic := '0';
   signal flash_addr : std_logic_vector(23 downto 0) := (others => '0');

 	--Outputs
   signal O_FLASH_CK : std_logic;
   signal O_FLASH_CS : std_logic;
   signal O_FLASH_SI : std_logic;
   signal flash_data : std_logic_vector(7 downto 0);
   signal flash_done : std_logic;

   -- Clock period definitions
   constant flash_clk_period : time := 12.5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI_FLASH PORT MAP (
          O_FLASH_CK   => O_FLASH_CK,
          O_FLASH_CS   => O_FLASH_CS,
          O_FLASH_SI   => O_FLASH_SI,
          I_FLASH_SO   => I_FLASH_SO,
          I_FLASH_CLK  => flash_clk,
          I_FLASH_INIT => flash_init,
          I_FLASH_ADDR => flash_addr,
          O_FLASH_DATA => flash_data,
          O_FLASH_DONE => flash_done
        );

   -- Clock process definitions
   flash_clk_process :process
   begin
		flash_clk <= '0';
		wait for flash_clk_period/2;
		flash_clk <= '1';
		wait for flash_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		

		wait until rising_edge(flash_clk);

		flash_addr <= x"c0ffee";

		wait until rising_edge(flash_clk);

		flash_init <= '1';
		I_FLASH_SO <= '1';
      wait;
   end process;

END;
