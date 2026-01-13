library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DecoderLeds is
    port(Input :   in  std_logic_vector(3 downto 0);
         Leds  :   out std_logic_vector(11 downto 0));
end entity;

architecture behavoural of DecoderLeds is
begin
    with Input select
        Leds <= "000000000000" when "0000",  --0
                "000000000001" when "0001",  --1
                "000000000011" when "0010",  --2
                "000000000111" when "0011",  --3
                "000000001111" when "0100",  --4
                "000000011111" when "0101",  --5
                "000000111111" when "0110",  --6
                "000001111111" when "0111",  --7
                "000011111111" when "1000",  --8
                "000111111111" when "1001",  --9
                "001111111111" when "1010",  --10
                "011111111111" when "1011",  --11
                "111111111111" when "1100",  --12
                "------------"  when others; --x
end architecture;