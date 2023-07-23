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
    s_int(0) <= s0(0);
    s_int(1) <= s0(1);
    s_int(2) <= s0(2);
    s_int(3) <= s0(3);
    s_int(4) <= s1(0);
    s_int(5) <= s1(1);
    s_int(6) <= s1(2);
    s_int(7) <= s1(3);
    s_int(8) <= s2(0);
    s_int(9) <= s2(1);
    s_int(10) <= s2(2);
    s_int(11) <= s2(3);
    s_int(12) <= s3(0);
    s_int(13) <= s3(1);
    s_int(14) <= s3(2);
    s_int(15) <= s3(3);
    s_int(16) <= s4(0);
    s_int(17) <= s4(1);
    s_int(18) <= s4(2);
    s_int(19) <= s4(3);
    s_int(20) <= s5(0);
    s_int(21) <= s5(1);
    s_int(22) <= s5(2);
    s_int(23) <= s5(3);
    s_int(24) <= s6(0);
    s_int(25) <= s6(1);
    s_int(26) <= s6(2);
    s_int(27) <= s6(3);
    s_int(28) <= s7(0);
    s_int(29) <= s7(1);
    s_int(30) <= s7(2);
    s_int(31) <= s7(3);

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
            WHEN OTHERS =>
                s <= "00000000000000000000000000000000";
        END CASE;
    END PROCESS;
END behavior;