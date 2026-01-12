library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RNG_Generator is
    Port ( clk     : in  STD_LOGIC;
           reset   : in  STD_LOGIC; --Reset de la placa

           rng_out : out STD_LOGIC_VECTOR (5 downto 0));
end entity;


architecture Behavioral of RNG_Generator is
    signal counter : integer range 0 to 51 := 0;     -- %52 en el m.c.m. de 4 y 13
begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            rng_out <= (others => '0');
        elsif clk'event and clk = '1' then
            if counter = 51 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
            rng_out <= std_logic_vector(to_unsigned(counter, 6));
        end if;
    end process;
end Behavioral;