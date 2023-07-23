-- moduling different sizes of adders

LIBRARY iee;
LIBRARY iee.std_logic_1164.ALL;

ENTITY output_size IS
    PORT (
        s0, s1, s2, s3, s4, s5, s6, s7 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        s : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    );
END output_size;

ARCHITECTURE behavior OF output_size IS
    SIGNAL s_int : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    s_int(3 DOWNTO 0) <= s0;
    s_int(7 DOWNTO 4) <= s1;
    s_int(11 DOWNTO 8) <= s2;
    s_int(15 DOWNTO 12) <= s3;
    s_int(19 DOWNTO 16) <= s4;
    s_int(23 DOWNTO 20) <= s5;
    s_int(27 DOWNTO 24) <= s6;
    s_int(31 DOWNTO 28) <= s7;

    PROCESS (sel)
    BEGIN
        CASE sel IS
            WHEN "00" =>
                s(3 DOWNTO 0) <= s_int(3 DOWNTO 0);
            WHEN "01" =>
                s(7 DOWNTO 0) <= s_int(7 DOWNTO 0);
            WHEN "10" =>
                s(15 DOWNTO 0) <= s_int(15 DOWNTO 0);
            WHEN "11" =>
                s <= s_int;
        END CASE;
    END PROCESS;
END behavior;