library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Top is
end TB_Top;

architecture Behavioral of TB_Top is
    component Top is
        Port (clk : in STD_LOGIC;
              reset : in STD_LOGIC;
              leds_4 : out STD_LOGIC_VECTOR (3 downto 0);
              botones : in STD_LOGIC_VECTOR (3 downto 0);
              selector : out STD_LOGIC_VECTOR (3 downto 0);
              segments : out STD_LOGIC_VECTOR (6 downto 0);
              leds_8 : out STD_LOGIC_VECTOR (7 downto 0);
              switches : in STD_LOGIC_VECTOR (3 downto 0)           
            );
    end component;

    signal clk, reset : STD_LOGIC := '0';
    signal leds_4, botones, selector, switches : STD_LOGIC_VECTOR (3 downto 0);
    signal segments : STD_LOGIC_VECTOR (6 downto 0);
    signal leds_8 : STD_LOGIC_VECTOR (7 downto 0);

    constant clk_period : time := 10 ns;
    constant wait_bot_conf : time := 10 ns; 
    constant wait_screen_time : time := 25 * clk_period;
    constant wait_before_presing : time := 4 * clk_period;

begin
    UUT: Top
        Port map (
            clk => clk,
            reset => reset,
            leds_4 => leds_4,
            botones => botones,
            selector => selector,
            segments => segments,
            leds_8 => leds_8,
            switches => switches
        );
    -- Clock generation
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- en vez de 5s vamos a hacer 10 ciclos de reloj
    -- Stimulus process

    reset_process : process
    begin
        -- hacemos reset
        reset <= '1';
        wait for 3 * clk_period;
        reset <= '0';
        wait;
    end process;

    stim_proc: process
    begin
        -- estado inicial de todas las señales
        botones <= (others => '0');
        switches <= (others => '0');
        wait for 5/2 * clk_period;
        -- empieza la simulación
        -- seleccionamos el número de jugadores
        switches <= "0011"; -- 3 jugadores
        wait for 4 * clk_period;
        botones(0) <= '1'; -- presionamos el botón de confirmación
        wait for wait_bot_conf;
        botones(0) <= '0';
        wait for wait_screen_time;
        -- extraemos el número de piedras
        wait for 30 * clk_period; -- tiempo para que elija el jugador 1 random
        switches <= "0011"; -- 3 piedra para el segundo jugador
        wait for 4 * clk_period;
        botones(0) <= '1'; -- presionamos el botón de confirmación
        wait for wait_bot_conf;
        botones(0) <= '0';
        wait for wait_screen_time;
        switches <= "0001"; -- 1 piedras para el tercer jugador
        wait for wait_before_presing;
        botones(0) <= '1'; -- presionamos el botón de confirmación
        wait for wait_bot_conf;
        botones(0) <= '0';
        wait for wait_screen_time;
        
        -- ponemos las apuestas de cada jugador
        switches <= "0111"; -- el primer jugador apuesta que hay 7 piedras en total
        wait for wait_before_presing;
        botones(0) <= '1'; -- presionamos el botón de confirmación
        wait for wait_bot_conf;
        botones(0) <= '0';
        wait for wait_screen_time;
        switches <= "1000"; -- el segundo jugador apuesta que hay 8 piedras en total
        wait for wait_before_presing;
        botones(0) <= '1'; -- presionamos el botón de confirmación
        wait for wait_bot_conf;
        botones(0) <= '0';
        wait for wait_screen_time;
        switches <= "0110"; -- el tercer jugador apuesta que hay 6 piedras en total (apuesta CORRECTA)
        wait for wait_before_presing;
        botones(0) <= '1'; -- presionamos el botón de confirmación
        wait for wait_bot_conf;
        botones(0) <= '0';
        wait for wait_screen_time;
        -- pasamos a comprobar si hay algún ganador
        wait for 40 * clk_period; -- tiene que dar tiempo a que pase por las 4 pantallas
        -- se comprueba si hay algún ganador 
        wait for 5 * clk_period;
        -- volvemos a empezar otra ronda
    end process;
end Behavioral;
