library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Bloque4 is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;

            fdiv_reset : out STD_LOGIC;
            fdiv_fin : in STD_LOGIC;
            
            R_NumPiedras1 : in std_logic_vector (1 downto 0);
            R_NumPiedras2 : in std_logic_vector (1 downto 0);
            R_NumPiedras3 : in std_logic_vector (1 downto 0);
            R_NumPiedras4 : in std_logic_vector (1 downto 0);
            R_Apuesta1 : in std_logic_vector (3 downto 0);
            R_Apuesta2 : in std_logic_vector (3 downto 0);
            R_Apuesta3 : in std_logic_vector (3 downto 0);
            R_Apuesta4 : in std_logic_vector (3 downto 0);
            W_Puntos1 : out std_logic;
            W_Puntos2 : out std_logic;
            W_Puntos3 : out std_logic;
            W_Puntos4 : out std_logic;
            W_Display : out std_logic_vector(19 downto 0);
            fin : out std_logic
           );
end Bloque4;

architecture Behavioral of Bloque4 is
    signal fin_s, pulsoflag : std_logic;
    type estados is (MostrarNumPiedras, MostrarTotPiedaras, MostrarApuestas, MostrarGanador);
    signal estado : estados;
    signal winner : std_logic_vector(4 downto 0);
    signal TotalApuestas : std_logic_vector(3 downto 0);
begin

process(clk, reset)
begin
    if reset = '1' then
        estado <= MostrarNumPiedras;
        fdiv_reset <= '1';
        W_Puntos1 <= '0';
        W_Puntos2 <= '0';
        W_Puntos3 <= '0';
        W_Puntos4 <= '0';
        fin_s <= '0';
        pulsoflag <= '0';
        winner <= "00100";
        W_Display <= "11010" & "11010" & "11010" & "11010"; -- en reset apagamos todos los displays
    elsif clk'event and clk = '1' then
        case estado is
            when MostrarNumPiedras =>
                --lógica del estado
                W_Display <= "000" & R_NumPiedras1 & "000" & R_NumPiedras2 & "000" & R_NumPiedras3 & "000" & R_NumPiedras4;
                --transición de estado
                if fdiv_fin = '1' then
                    fdiv_reset <= '1';
                    estado <= MostrarTotPiedaras;
                else
                    fdiv_reset <= '0';
                end if;
            when MostrarTotPiedaras =>
                W_Display <= (19 downto 4 => '0') & TotalApuestas;
                --transición de estado
                if fdiv_fin = '1' then
                    fdiv_reset <= '1';
                    estado <= MostrarApuestas;
                else
                    fdiv_reset <= '0';
                end if;
            when MostrarApuestas =>
                W_Display <= "0" & R_Apuesta1 & "0" & R_Apuesta2 & "0" & R_Apuesta3 & "0" & R_Apuesta4;
                if fdiv_fin = '1' then
                    fdiv_reset <= '1';
                    estado <= MostrarGanador;
                else
                    fdiv_reset <= '0';
                end if;
            when MostrarGanador =>
                -- lógica del estado
                W_Display <= "10010" & "01010" & "11010" & winner;
                if R_Apuesta1 = TotalApuestas then
                    winner <= "00001";
                    if pulsoflag = '0' then
                        W_Puntos1 <= '1';
                        pulsoflag <= '1';
                    else
                        W_Puntos1 <= '0';
                    end if;
                elsif R_Apuesta2 = TotalApuestas then
                    winner <= "00010";
                    if pulsoflag = '0' then
                        W_Puntos2 <= '1';
                        pulsoflag <= '1';
                    else
                        W_Puntos2 <= '0';
                    end if;
                elsif R_Apuesta3 = TotalApuestas then
                    winner <= "00011";
                    if pulsoflag = '0' then
                        W_Puntos3 <= '1';
                        pulsoflag <= '1';
                    else
                        W_Puntos3 <= '0';
                    end if;
                elsif R_Apuesta4 = TotalApuestas then
                    winner <= "00100";
                    if pulsoflag = '0' then
                        W_Puntos4 <= '1';
                        pulsoflag <= '1';
                    else
                        W_Puntos4 <= '0';
                    end if;
                else
                    winner <= "00100";
                end if;
                if fdiv_fin = '1' then
                    fdiv_reset <= '1';
                    fin_s <= '1';
                else
                    if fin_s = '0' then
                        fdiv_reset <= '0';
                    end if;
                end if;
        end case;
    end if;
end process;
TotalApuestas <= std_logic_vector(resize(unsigned(R_NumPiedras1), 4) + resize(unsigned(R_NumPiedras2), 4) + resize(unsigned(R_NumPiedras3), 4) + resize(unsigned(R_NumPiedras4), 4));
fin <= fin_s;
end Behavioral;
