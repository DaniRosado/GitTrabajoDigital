library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DecoderControler is
    port(clk    :   in  std_logic;
         reset  :   in  std_logic;

         long_mensaje_in  : in  std_logic_vector(19 downto 0); 
         segments : out std_logic_vector( 6 downto 0);      -- Salida para el display de 7 segmentos
         selector : out std_logic_vector( 3 downto 0)       -- Selector para saber que 7s se va a actualizar
         );
end entity;

architecture behavoural of DecoderControler is
    
    component Decoder7s is
        port(mensaje_in        :   in  std_logic_vector(4 downto 0);
             mensaje_out  :   out std_logic_vector(6 downto 0));
    end component;

    signal   counter   : integer range 0 to 125000 := 0;
    constant MAX_COUNT : integer := 125000;

    signal text_7s_0   :   std_logic_vector( 6 downto 0);      -- Salida del 7s [0]
    signal text_7s_1   :   std_logic_vector( 6 downto 0);      -- Salida del 7s [1]
    signal text_7s_2   :   std_logic_vector( 6 downto 0);      -- Salida del 7s [2]
    signal text_7s_3   :   std_logic_vector( 6 downto 0);      -- Salida del 7s [3]
    signal selector_int : std_logic_vector( 3 downto 0);       -- Selector para saber que 7s se va a actualizar
    
begin

Decoder3: Decoder7s
    port map(
        mensaje_in => long_mensaje_in(19 downto 15),
        mensaje_out  => text_7s_3
    );
Decoder2: Decoder7s
    port map(
        mensaje_in => long_mensaje_in(14 downto 10),
        mensaje_out  => text_7s_2
    );
Decoder1: Decoder7s
    port map(
        mensaje_in => long_mensaje_in(9 downto 5),
        mensaje_out  => text_7s_1
    );
Decoder0: Decoder7s
    port map(
        mensaje_in => long_mensaje_in(4 downto 0),
        mensaje_out  => text_7s_0
    );



process(clk)
begin
    if clk'event and clk = '1' then
        if reset = '1' then
            counter <= 0;
        else
            if counter = MAX_COUNT then
                counter <= 0;
                case selector_int is
                    when "0001" =>                          --Actualizar 7s[1]
                        segments <= text_7s_0;
                        selector_int <= "0010";
                    when "0010" =>                          --Actualizar 7s[2]
                        segments <= text_7s_1;
                        selector_int <= "0100";
                    when "0100" =>                          --Actualizar 7s[3]
                        segments <= text_7s_2;
                        selector_int <= "1000";
                    when others =>                          --Actualizar 7s[0]
                        segments <= text_7s_3;
                        selector_int <= "0001";
                end case;
            else
                counter <= counter + 1;
            end if;
        end if;
    end if;
end process;
selector <= selector_int;


end architecture;