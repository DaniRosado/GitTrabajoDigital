library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Bloque2 is
end entity;

architecture Behavioral of TB_Bloque2 is

    -- Component Declaration for the Unit Under Test (UUT)
    component Bloque2
        port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            
            num_jug : in  std_logic_vector (3 downto 0);  -- "0010"(2), "0011"(3), "0100"(4)
            num_ronda     : in  unsigned (7 downto 0);          -- Ronda actual
            rng_in  : in  std_logic_vector (5 downto 0);

            switches      : in  std_logic_vector (3 downto 0);
            btn_continue : in  std_logic;
            btn_confirm   : in  std_logic;

            fdiv_fin   : in  std_logic;                     
            fdiv_reset : out std_logic;

            segments7     : out std_logic_vector (19 downto 0);

            R_NumPiedras1           : out std_logic_vector (1 downto 0);
            R_NumPiedras2           : out std_logic_vector (1 downto 0); 
            R_NumPiedras3           : out std_logic_vector (1 downto 0); 
            R_NumPiedras4           : out std_logic_vector (1 downto 0); 

            fin_fase : out std_logic
        );
    end component;


    constant clk_period : time := 10 ns;

    -- Signals to connect to UUT
    signal clk_tb           : std_logic;
    signal reset_tb         : std_logic;
    
    signal num_jug_tb : std_logic_vector (3 downto 0);  -- "0010"(2), "0011"(3), "0100"(4)
    signal num_ronda_tb     : unsigned (7 downto 0);          -- Ronda actual
    signal rng_tb  : std_logic_vector (5 downto 0);

    signal switches_tb      : std_logic_vector (3 downto 0);
    signal btn_continue_tb : std_logic;
    signal btn_confirm_tb   : std_logic;

    signal fdiv_fin_tb   : std_logic;                     
    signal fdiv_reset_tb : std_logic;

    signal segments7_tb     : std_logic_vector (19 downto 0);

    signal R_NumPiedras1_tb           : std_logic_vector (1 downto 0);
    signal R_NumPiedras2_tb           : std_logic_vector (1 downto 0); 
    signal R_NumPiedras3_tb           : std_logic_vector (1 downto 0); 
    signal R_NumPiedras4_tb           : std_logic_vector (1 downto 0);

    signal fin_fase_tb : std_logic;

begin

    clk_process :process
    begin
        clk_tb <= '1';
        wait for clk_period/2;
        clk_tb <= '0';
        wait for clk_period/2;
    end process;


    uut: Bloque2
        port map (
                clk     => clk_tb,         
                reset   => reset_tb,       
                
                num_jug     => num_jug_tb,
                num_ronda   => num_ronda_tb,
                rng_in      => rng_tb,

                switches        => switches_tb,
                btn_confirm     => btn_confirm_tb,
                btn_continue    => btn_continue_tb,

                fdiv_fin    => fdiv_fin_tb,                 
                fdiv_reset  => fdiv_reset_tb,

                segments7   => segments7_tb,

                R_NumPiedras1   => R_NumPiedras1_tb,
                R_NumPiedras2   => R_NumPiedras2_tb,
                R_NumPiedras3   => R_NumPiedras3_tb,
                R_NumPiedras4   => R_NumPiedras4_tb,

                fin_fase    => fin_fase_tb
        );



    tb : process
    begin
        -- Reset the UUT
        reset_tb <= '1';
        wait for clk_period * 2.5;
        reset_tb <= '0';

                    --------------------
                    -- 2 PLAYERS TEST --
                    --------------------

        num_jug_tb <= "0010"; -- 2 players

        --############### Round 0 ###############--

        num_ronda_tb <= to_unsigned(0, 8);

        rng_tb <= "000101";    --RNG=5  [Bet of 1]  [R0:P1]

        wait for clk_period * 50;

        fdiv_fin_tb <= '1';          -- End of 5s
        wait for clk_period;
        fdiv_fin_tb <= '0';
        wait for clk_period * 10;

        --------------------------------------------

        switches_tb <= "0111";          -- 7 [Bet of 7] [R0:P2]

        wait for clk_period*10;

        btn_confirm_tb <= '1';          -- Press confirm
        wait for clk_period;
        btn_confirm_tb <= '0';


        wait for clk_period * 50;

        fdiv_fin_tb <= '1';          -- End of 5s
        wait for clk_period;
        fdiv_fin_tb <= '0';
        wait for clk_period * 10;

        --------------------------------------------

        switches_tb <= "0011";          -- [Bet of 3]   [R0:P2]

        wait for clk_period*10;

        btn_confirm_tb <= '1';          -- Press confirm
        wait for clk_period;
        btn_confirm_tb <= '0';


        wait for clk_period * 50;

        fdiv_fin_tb <= '1';          -- End of 5s
        wait for clk_period;
        fdiv_fin_tb <= '0';
        wait for clk_period * 10;

        --------------------------------------------


        --############### Round 1 ###############--
        num_ronda_tb <= to_unsigned(1, 8);
        wait for clk_period * 2;

        -- Reset the UUT
        reset_tb <= '1';
        wait for clk_period * 2.5;
        reset_tb <= '0';

        --------------------------------------------

        rng_tb <= "000110";    -- RNG=6 [Bet of 2]   [R1:P1]
    
        wait for clk_period*50;

        fdiv_fin_tb <= '1';      -- End of 5s
        wait for clk_period;
        fdiv_fin_tb <= '0';
        wait for clk_period * 10;
        --------------------------------------------

        switches_tb <= "0000";    -- [Bet of 0]   [R1:P2]

        wait for clk_period*10;

        btn_confirm_tb <= '1';     -- Press confirm
        wait for clk_period;
        btn_confirm_tb <= '0';

        wait for clk_period * 50;

        fdiv_fin_tb <= '1';      -- End of 5s
        wait for clk_period;
        fdiv_fin_tb <= '0';

        --------------------------------------------

        --############### Round 2 ###############--
        num_ronda_tb <= to_unsigned(2, 8);
        wait for clk_period * 2;

        -- Reset the UUT
        reset_tb <= '1';
        wait for clk_period;
        rng_tb <= "010001";    -- RNG=17 [Bet of 1]   [R2:P1]
        reset_tb <= '0';



        rng_tb <= "010001";    -- RNG=17 [Bet of 1]   [R2:P1]


        wait for clk_period * 50;

        fdiv_fin_tb <= '1';      -- End of 5s
        wait for clk_period;
        fdiv_fin_tb <= '0';
        wait for clk_period * 100;

        --------------------------------------------

        switches_tb <= "0010";    -- [Bet of 2]   [R2:P2]

        wait for clk_period*10;

        btn_confirm_tb <= '1';     -- Press confirm
        wait for clk_period;
        btn_confirm_tb <= '0';
    
        wait for clk_period * 50;

        fdiv_fin_tb <= '1';      -- End of 5s
        wait for clk_period;
        fdiv_fin_tb <= '0';
        wait for clk_period * 10;

        --------------------------------------------

        -- Finish simulation
        wait;
    end process;

end architecture;