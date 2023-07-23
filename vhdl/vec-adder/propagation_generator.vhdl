-- propagation generator for CLA 4-Bit Adder

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY propagation_generator IS
    PORT (
        a, b : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        vec_p, vec_g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        p, g : OUT STD_LOGIC
    );
END propagation_generator;

ARCHITECTURE behavior OF propagation_generator IS
    SIGNAL p_vec, g_vec : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    PROCESS (a, b)
    BEGIN
        p_vec <= a XOR b;
        g_vec <= a AND b;
    END PROCESS;

    vec_p <= p_vec;
    vec_g <= g_vec;
    p <= p_vec(3) AND p_vec(2) AND p_vec(1) AND p_vec(0);
    g <= g_vec(3) OR (g_vec(2) AND p_vec(3)) OR (p_vec(3) AND p_vec(2) AND g_vec(1)) OR (p_vec(3) AND p_vec(2) AND p_vec(1) AND g_vec(0));
END behavior;