library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DecoderControler is
    port(clk    :   in  std_logic;
         reset  :   in  std_logic;

         mensaje_in  : in  std_logic_vector(19 downto 0); 
         mensaje_out : out std_logic_vector( 6 downto 0);
         selector_7s : out std_logic_vector( 3 downto 0)
         );
end entity;

architecture behavoural of DecoderControler is
    
    component Decoder7s is
        port(BCD        :   in  std_logic_vector(4 downto 0);
             segments7  :   out std_logic_vector(6 downto 0));
    end component;
    signal counter : integer range 0 to 125000 := 0;
    signal Output0 :   std_logic_vector( 6 downto 0);
    signal Output1 :   std_logic_vector( 6 downto 0);
    signal Output2 :   std_logic_vector( 6 downto 0);
    signal Output3 :   std_logic_vector( 6 downto 0);
    signal selectors :   std_logic_vector( 3 downto 0);
    constant MAX_COUNT : integer := 125000; --quiero que tenga una tasa de refresco de 100Hz pero el reloj es de 125MHz
    
begin



Decoder3: Decoder7s
    port map(
        BCD => mensaje_in(19 downto 15),
        segments7  => Output3
    );
Decoder2: Decoder7s
    port map(
        BCD => mensaje_in(14 downto 10),
        segments7  => Output2
    );
Decoder1: Decoder7s
    port map(
        BCD => mensaje_in(9 downto 5),
        segments7  => Output1
    );
Decoder0: Decoder7s
    port map(
        BCD => mensaje_in(4 downto 0),
        segments7  => Output0
    );



process(clk)
begin
    if clk'event and clk = '1' then
        if reset = '1' then
            counter <= 0;
        else
            if counter = MAX_COUNT then
                counter <= 0;
                case Selectors is
                    when "0001" =>
                        mensaje_out <= Output0;
                        Selectors <= "0010";
                    when "0010" =>
                        mensaje_out <= Output1;
                        Selectors <= "0100";
                    when "0100" =>
                        mensaje_out <= Output2;
                        Selectors <= "1000";
                    when others =>
                        mensaje_out <= Output3;
                        Selectors <= "0001";
                end case;
            else
                counter <= counter + 1;
            end if;
        end if;
    end if;
end process;
selector_7s <= Selectors;


end architecture;