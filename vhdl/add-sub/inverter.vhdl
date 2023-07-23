LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY inverter IS
    PORT (
        a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sel : IN STD_LOGIC;
        s : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    );
END inverter;

ARCHITECTURE behavior OF inverter IS
BEGIN
    PROCESS (a, sel)
    BEGIN
        IF (sel = '1') THEN
            s <= NOT a;
        ELSE
            s <= a;
        END IF;
    END PROCESS;
END behavior;