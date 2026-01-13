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

entity TB_ResolRonda is
end TB_ResolRonda;

architecture Behavioral of TB_ResolRonda is
    -- Declaración del componente a probar
    component ResolRonda is
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
    end component;

    component Freqdiv is
    Port (clk    :  in  std_logic;
          reset  :  in  std_logic;
          Output :  out std_logic);
    end component;
    
    -- Señales de prueba
    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '0';
    signal fdiv_reset_tb : std_logic;
    signal fdiv_fin_tb : std_logic;
    signal R_NumPiedras1_tb : std_logic_vector(1 downto 0) := (others => '0');
    signal R_NumPiedras2_tb : std_logic_vector(1 downto 0) := (others => '0');
    signal R_NumPiedras3_tb : std_logic_vector(1 downto 0) := (others => '0');
    signal R_NumPiedras4_tb : std_logic_vector(1 downto 0) := (others => '0');
    signal R_Apuesta1_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal R_Apuesta2_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal R_Apuesta3_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal R_Apuesta4_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal W_Puntos1_tb : std_logic;
    signal W_Puntos2_tb : std_logic;
    signal W_Puntos3_tb : std_logic;
    signal W_Puntos4_tb : std_logic;
    signal W_Display_tb : std_logic_vector(19 downto 0);
    signal fin_tb : std_logic;
    
    -- Constantes para el periodo del reloj
    constant CLK_PERIOD : time := 10 ns;
    
begin
    
    -- Instanciación del UUT (Unit Under Test)
    UUT: ResolRonda
        port map (
            clk => clk_tb,
            reset => reset_tb,
            fdiv_reset => fdiv_reset_tb,
            fdiv_fin => fdiv_fin_tb,
            R_NumPiedras1 => R_NumPiedras1_tb,
            R_NumPiedras2 => R_NumPiedras2_tb,
            R_NumPiedras3 => R_NumPiedras3_tb,
            R_NumPiedras4 => R_NumPiedras4_tb,
            R_Apuesta1 => R_Apuesta1_tb,
            R_Apuesta2 => R_Apuesta2_tb,
            R_Apuesta3 => R_Apuesta3_tb,
            R_Apuesta4 => R_Apuesta4_tb,
            W_Puntos1 => W_Puntos1_tb,
            W_Puntos2 => W_Puntos2_tb,
            W_Puntos3 => W_Puntos3_tb,
            W_Puntos4 => W_Puntos4_tb,
            W_Display => W_Display_tb,
            fin => fin_tb
        );
    
    fdiv : Freqdiv
        port map (
            clk => clk_tb,
            reset => fdiv_reset_tb,
            Output => fdiv_fin_tb
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
        R_NumPiedras1_tb <= "10"; -- 2 piedras
        R_NumPiedras2_tb <= "11"; -- 3 piedras
        R_NumPiedras3_tb <= "01"; -- 1 piedra
        R_NumPiedras4_tb <= "10"; -- 2 piedras
        -- Total = 8 piedras
        R_Apuesta1_tb <= "1000"; -- Jugador 1 apuesta 8 (correcto)
        R_Apuesta2_tb <= "0110"; -- Jugador 2 apuesta 6
        R_Apuesta3_tb <= "0111"; -- Jugador 3 apuesta 7
        R_Apuesta4_tb <= "1001"; -- Jugador 4 apuesta 9
        
        -- Esperar varios ciclos para observar la máquina de estados
        wait for CLK_PERIOD * 3000;
        
        -- Test 3: Reset y nueva ronda - Jugador 2 gana
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';
        
        R_NumPiedras1_tb <= "01"; -- 1 piedras
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
