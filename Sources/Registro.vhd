library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Estados_pkg.all;

entity Registro is
    Port (clk : in STD_LOGIC;
          reset : in STD_LOGIC;

          estado_in : in estados;

          num_jug_in : in std_logic_vector (3 downto 0);
          num_jug_out : out std_logic_vector (3 downto 0);

          num_round_in  : in  std_logic;
          num_round_out : out std_logic_vector (7 downto 0);

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
end entity;

architecture Behavioral of Registro is

    signal num_jug_reg : std_logic_vector (3 downto 0);
    signal num_round_reg : unsigned (7 downto 0);
    signal NumPiedras1_reg, NumPiedras2_reg, NumPiedras3_reg, NumPiedras4_reg : std_logic_vector (1 downto 0);
    signal Apuesta1_reg, Apuesta2_reg, Apuesta3_reg, Apuesta4_reg : std_logic_vector (3 downto 0);
    signal Puntos1_reg, Puntos2_reg, Puntos3_reg, Puntos4_reg : unsigned (1 downto 0);
begin

    num_jug_out <= num_jug_reg;
    num_round_out <= num_round_reg;

    Apuesta1_out <= Apuesta1_reg;
    Apuesta2_out <= Apuesta2_reg;
    Apuesta3_out <= Apuesta3_reg;
    Apuesta4_out <= Apuesta4_reg;

    NumPiedras1_out <= NumPiedras1_reg;
    NumPiedras2_out <= NumPiedras2_reg;
    NumPiedras3_out <= NumPiedras3_reg;
    NumPiedras4_out <= NumPiedras4_reg;

    Puntos1_out <= Puntos1_reg;
    Puntos2_out <= Puntos2_reg;
    Puntos3_out <= Puntos3_reg;
    Puntos4_out <= Puntos4_reg;

    with estado_in select
        num_jug_reg <= num_jug_in when SJug,
                       num_jug_reg when others;

    with estado_in select
        num_round_reg <= num_round_reg + 1 when SJug,
                         num_round_reg when others;

    with estado_in select
        NumPiedras1_reg <= NumPiedras1_in when ExtPied,
                           NumPiedras1_reg when others;
    with estado_in select
        NumPiedras2_reg <= NumPiedras2_in when ExtPied,
                           NumPiedras2_reg when others; 
    with estado_in select
        NumPiedras3_reg <= NumPiedras3_in when ExtPied,
                           NumPiedras3_reg when others; 
    with estado_in select
        NumPiedras4_reg <= NumPiedras4_in when ExtPied,
                           NumPiedras4_reg when others; 





end architecture;