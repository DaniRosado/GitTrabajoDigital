library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Estados_pkg.all;

entity Registro is
    Port (clk : in STD_LOGIC;
          reset : in STD_LOGIC;

          estado_in : in estados;

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

          Puntos1_out : out std_logic;
          Puntos2_out : out std_logic;
          Puntos3_out : out std_logic;
          Puntos4_out : out std_logic);
end entity;

