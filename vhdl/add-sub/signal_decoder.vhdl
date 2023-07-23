LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY signal_decoder IS
    PORT (
        a, b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        a0, a1, a2, a3, a4, a5, a6, a7, b1, b2, b3, b4, b5, b6, b7 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    );
END signal_decoder;

ARCHITECTURE Behavioral OF signal_decoder IS

BEGIN
    a0 <= a(3 DOWNTO 0);
    a1 <= a(7 DOWNTO 4);
    a2 <= a(11 DOWNTO 8);
    a3 <= a(15 DOWNTO 12);
    a4 <= a(19 DOWNTO 16);
    a5 <= a(23 DOWNTO 20);
    a6 <= a(27 DOWNTO 24);
    a7 <= a(31 DOWNTO 28);

    b1 <= b(3 DOWNTO 0);
    b2 <= b(7 DOWNTO 4);
    b3 <= b(11 DOWNTO 8);
    b4 <= b(15 DOWNTO 12);
    b5 <= b(19 DOWNTO 16);
    b6 <= b(23 DOWNTO 20);
    b7 <= b(27 DOWNTO 24);
END Behavioral;