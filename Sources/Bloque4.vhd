--Bloque4.vhd: Módulo encargado de gestionar la fase de resolución y puntuaciones.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Bloque4 is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;

            fdiv_reset : out STD_LOGIC;
            fdiv_fin : in STD_LOGIC;

            R_num_jug     : in  std_logic_vector (3 downto 0);
            
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

            R_Puntos1: in std_logic_vector (1 downto 0);
            R_Puntos2 : in std_logic_vector (1 downto 0);
            R_Puntos3 : in std_logic_vector (1 downto 0);
            R_Puntos4 : in std_logic_vector (1 downto 0);

            segments7 : out std_logic_vector(19 downto 0);
            
            fin_fase : out std_logic
           );
end Bloque4;

architecture Behavioral of Bloque4 is
    signal fin_s, pulsoflag : std_logic;
    type estados is (MostrarNumPiedras, MostrarTotPiedaras, MostrarApuestas, MostrarGanador, MostrarPuntuaciones);
    signal estado : estados;
    signal winner : std_logic_vector(4 downto 0);
    signal TotalApuestas : std_logic_vector(3 downto 0);
begin

process(clk)
begin
    if clk'event and clk = '1' then

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
            segments7 <= "11111" & "11111" & "11111" & "11111"; -- en reset apagamos todos los displays
        else
    
            case estado is
                when MostrarNumPiedras =>
                    --lógica del estado
                    segments7 (19 downto 10) <= "000" & R_NumPiedras1 & "000" & R_NumPiedras2;
                    case R_num_jug is
                        when "0010" => -- 2 Jugadores
                            segments7 (9 downto 0) <= "11111" & "11111";
                        when "0011" => -- 3 Jugadores
                            segments7 (9 downto 0) <= "000" & R_NumPiedras3 & "11111";
                        when "0100" => -- 4 Jugadores
                            segments7 (9 downto 0) <= "000" & R_NumPiedras3 & "000" & R_NumPiedras4;
                        when others =>
                            segments7 (9 downto 0) <= "11111" & "11111";
                        end case;   
                    --transición de estado
                    if fdiv_fin = '1' then
                        fdiv_reset <= '1';
                        estado <= MostrarTotPiedaras;
                    else
                        fdiv_reset <= '0';
                    end if;
                when MostrarTotPiedaras =>
                    segments7 <= (19 downto 5 => '1') & "0" & TotalApuestas;
                    --transición de estado
                    if fdiv_fin = '1' then
                        fdiv_reset <= '1';
                        estado <= MostrarApuestas;
                    else
                        fdiv_reset <= '0';
                    end if;
                when MostrarApuestas =>
                    segments7 (19 downto 10) <= "0" & R_Apuesta1 & "0" & R_Apuesta2;
                    case R_num_jug is
                        when "0010" => -- 2 Jugadores
                            segments7 (9 downto 0) <= "11111" & "11111";
                        when "0011" => -- 3 Jugadores
                            segments7 (9 downto 0) <= "0" & R_Apuesta3 & "11111";
                        when "0100" => -- 4 Jugadores
                            segments7 (9 downto 0) <= "0" & R_Apuesta3 & "0" & R_Apuesta4;
                        when others =>
                            segments7 (9 downto 0) <= "11111" & "11111";
                        end case;
                    if fdiv_fin = '1' then
                        fdiv_reset <= '1';
                        estado <= MostrarGanador;
                    else
                        fdiv_reset <= '0';
                    end if;
                when MostrarGanador =>
                    -- lógica del estado
                    segments7 <= "10010" & "01010" & "11111" & winner;
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
                        winner <= "00000";
                    end if;
                    if fdiv_fin = '1' then
                        fdiv_reset <= '1';
                        estado <= MostrarPuntuaciones;
                    elsif fin_s = '0' then
                        fdiv_reset <= '0';
                    end if;

                when MostrarPuntuaciones =>
                    segments7 (19 downto 10) <= "000" & R_Puntos1 & "000" & R_Puntos2;
                    case R_num_jug is
                        when "0010" => -- 2 Jugadores
                            segments7 (9 downto 0) <= "11111" & "11111";
                        when "0011" => -- 3 Jugadores
                            segments7 (9 downto 0) <= "000" & R_Puntos3 & "11111";
                        when "0100" => -- 4 Jugadores
                            segments7 (9 downto 0) <= "000" & R_Puntos3 & "000" & R_Puntos4;
                        when others =>
                            segments7 (9 downto 0) <= "11111" & "11111";
                        end case;
                    if fdiv_fin = '1' then
                        fdiv_reset <= '1';
                        estado <= MostrarNumPiedras;
                        fin_s <= '1';
                    else
                        fdiv_reset <= '0';
                        fin_s <= '0';
                    end if;
            end case;
        end if;
    end if;
end process;
TotalApuestas <= std_logic_vector(resize(unsigned(R_NumPiedras1), 4) + resize(unsigned(R_NumPiedras2), 4) + resize(unsigned(R_NumPiedras3), 4) + resize(unsigned(R_NumPiedras4), 4));
fin_fase <= fin_s;
end Behavioral;
