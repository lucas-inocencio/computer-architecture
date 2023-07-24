-- LookAhead 4-Bit

LIBRARY ieee;
use ieee.std_logic_1164.all;

ENTITY LookAhead4Bit IS
    PORT(
        a, b, p, g : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        cin : IN STD_LOGIC;
        s : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END LookAhead4Bit;

ARCHITECTURE LookAhead4Bit OF LookAhead4Bit IS
BEGIN
    s(0) <= p(0) XOR cin;
    s(1) <= p(1) XOR (g(0) OR (p(0) AND cin));
    s(2) <= p(2) XOR (g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin));
    s(3) <= p(3) XOR ((p(2) AND g(1)) OR (p(2) AND p(1) AND g(0)) OR (p(2) AND p(1) AND p(0) AND cin));
END LookAhead4Bit;