----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.12.2025
-- Design Name: 
-- Module Name: TB_ResolRonda - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for ResolRonda
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.estados_pkg.all;

entity TB_ResolRonda is
end TB_ResolRonda;

architecture Behavioral of TB_ResolRonda is
    -- Declaración del componente Freqdiv (divisor de frecuencia)
    component Freqdiv is
    Port (clk    :  in  std_logic;
          estado_in :  in  estados;
          reset1  :  in  std_logic;
          reset2  :  in  std_logic;
          reset3  :  in  std_logic;
          reset4  :  in  std_logic;
          reset5  :  in  std_logic;
          fdiv_out :  out std_logic);
    end component;
    
    -- Señales de prueba
    signal clk_tb, reset_tb : STD_LOGIC := '0';
    signal fdiv_reset_tb, fdiv_fin_tb : STD_LOGIC;
    signal R_num_jug_tb : std_logic_vector (3 downto 0) := (others => '0');
    signal R_NumPiedras1_tb, R_NumPiedras2_tb, R_NumPiedras3_tb, R_NumPiedras4_tb : std_logic_vector (1 downto 0);
    signal R_Apuesta1_tb, R_Apuesta2_tb, R_Apuesta3_tb, R_Apuesta4_tb : std_logic_vector (3 downto 0);
    signal R_Puntos1_tb, R_Puntos2_tb, R_Puntos3_tb, R_Puntos4_tb : std_logic_vector (1 downto 0);
    signal W_Puntos1_tb, W_Puntos2_tb, W_Puntos3_tb, W_Puntos4_tb : std_logic;
    signal W_Display_tb : std_logic_vector(19 downto 0);
    signal fin_tb : std_logic;
    
    -- Constantes para el periodo del reloj
    constant CLK_PERIOD : time := 10 ns;
    
begin
    
    -- Instanciación del UUT (Unit Under Test)
    UUT: entity work.Bloque4
        port map (
            clk => clk_tb,
            reset => reset_tb,
            fdiv_reset => fdiv_reset_tb,
            fdiv_fin => fdiv_fin_tb,
            btn_continue => '0',
            R_num_jug => R_num_jug_tb,
            R_NumPiedras1 => R_NumPiedras1_tb,
            R_NumPiedras2 => R_NumPiedras2_tb,
            R_NumPiedras3 => R_NumPiedras3_tb,
            R_NumPiedras4 => R_NumPiedras4_tb,
            R_Apuesta1 => R_Apuesta1_tb,
            R_Apuesta2 => R_Apuesta2_tb,
            R_Apuesta3 => R_Apuesta3_tb,
            R_Apuesta4 => R_Apuesta4_tb,
            R_Puntos1 => R_Puntos1_tb,
            R_Puntos2 => R_Puntos2_tb,
            R_Puntos3 => R_Puntos3_tb,
            R_Puntos4 => R_Puntos4_tb,
            W_Puntos1 => W_Puntos1_tb,
            W_Puntos2 => W_Puntos2_tb,
            W_Puntos3 => W_Puntos3_tb,
            W_Puntos4 => W_Puntos4_tb,
            segments7 => W_Display_tb,
            fin_fase => fin_tb
        );
    
    fdiv : Freqdiv
        port map (
            clk => clk_tb,
            estado_in => ResRonda,
            reset1 => '0',
            reset2 => '0',
            reset3 => '0',
            reset4 => reset_tb,
            reset5 => '0',
            fdiv_out => fdiv_fin_tb
        );
    -- Generación del reloj
    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Proceso de estimulación
    stimulus_process: process
    begin
        -- Test 1: Reset inicial
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';
        
        -- Test 2: Configurar piedras y apuestas - Jugador 1 gana
        R_num_jug_tb <= "0100"; -- 4 jugadores

        R_NumPiedras1_tb <= "10"; -- 2 piedras
        R_NumPiedras2_tb <= "11"; -- 3 piedras
        R_NumPiedras3_tb <= "01"; -- 1 piedra
        R_NumPiedras4_tb <= "10"; -- 2 piedras
        -- Total = 8 piedras
        R_Apuesta1_tb <= "1000"; -- Jugador 1 apuesta 8 (correcto)
        R_Apuesta2_tb <= "0110"; -- Jugador 2 apuesta 6
        R_Apuesta3_tb <= "0111"; -- Jugador 3 apuesta 7
        R_Apuesta4_tb <= "1001"; -- Jugador 4 apuesta 9

        R_Puntos1_tb <= "01"; -- 1 punto
        R_Puntos2_tb <= "00"; -- 0 puntos
        R_Puntos3_tb <= "10"; -- 2 puntos
        R_Puntos4_tb <= "01"; -- 1 punto
        
        -- Esperar varios ciclos para observar la máquina de estados
        wait for CLK_PERIOD * 3000;
        
        -- Test 3: Reset y nueva ronda - Jugador 2 gana
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';

        R_NumPiedras1_tb <= "01"; -- 1 piedra
        R_NumPiedras2_tb <= "10"; -- 2 piedras
        R_NumPiedras3_tb <= "11"; -- 3 piedras
        R_NumPiedras4_tb <= "01"; -- 1 piedra
        -- Total = 12 piedras
        R_Apuesta1_tb <= "1010"; -- Jugador 1 apuesta 10
        R_Apuesta2_tb <= "1100"; -- Jugador 2 apuesta 12 
        R_Apuesta3_tb <= "1011"; -- Jugador 3 apuesta 11
        R_Apuesta4_tb <= "0111"; -- Jugador 4 apuesta 7
        
        wait for CLK_PERIOD * 3000;
        
        -- Test 4: Reset y nueva ronda - Jugador 3 gana
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';
        
        R_NumPiedras1_tb <= "01"; -- 1 piedra
        R_NumPiedras2_tb <= "01"; -- 1 piedra
        R_NumPiedras3_tb <= "01"; -- 1 piedra
        R_NumPiedras4_tb <= "10"; -- 2 piedras
        -- Total = 5 piedras
        R_Apuesta1_tb <= "0100"; -- Jugador 1 apuesta 4
        R_Apuesta2_tb <= "0110"; -- Jugador 2 apuesta 6
        R_Apuesta3_tb <= "0101"; -- Jugador 3 apuesta 5 (correcto)
        R_Apuesta4_tb <= "0111"; -- Jugador 4 apuesta 7
        
        wait for CLK_PERIOD * 3000;
        
        -- Test 5: Caso donde jugador 4 gana (por defecto - nadie acierta)
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';
        
        R_NumPiedras1_tb <= "11"; -- 3 piedras
        R_NumPiedras2_tb <= "10"; -- 2 piedras
        R_NumPiedras3_tb <= "10"; -- 2 piedras
        R_NumPiedras4_tb <= "11"; -- 3 piedras
        -- Total = 10 piedras
        R_Apuesta1_tb <= "0111"; -- Jugador 1 apuesta 7
        R_Apuesta2_tb <= "1000"; -- Jugador 2 apuesta 8
        R_Apuesta3_tb <= "1001"; -- Jugador 3 apuesta 9
        R_Apuesta4_tb <= "1011"; -- Jugador 4 apuesta 11 (ninguno acierta)
        
        wait for CLK_PERIOD * 3000;
        
        -- Test 6: Valores extremos
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';
        
        R_NumPiedras1_tb <= "11"; -- 15 piedras (máximo)
        R_NumPiedras2_tb <= "00"; -- 0 piedras
        R_NumPiedras3_tb <= "01"; -- 1 piedra
        R_NumPiedras4_tb <= "00"; -- 0 piedras
        -- Total = 16 piedras
        R_Apuesta1_tb <= "0000"; -- Jugador 1 apuesta 0
        R_Apuesta2_tb <= "0000"; -- Jugador 2 apuesta 0
        R_Apuesta3_tb <= "0000"; -- Jugador 3 apuesta 0
        R_Apuesta4_tb <= "0000"; -- Jugador 4 apuesta 0 (gana por defecto)
        
        wait for CLK_PERIOD * 3000;
        
        -- Finalizar simulación
        wait;
        
    end process;
    
end Behavioral;
