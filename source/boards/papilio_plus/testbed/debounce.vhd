library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity debounce is
  generic (
    G_WIDTH           : in    integer
    );
  port (
    I_BUTTON          : in    std_logic_vector(G_WIDTH-1 downto 0); -- active high
    O_BUTTON          : out   std_logic_vector(G_WIDTH-1 downto 0);
    CLK               : in    std_logic
    );
end;

architecture RTL of debounce is

  signal tick_counter : std_logic_vector(12 downto 0);
  signal button       : std_logic_vector(G_WIDTH-1 downto 0);
begin

  p_debounce : process
    variable tick : boolean;
  begin
    wait until rising_edge(CLK);
    tick := (tick_counter(12) = '1');
    -- pragma translate_off
    -- synopsys translate_off
    tick := true;
    -- synopsys translate_on
    -- pragma translate_on
    if tick then
      tick_counter <= '0' & x"FFE";
    else
      tick_counter <= tick_counter - "1";
    end if;
    -- tick approx 1.5KHz

    for i in 0 to G_WIDTH-1 loop
      if (I_BUTTON(i) = '1') then
        button(i) <= '1';
      elsif tick then
        button(i) <= '0';
      end if;
    end loop;
  end process;

  O_BUTTON <= button;

end architecture RTL;
