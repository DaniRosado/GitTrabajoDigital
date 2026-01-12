library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Freqdiv is
    Port (clk    :  in  std_logic;
          reset  :  in  std_logic;
          
          freqdiv_out :  out std_logic);
end Freqdiv;

architecture Behavioral of Freqdiv is

    constant max_count : integer := 5*125000000/1000000 -1;
    --constant max_count : integer := 20; -- Para simulación rápida
    signal counter : integer range 0 to max_count := 0 ;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            freqdiv_out <= '0';
        elsif clk'event and clk = '1' then
            if counter < max_count -1 then
                counter <= counter + 1;
                freqdiv_out <= '0';
            else
                counter <= 0;
                freqdiv_out <= '1';
            end if;
        end if;
    end process;
end Behavioral;