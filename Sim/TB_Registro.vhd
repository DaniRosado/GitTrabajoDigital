library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.estados_pkg.all;

entity TB_Registro is
end TB_Registro;

architecture behavior of TB_Registro is

    -- Component Declaration for the Unit Under Test (UUT)
    component Registro
        Port (clk : in STD_LOGIC;
                reset : in STD_LOGIC;

                estado_in : in estados;

                num_jug_in : in std_logic_vector (3 downto 0);
                num_jug_out : out std_logic_vector (3 downto 0);

                num_round_in  : in  std_logic;
                num_round_out : out unsigned(7 downto 0);

                NumPiedras1_in : in std_logic_vector (1 downto 0);
                NumPiedras2_in : in std_logic_vector (1 downto 0);
                NumPiedras3_in : in std_logic_vector (1 downto 0);
                NumPiedras4_in : in std_logic_vector (1 downto 0);

                NumPiedras1_out : out std_logic_vector (1 downto 0);
                NumPiedras2_out : out std_logic_vector (1 downto 0);
                NumPiedras3_out : out std_logic_vector (1 downto 0);
                NumPiedras4_out : out std_logic_vector (1 downto 0);

                Apuesta1_in : in std_logic_vector (3 downto 0);
                Apuesta2_in : in std_logic_vector (3 downto 0);
                Apuesta3_in : in std_logic_vector (3 downto 0);
                Apuesta4_in : in std_logic_vector (3 downto 0);

                Apuesta1_out : out std_logic_vector (3 downto 0);
                Apuesta2_out : out std_logic_vector (3 downto 0);
                Apuesta3_out : out std_logic_vector (3 downto 0);
                Apuesta4_out : out std_logic_vector (3 downto 0);

                Puntos1_in : in std_logic;
                Puntos2_in : in std_logic;
                Puntos3_in : in std_logic;
                Puntos4_in : in std_logic;

                Puntos1_out : out std_logic_vector (1 downto 0);
                Puntos2_out : out std_logic_vector (1 downto 0);
                Puntos3_out : out std_logic_vector (1 downto 0);
                Puntos4_out : out std_logic_vector (1 downto 0)
            );
            end component;

   --Inputs
   signal clk_tb : std_logic := '0';
   signal reset_tb : std_logic := '0';
   -- Clock period definition
   constant clk_period : time := 10 ns;


    signal estado_in_tb : estados;
    signal num_jug_in_tb, num_jug_out_tb: std_logic_vector (3 downto 0);
    signal num_round_in_tb : std_logic := '0';
    signal num_round_out_tb : unsigned(7 downto 0);
    signal NumPiedras1_in_tb, NumPiedras2_in_tb, NumPiedras3_in_tb, NumPiedras4_in_tb : std_logic_vector (1 downto 0);
    signal NumPiedras1_out_tb, NumPiedras2_out_tb, NumPiedras3_out_tb, NumPiedras4_out_tb : std_logic_vector (1 downto 0);
    signal Apuesta1_in_tb, Apuesta2_in_tb, Apuesta3_in_tb, Apuesta4_in_tb : std_logic_vector (3 downto 0);
    signal Apuesta1_out_tb, Apuesta2_out_tb, Apuesta3_out_tb, Apuesta4_out_tb : std_logic_vector (3 downto 0);
    signal Puntos1_in_tb, Puntos2_in_tb, Puntos3_in_tb, Puntos4_in_tb : std_logic;
    signal Puntos1_out_tb, Puntos2_out_tb, Puntos3_out_tb, Puntos4_out_tb : std_logic_vector (1 downto 0);

begin

 uut: Registro
    Port map (
          clk => clk_tb,
          reset => reset_tb,

          estado_in => estado_in_tb,

          num_jug_in => num_jug_in_tb,
          num_jug_out => num_jug_out_tb,

          num_round_in  => num_round_in_tb,
          num_round_out => num_round_out_tb,

          NumPiedras1_in => NumPiedras1_in_tb,
          NumPiedras2_in => NumPiedras2_in_tb,
          NumPiedras3_in => NumPiedras3_in_tb,
          NumPiedras4_in => NumPiedras4_in_tb,

          NumPiedras1_out => NumPiedras1_out_tb,
          NumPiedras2_out => NumPiedras2_out_tb,
          NumPiedras3_out => NumPiedras3_out_tb,
          NumPiedras4_out => NumPiedras4_out_tb,

          Apuesta1_in => Apuesta1_in_tb,
          Apuesta2_in => Apuesta2_in_tb,
          Apuesta3_in => Apuesta3_in_tb,
          Apuesta4_in => Apuesta4_in_tb,

          Apuesta1_out => Apuesta1_out_tb,
          Apuesta2_out => Apuesta2_out_tb,
          Apuesta3_out => Apuesta3_out_tb,
          Apuesta4_out => Apuesta4_out_tb,

          Puntos1_in => Puntos1_in_tb,
          Puntos2_in => Puntos2_in_tb,
          Puntos3_in => Puntos3_in_tb,
          Puntos4_in => Puntos4_in_tb,

          Puntos1_out => Puntos1_out_tb,
          Puntos2_out => Puntos2_out_tb,
          Puntos3_out => Puntos3_out_tb,
          Puntos4_out => Puntos4_out_tb
        );

   -- Clock process definitions
   clk_process :process
   begin
        clk_tb <= '1';
        wait for clk_period/2;
        clk_tb <= '0';
        wait for clk_period/2;
   end process;


    estimulating_process:process
    begin
        -- reset
        reset_tb <= '1';
        wait for clk_period*2;
        reset_tb <= '0';
        wait for clk_period*2;

        --Estado Selección de jugadores
        estado_in_tb <= SJug;

        num_jug_in_tb <= "0010";    -- 2 jugadores :)

        NumPiedras1_in_tb <= "00";  -- 0 piedras
        NumPiedras2_in_tb <= "01";  -- 1 piedras
        NumPiedras3_in_tb <= "10";  -- 2 piedras
        NumPiedras4_in_tb <= "11";  -- 3 piedras

        Apuesta1_in_tb <= "0001";
        Apuesta2_in_tb <= "0010";
        Apuesta3_in_tb <= "0100";
        Apuesta4_in_tb <= "1000";

        Puntos1_in_tb <= '1';
        Puntos2_in_tb <= '1';
        Puntos3_in_tb <= '1';
        Puntos4_in_tb <= '1';

        wait for clk_period*10;

        --Estado Extracción de piedras
        estado_in_tb <= ExtPied;

        num_jug_in_tb <= "0011";

        NumPiedras1_in_tb <= "01";
        NumPiedras2_in_tb <= "10";
        NumPiedras3_in_tb <= "11";
        NumPiedras4_in_tb <= "00";

        Apuesta1_in_tb <= "0010";
        Apuesta2_in_tb <= "0100";
        Apuesta3_in_tb <= "1000";
        Apuesta4_in_tb <= "0001";

        Puntos1_in_tb <= '1';
        Puntos2_in_tb <= '1';
        Puntos3_in_tb <= '1';
        Puntos4_in_tb <= '1';

        wait for clk_period*10;

        --Estado Introducción de apuestas
        estado_in_tb <= IntrApuesta;

        num_jug_in_tb <= "0100";

        NumPiedras1_in_tb <= "10";
        NumPiedras2_in_tb <= "11";
        NumPiedras3_in_tb <= "00";
        NumPiedras4_in_tb <= "01";

        Apuesta1_in_tb <= "0100";
        Apuesta2_in_tb <= "1000";
        Apuesta3_in_tb <= "0001";
        Apuesta4_in_tb <= "0010";

        Puntos1_in_tb <= '1';
        Puntos2_in_tb <= '1';
        Puntos3_in_tb <= '1';
        Puntos4_in_tb <= '1';

        wait for clk_period*10;

        --Estado Resolución de ronda
        estado_in_tb <= ResRonda;

        num_jug_in_tb <= "0100";

        NumPiedras1_in_tb <= "11";
        NumPiedras2_in_tb <= "00";
        NumPiedras3_in_tb <= "01";
        NumPiedras4_in_tb <= "10";

        Apuesta1_in_tb <= "1000";
        Apuesta2_in_tb <= "0001";
        Apuesta3_in_tb <= "0010";
        Apuesta4_in_tb <= "0100";

        Puntos1_in_tb <= '1';
        Puntos2_in_tb <= '1';
        Puntos3_in_tb <= '1';
        Puntos4_in_tb <= '1';

        wait for clk_period*10;

        --Estado Fin Juego
        estado_in_tb <= FinJug;

        num_jug_in_tb <= "0100";

        NumPiedras1_in_tb <= "00";
        NumPiedras2_in_tb <= "01";
        NumPiedras3_in_tb <= "10";
        NumPiedras4_in_tb <= "11";

        Apuesta1_in_tb <= "0001";
        Apuesta2_in_tb <= "0010";
        Apuesta3_in_tb <= "0100";
        Apuesta4_in_tb <= "1000";

        Puntos1_in_tb <= '1';
        Puntos2_in_tb <= '1';
        Puntos3_in_tb <= '1';
        Puntos4_in_tb <= '1';

        wait for clk_period*10;
        num_round_in_tb <= '1';
        wait for clk_period;
        num_round_in_tb <= '0';

        wait for clk_period*5;

        num_round_in_tb <= '1';
        wait for clk_period*2;
        num_round_in_tb <= '0';

        wait for clk_period*5;

        num_round_in_tb <= '1';
        wait for clk_period*3;
        num_round_in_tb <= '0';

        wait;
    end process;

end architecture;