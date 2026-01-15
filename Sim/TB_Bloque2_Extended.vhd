library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Bloque2_Extended is
end TB_Bloque2_Extended;

architecture Behavioral of TB_Bloque2_Extended is

    -- Component Declaration for the Unit Under Test (UUT)
    component Bloque2 is
        port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            NUM_JUGADORES : in  std_logic_vector (3 downto 0); -- "0010"(2), "0011"(3), "0100"(4)
            NUM_RONDA     : in  unsigned (7 downto 0); -- Ronda actual
            ALEATORIO_IN  : in  std_logic_vector (5 downto 0);
            SWITCHES      : in  std_logic_vector (3 downto 0);
            BTN_CONFIRM   : in  std_logic;
            BTN_CONTINUAR : in  std_logic;
            freqdiv_end   : in  std_logic; -- Pulso de fin de 5s                   
            freqdiv_reset : out std_logic; 
            segments7     : out std_logic_vector (19 downto 0); -- 4 dígitos x 5 bits
            PIEDRAS_P1    : out std_logic_vector (3 downto 0);
            PIEDRAS_P2    : out std_logic_vector (3 downto 0);
            PIEDRAS_P3    : out std_logic_vector (3 downto 0);
            PIEDRAS_P4    : out std_logic_vector (3 downto 0);
            FIN_FASE      : out std_logic -- Fin de fase
        );
    end component;

    component Antirrebotes
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            boton    : in  std_logic;
            filtrado : out std_logic
        );
    end component;

    component Freqdiv is
        Port (
            clk    :  in  std_logic;
            reset  :  in  std_logic;
            Output :  out std_logic
        );
    end component;

    component RNG is
        Port (
            clk           : in  STD_LOGIC;
            reset         : in  STD_LOGIC; --Reset de la placa
            random_number : out STD_LOGIC_VECTOR (5 downto 0)
        );
    end component;

    -- Signals to connect to UUT
    signal clk_tb           : std_logic := '0';
    signal reset_tb         : std_logic := '0';
    
    signal NUM_JUGADORES_tb : std_logic_vector (3 downto 0) := "0010";
    signal NUM_RONDA_tb     : unsigned (7 downto 0) := (others => '0');
    
    signal btn_confirm_raw    : std_logic := '0';
    signal btn_confirm_filt   : std_logic;
    signal btn_continue_raw   : std_logic := '0';
    signal btn_continue_filt  : std_logic;
    
    signal switches_tb      : std_logic_vector (3 downto 0) := (others => '0');
    
    signal rng_out_tb       : std_logic_vector (5 downto 0);
    signal freqdiv_end_tb   : std_logic;
    signal freqdiv_reset_tb : std_logic; -- Controlado por Bloque2

    signal segments7_tb     : std_logic_vector (19 downto 0);
    signal PIEDRAS_P1_tb    : std_logic_vector (3 downto 0);
    signal PIEDRAS_P2_tb    : std_logic_vector (3 downto 0);
    signal PIEDRAS_P3_tb    : std_logic_vector (3 downto 0);
    signal PIEDRAS_P4_tb    : std_logic_vector (3 downto 0);
    signal FIN_FASE_tb      : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)

    RNG_inst: RNG
        port map (
            clk           => clk_tb,
            reset         => '0', 
            random_number => rng_out_tb
        );

    Freqdiv_inst: Freqdiv
        port map (
            clk    => clk_tb,
            reset  => freqdiv_reset_tb, 
            Output => freqdiv_end_tb
        );

    Antirrebotes_Confirm: Antirrebotes
        port map (
            clk      => clk_tb,
            reset    => reset_tb,
            boton    => btn_confirm_raw,
            filtrado => btn_confirm_filt
        );

    Antirrebotes_Continue: Antirrebotes
        port map (
            clk      => clk_tb,
            reset    => reset_tb,
            boton    => btn_continue_raw,
            filtrado => btn_continue_filt
        );


    uut: Bloque2
        port map (
            clk           => clk_tb,
            reset         => reset_tb,
            NUM_JUGADORES => NUM_JUGADORES_tb,
            NUM_RONDA     => NUM_RONDA_tb,
            ALEATORIO_IN  => rng_out_tb,    
            SWITCHES      => switches_tb,
            BTN_CONFIRM   => btn_confirm_filt,  
            BTN_CONTINUAR => btn_continue_filt, 
            freqdiv_end   => freqdiv_end_tb,    
            freqdiv_reset => freqdiv_reset_tb,
            segments7     => segments7_tb,
            PIEDRAS_P1    => PIEDRAS_P1_tb,
            PIEDRAS_P2    => PIEDRAS_P2_tb,
            PIEDRAS_P3    => PIEDRAS_P3_tb,
            PIEDRAS_P4    => PIEDRAS_P4_tb,
            FIN_FASE      => FIN_FASE_tb
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
        wait for 100 ns;
        reset_tb <= '0';
        wait for 100 ns;


   
        -- 2 PLAYERS
        NUM_JUGADORES_tb <= "0010"; -- 2 players

        -- Round 0
        NUM_RONDA_tb     <= to_unsigned(0, 8); 

        wait for 200 ns;


        -- Apuesta J1
        btn_continue_raw <= '1'; 
        wait for 1500 ns; 
        btn_continue_raw <= '0';
        wait for 200 ns;

        
        switches_tb <= "0000"; -- Apuesta 0 (J2)
        wait for 50 ns;
        
        btn_confirm_raw <= '1'; -- Confirmar apuesta J2
        wait for 1500 ns;
        btn_confirm_raw <= '0';
        
        wait for 500 ns; -- Error apuesta 0 en ronda 0


        switches_tb <= "0001"; -- Apuesta 1 (J2)
        wait for 50 ns;
        
        btn_confirm_raw <= '1'; -- Confirmar apuesta J2
        wait for 1500 ns;
        btn_confirm_raw <= '0';
        wait for 100 ns;

        btn_continue_raw <= '1'; -- Continuar tras apuesta J2
        wait for 1500 ns;
        btn_continue_raw <= '0';
        
        wait for 200 ns; -- Fin ronda 0


        -- Round 1
        NUM_RONDA_tb     <= to_unsigned(1, 8); 
        
        wait for 200 ns; 


        -- Apuesta J1
        btn_continue_raw <= '1'; 
        wait for 1500 ns; 
        btn_continue_raw <= '0';
        wait for 200 ns;


        switches_tb <= "0010"; -- Apuesta 2 (J2)
        wait for 50 ns;
        
        btn_confirm_raw <= '1'; -- Confirmar apuesta J2
        wait for 1500 ns;
        btn_confirm_raw <= '0';
        wait for 100 ns;

        btn_continue_raw <= '1'; -- Continuar tras apuesta J2
        wait for 1500 ns;
        btn_continue_raw <= '0';
        
        wait for 200 ns;



       -- 3 PLAYERS
        reset_tb <= '1';
        wait for 50 ns;
        reset_tb <= '0';
        
        NUM_JUGADORES_tb <= "0011"; -- 3 players

        -- Round 2
        NUM_RONDA_tb     <= to_unsigned(2, 8);
        wait for 100 ns;


        -- Apuesta J1
        btn_continue_raw <= '1';
        wait for 1500 ns;
        btn_continue_raw <= '0';
        wait for 200 ns;


        switches_tb <= "0011"; -- Apuesta 3 (J2)
        wait for 50 ns;

        btn_confirm_raw <= '1'; -- Confirmar apuesta J2
        wait for 1500 ns;
        btn_confirm_raw <= '0';
        wait for 100 ns;
        
        btn_continue_raw <= '1'; -- Continuar tras apuesta J2
        wait for 1500 ns;
        btn_continue_raw <= '0';
        wait for 200 ns;


        switches_tb <= "0001"; -- Apuesta 1 (J3)
        wait for 50 ns;

        btn_confirm_raw <= '1'; -- Confirmar apuesta J3
        wait for 1500 ns;
        btn_confirm_raw <= '0';
        wait for 100 ns;

        btn_continue_raw <= '1'; -- Continuar tras apuesta J3
        wait for 1500 ns;
        btn_continue_raw <= '0';
        
        wait for 200 ns; 



        -- 4 PLAYERS
        reset_tb <= '1';
        wait for 50 ns;
        reset_tb <= '0';

        NUM_JUGADORES_tb <= "0100"; -- 4 players

        -- Round 3
        NUM_RONDA_tb     <= to_unsigned(3, 8);
        wait for 100 ns;


        -- Apuesta J1
        btn_continue_raw <= '1'; 
        wait for 1500 ns; 
        btn_continue_raw <= '0'; 
        wait for 200 ns; 


        switches_tb <= "0000"; -- Apuesta 0 (J2)
        wait for 50 ns; 

        btn_confirm_raw <= '1'; -- Confirmar apuesta J2
        wait for 1500 ns; 
        btn_confirm_raw <= '0'; 
        wait for 100 ns;

        btn_continue_raw <= '1'; -- Continuar tras apuesta J2
        wait for 1500 ns; 
        btn_continue_raw <= '0'; 

        wait for 200 ns;


        switches_tb <= "0011"; -- Apuesta 3 (J3)
        wait for 50 ns;

        btn_confirm_raw <= '1'; -- Confirmar apuesta J3
        wait for 1500 ns; 
        btn_confirm_raw <= '0'; 
        wait for 100 ns;

        btn_continue_raw <= '1'; -- Continuar tras apuesta J3
        wait for 1500 ns; 
        btn_continue_raw <= '0';
         
        wait for 200 ns;


        switches_tb <= "0010"; -- Apuesta 2 (J4)
        wait for 50 ns;

        btn_confirm_raw <= '1'; -- Confirmar apuesta J4
        wait for 1500 ns; 
        btn_confirm_raw <= '0'; 
        wait for 100 ns;

        btn_continue_raw <= '1'; -- Continuar tras apuesta J4
        wait for 1500 ns; 
        btn_continue_raw <= '0'; 

        wait for 200 ns;


        wait;
    end process;

end Behavioral;