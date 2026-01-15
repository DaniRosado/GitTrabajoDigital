library ieee;
use ieee.std_logic_1164.all;
use work.estados_pkg.all;

entity TB_DecoderControler is
end entity;

architecture behavoural of TB_DecoderControler is

    signal clk_tb     : std_logic := '0';
    signal reset_tb   : std_logic := '0';

    signal estado_in_tb  : estados;

    signal long_mensaje1_in_tb  : std_logic_vector(19 downto 0);
    signal long_mensaje2_in_tb  : std_logic_vector(19 downto 0);
    signal long_mensaje3_in_tb  : std_logic_vector(19 downto 0);
    signal long_mensaje4_in_tb  : std_logic_vector(19 downto 0);
    signal long_mensaje5_in_tb  : std_logic_vector(19 downto 0);

    signal segments_tb : std_logic_vector(6 downto 0);
    signal selector_tb : std_logic_vector(3 downto 0);
    component DecoderControler is
    port(clk    :   in  std_logic;
         reset  :   in  std_logic;

         estado_in  :   in  estados;

         long_mensaje1_in  : in  std_logic_vector(19 downto 0);
         long_mensaje2_in  : in  std_logic_vector(19 downto 0);
         long_mensaje3_in  : in  std_logic_vector(19 downto 0);
         long_mensaje4_in  : in  std_logic_vector(19 downto 0);
         long_mensaje5_in  : in  std_logic_vector(19 downto 0); 

         segments : out std_logic_vector( 6 downto 0);      -- Salida para el display de 7 segmentos
         selector : out std_logic_vector( 3 downto 0)       -- Selector para saber que 7s se va a actualizar
         );
    end component;
begin
    UUT: DecoderControler
        port map(
            clk     => clk_tb,
            reset   => reset_tb,
            estado_in => estado_in_tb,
            long_mensaje1_in => long_mensaje1_in_tb,
            long_mensaje2_in => long_mensaje2_in_tb,
            long_mensaje3_in => long_mensaje3_in_tb,
            long_mensaje4_in => long_mensaje4_in_tb,
            long_mensaje5_in => long_mensaje5_in_tb,
            segments => segments_tb,
            selector => selector_tb
        );

TB_process : process
begin
    long_mensaje1_in_tb <= "10000100011001010011"; -- "JUG_"
    long_mensaje2_in_tb <= "10100101010000011010"; -- "ch0 "
    long_mensaje3_in_tb <= "01010101100000111010"; -- "AP1 "
    long_mensaje4_in_tb <= "00010000110010000101"; -- "2345"
    long_mensaje5_in_tb <= "01111101111100000110"; -- "Fin6"



    wait for 50 ns;
    estado_in_tb <= SJug;
    wait for 2000 ns;
    estado_in_tb <= ExtPied;
    wait for 2000 ns;
    estado_in_tb <= IntrApuesta;
    wait for 2000 ns;
    estado_in_tb <= ResRonda;
    wait for 2000 ns;
    estado_in_tb <= FinJug;
    wait for 2000 ns;

    wait;
end process;

TB_clk_process : process
begin
    while true loop
        clk_tb <= '1';
        wait for 10 ns;
        clk_tb <= '0';
        wait for 10 ns;
    end loop;
end process;

end architecture;   