-- Decoder7s.vhd: Módulo decodificador de 5 bits a 7 segmentos.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decoder7s is
    port(mensaje_in   :  in  std_logic_vector(4 downto 0);
         mensaje_out  :  out std_logic_vector(6 downto 0));
end entity;

architecture behavoural of Decoder7s is
begin
    with mensaje_in select
        mensaje_out <= "0000001" when "00000",  --0
                       "1001111" when "00001",  --1
                       "0010010" when "00010",  --2
                       "0000110" when "00011",  --3
                       "1001100" when "00100",  --4
                       "0100100" when "00101",  --5
                       "0100000" when "00110",  --6
                       "0001111" when "00111",  --7
                       "0000000" when "01000",  --8
                       "0001100" when "01001",  --9
                       "0001000" when "01010",  --A
                       "1100000" when "01011",  --b 
                       "0110001" when "01100",  --C
                       "1000010" when "01101",  --d
                       "0110000" when "01110",  --E
                       "0111000" when "01111",  --F

                       "1000011" when "10000",  --J
                       "1000001" when "10001",  --U
                       "0100000" when "10010",  --G
                       "1110111" when "10011",  --_
                       "1110010" when "10100",  --c
                       "1101000" when "10101",  --h
                       "0011000" when "10110",  --P
                       "1111001" when "10111",  --i
                       "1101010" when "11000",  --n
                       "1110010" when "11001",  --c
                       "1111111" when "11111",  --All segments off
                       "-------"  when others; --x
end architecture;
