library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Bloque3_Extended is
end TB_Bloque3_Extended;

architecture Behavioral of TB_Bloque3_Extended is

    -- Component Declaration for the Unit Under Test (UUT)
    component Bloque3 is
        port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            continue      : in  std_logic;
            confirm       : in  std_logic;
            switches      : in  std_logic_vector (3 downto 0);
            player_number : in  std_logic_vector (3 downto 0); -- "0010"(2), "0011"(3), "0100"(4)
            freqdiv_end   : in  std_logic;                     -- Pulso de fin de 5s
            round         : in  unsigned (7 downto 0); -- Ronda actual
            rng           : in  std_logic_vector (5 downto 0);
            
            freqdiv_reset : out std_logic;
            segments7     : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits
            leds          : out std_logic_vector (3 downto 0);  -- Barra de LEDs
            ap1           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J1
            ap2           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J2
            ap3           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J3
            ap4           : out std_logic_vector (3 downto 0);  -- Apuesta al registro J4

            end_inserting : out std_logic                       -- Fin de fase
        );
    end component;

    component Antirrebotes
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            boton    : in  std_logic;
            filtrado : out std_logic
        );
    end component;

    component DecoderControler is
        port(Input0  :   in  std_logic_vector(19 downto 0); --Seleccion nº de jugadores
             Input1  :   in  std_logic_vector(19 downto 0); --Seleccion nº de piedras
             Input2  :   in  std_logic_vector(19 downto 0); --Seleccion apuestas
             Input3  :   in  std_logic_vector(19 downto 0); --Resolución apuestas
             Input4  :   in  std_logic_vector(19 downto 0); --Fin de ronda
             Sel     :   in  std_logic_vector( 2 downto 0);
             Output0 :   out std_logic_vector( 6 downto 0);
             Output1 :   out std_logic_vector( 6 downto 0);
             Output2 :   out std_logic_vector( 6 downto 0);
             Output3 :   out std_logic_vector( 6 downto 0)
            );
    end component;

    component DecoderLeds is
        port(Input :   in  std_logic_vector(3 downto 0);
             Leds  :   out std_logic_vector(11 downto 0));
    end component;

    component Freqdiv is
        Port (clk    :  in  std_logic;
              reset  :  in  std_logic;
              Output :  out std_logic);
    end component;

    component RNG_Generator is
        Port (clk     : in  STD_LOGIC;
              reset   : in  STD_LOGIC; --Reset de la placa
              random_number : out STD_LOGIC_VECTOR (5 downto 0));
    end component;



    -- Signals to connect to UUT
    signal clk_tb           : std_logic := '0';
    signal reset_tb         : std_logic := '0';
    signal continue_tb      : std_logic := '0';
    signal continuePressed_tb : std_logic;
    signal confirm_tb       : std_logic := '0';
    signal confirmPressed_tb : std_logic;
    signal switches_tb      : std_logic_vector (3 downto 0);
    signal player_number_tb : std_logic_vector (3 downto 0);
    signal freqdiv_end_tb   : std_logic := '0';
    signal round_tb         : unsigned (7 downto 0);
    signal rng_tb           : std_logic_vector (5 downto 0);
    
    signal freqdiv_reset_tb : std_logic;
    signal segments7_tb     : std_logic_vector (19 downto 0);
    signal leds_tb          : std_logic_vector (3 downto 0);
    signal ap1_tb           : std_logic_vector (3 downto 0);
    signal ap2_tb           : std_logic_vector (3 downto 0);
    signal ap3_tb           : std_logic_vector (3 downto 0);
    signal ap4_tb           : std_logic_vector (3 downto 0);

    signal end_inserting_tb : std_logic;

    signal Output0_tb       : std_logic_vector(6 downto 0);
    signal Output1_tb       : std_logic_vector(6 downto 0);
    signal Output2_tb       : std_logic_vector(6 downto 0);
    signal Output3_tb       : std_logic_vector(6 downto 0);

    signal leds_output_tb   : std_logic_vector(11 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)

    Antirrebotes_Continue: Antirrebotes
        port map (
            clk        => clk_tb,
            reset      => reset_tb,
            boton      => continue_tb,
            filtrado   => continuePressed_tb
        );

    Antirrebotes_Confirm: Antirrebotes
        port map (
            clk        => clk_tb,
            reset      => reset_tb,
            boton      => confirm_tb,
            filtrado   => confirmPressed_tb
        );
        
    RNG_inst: RNG_Generator
        port map (
            clk           => clk_tb,
            reset         => '0',
            random_number => rng_tb
        );

    Freqdiv_inst: Freqdiv
        port map (
            clk    => clk_tb,
            reset  => freqdiv_reset_tb,
            Output => freqdiv_end_tb
        );

    DecoderControler_inst: DecoderControler
        port map (
            Input0  => (others => '1'),
            Input1  => (others => '1'),
            Input2  => segments7_tb,
            Input3  => (others => '1'),
            Input4  => (others => '1'),
            Sel     => "010",
            Output0 => Output0_tb,
            Output1 => Output1_tb,
            Output2 => Output2_tb,
            Output3 => Output3_tb
        );

    DecoderLeds_inst: DecoderLeds
        port map (
            Input => leds_tb ,
            Leds  => leds_output_tb
        );


    uut: Bloque3
        Port map (
            clk             => clk_tb,
            reset           => reset_tb,
            continue        => continuePressed_tb,
            confirm         => confirmPressed_tb,
            switches        => switches_tb,
            player_number   => player_number_tb,
            freqdiv_end     => freqdiv_end_tb,
            round           => round_tb,
            rng             => rng_tb,
            freqdiv_reset   => freqdiv_reset_tb,
            segments7       => segments7_tb,
            leds            => leds_tb,
            ap1             => ap1_tb,
            ap2             => ap2_tb,
            ap3             => ap3_tb,
            ap4             => ap4_tb,
            end_inserting   => end_inserting_tb
        );




    -- Clock generation process
    clk_process :process
    begin
        while true loop
            clk_tb <= '1';
            wait for clk_period / 2;
            clk_tb <= '0';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    tb : process
    begin       
        -- Reset the UUT
        reset_tb <= '1';
        wait for 28 ns;
        reset_tb <= '0';


        -- 2 PLAYERS
        player_number_tb <= "0010"; -- 2 players

        -- Round 0
        round_tb <= to_unsigned(0, 8);

        switches_tb <= "1101"; -- Apuesta 13

        wait for 30 ns;

        confirm_tb <= '1';
        wait for 1500 ns;
        confirm_tb <= '0';

        wait for 10 ns;

        continue_tb <= '1';
        wait for 1500 ns;
        continue_tb <= '0';


        switches_tb <= "0001"; -- Apuesta 1

        wait for 30 ns;

        confirm_tb <= '1';
        wait for 1500 ns;
        confirm_tb <= '0';

        wait for 10 ns;

        continue_tb <= '1';
        wait for 1500 ns;
        continue_tb <= '0';


        wait for 1500 ns;

        -- Round 1
        round_tb <= to_unsigned(1, 8);


        -- Reset the UUT
        reset_tb <= '1';
        wait for 28 ns;
        reset_tb <= '0';


        switches_tb <= "0100"; -- Apuesta 3

        wait for 30 ns;

        confirm_tb <= '1';
        wait for 150 ns;
        continue_tb <= '1';
        wait for 1500 ns;
        confirm_tb <= '0';
        wait for 150 ns;
        continue_tb <= '0';




        wait for 15 ns;
        round_tb <= to_unsigned(2, 8);









        wait;
    end process;

end Behavioral;

