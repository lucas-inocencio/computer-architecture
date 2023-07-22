-- testbench for vecAdder

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vecAdder_tb IS
END ENTITY vecAdder_tb;

ARCHITECTURE sim OF vecAdder_tb IS
    SIGNAL A_i, B_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mode_i : STD_LOGIC;
    SIGNAL vecSize_i : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL S_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    uut : ENTITY work.vecAdder
        PORT MAP(
            A_i => A_i,
            B_i => B_i,
            mode_i => mode_i,
            vecSize_i => vecSize_i,
            S_o => S_o
        );

    PROCESS
    BEGIN
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(0, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(0, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(1, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(2, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(3, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(4, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(5, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(6, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(7, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(8, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(9, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(10, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(11, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(12, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(13, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(14, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(15, 32));
        B
        ```
        _i <= STD_LOGIC_VECTOR(to_unsigned(16, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(17, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(18, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(19, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(20, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(21, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(22, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(23, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(24, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(25, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(26, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(27, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(28, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(29, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(30, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT FOR 10 ns;
        A_i <= STD_LOGIC_VECTOR(to_unsigned(31, 32));
        B_i <= STD_LOGIC_VECTOR(to_unsigned(32, 32));
        mode_i <= '0';
        vecSize_i <= "00";
        WAIT;
    END PROCESS;
END ARCHITECTURE sim;