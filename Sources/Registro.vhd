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

    Puntos1_out <= std_logic_vector(Puntos1_reg);
    Puntos2_out <= std_logic_vector(Puntos2_reg);
    Puntos3_out <= std_logic_vector(Puntos3_reg);
    Puntos4_out <= std_logic_vector(Puntos4_reg);

    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                num_jug_reg <= (others => '0');
                num_round_reg <= (others => '0');


                NumPiedras1_reg <= (others => '-');
                NumPiedras2_reg <= (others => '-');
                NumPiedras3_reg <= (others => '-');
                NumPiedras4_reg <= (others => '-');

                Apuesta1_reg <= (others => '-');
                Apuesta2_reg <= (others => '-');
                Apuesta3_reg <= (others => '-');
                Apuesta4_reg <= (others => '-');

                Puntos1_reg <= (others => '0');
                Puntos2_reg <= (others => '0');
                Puntos3_reg <= (others => '0');
                Puntos4_reg <= (others => '0');
            else
                case estado_in is
                    when SJug =>
                        num_jug_reg <= num_jug_in;
                    when ExtPied =>
                        NumPiedras1_reg <= NumPiedras1_in;
                        NumPiedras2_reg <= NumPiedras2_in;
                        NumPiedras3_reg <= NumPiedras3_in;
                        NumPiedras4_reg <= NumPiedras4_in;
                    when IntrApuesta =>
                        Apuesta1_reg <= Apuesta1_in;
                        Apuesta2_reg <= Apuesta2_in;
                        Apuesta3_reg <= Apuesta3_in;
                        Apuesta4_reg <= Apuesta4_in;
                    when ResRonda =>
                        if Puntos1_in = '1' then Puntos1_reg <= Puntos1_reg + 1; end if;
                        if Puntos2_in = '1' then Puntos2_reg <= Puntos2_reg + 1; end if;
                        if Puntos3_in = '1' then Puntos3_reg <= Puntos3_reg + 1; end if;
                        if Puntos4_in = '1' then Puntos4_reg <= Puntos4_reg + 1; end if;
                    when others =>
                        null;
                end case;
                if num_round_in = '1' then num_round_reg <= num_round_reg + 1; end if;
            end if;
        end if;
    end process;





end architecture;