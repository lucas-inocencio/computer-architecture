-- 32-bit vector adder/subtractor
-- input is two vectors of 32-bit integers
-- the vector can be sliced into eight 4-bit integers or four 8-bit integers or two 16-bit integers

-- A_i, B_i std_logic_vector(31 DOWNTO 0); 32 bit operands
-- mode_i std_logic; 0 = add, 1 = subtract
-- vecSize_i std_logic_vector(1 DOWNTO 0); 00 = 4, 01 = 8, 10 = 16 or 11 = 32.
-- S_o std_logic_vector(31 DOWNTO 0); 32 bit result

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vecAdder IS
    PORT (
        A_i, B_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        mode_i : IN STD_LOGIC;
        vecSize_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        S_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY vecAdder;

ARCHITECTURE rtl OF vecAdder IS
    SIGNAL A, B : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL S : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    A <= A_i;
    B <= B_i;

    PROCESS (A, B, mode_i, vecSize_i)
    BEGIN
        CASE vecSize_i IS
            WHEN "00" => -- 4
                IF mode_i = '0' THEN
                    S <= STD_LOGIC_VECTOR(unsigned(A(3 DOWNTO 0)) + unsigned(B(3 DOWNTO 0))) &
                        STD_LOGIC_VECTOR(unsigned(A(7 DOWNTO 4)) + unsigned(B(7 DOWNTO 4))) &
                        STD_LOGIC_VECTOR(unsigned(A(11 DOWNTO 8)) + unsigned(B(11 DOWNTO 8))) &
                        STD_LOGIC_VECTOR(unsigned(A(15 DOWNTO 12)) + unsigned(B(15 DOWNTO 12))) &
                        STD_LOGIC_VECTOR(unsigned(A(19 DOWNTO 16)) + unsigned(B(19 DOWNTO 16))) &
                        STD_LOGIC_VECTOR(unsigned(A(23 DOWNTO 20)) + unsigned(B(23 DOWNTO 20))) &
                        STD_LOGIC_VECTOR(unsigned(A(27 DOWNTO 24)) + unsigned(B(27 DOWNTO 24))) &
                        STD_LOGIC_VECTOR(unsigned(A(31 DOWNTO 28)) + unsigned(B(31 DOWNTO 28)));
                ELSE
                    S <= STD_LOGIC_VECTOR(unsigned(A(3 DOWNTO 0)) - unsigned(B(3 DOWNTO 0))) &
                        STD_LOGIC_VECTOR(unsigned(A(7 DOWNTO 4)) - unsigned(B(7 DOWNTO 4))) &
                        STD_LOGIC_VECTOR(unsigned(A(11 DOWNTO 8)) - unsigned(B(11 DOWNTO 8))) &
                        STD_LOGIC_VECTOR(unsigned(A(15 DOWNTO 12)) - unsigned(B(15 DOWNTO 12))) &
                        STD_LOGIC_VECTOR(unsigned(A(19 DOWNTO 16)) - unsigned(B(19 DOWNTO 16))) &
                        STD_LOGIC_VECTOR(unsigned(A(23 DOWNTO 20)) - unsigned(B(23 DOWNTO 20))) &
                        STD_LOGIC_VECTOR(unsigned(A(27 DOWNTO 24)) - unsigned(B(27 DOWNTO 24))) &
                        STD_LOGIC_VECTOR(unsigned(A(31 DOWNTO 28)) - unsigned(B(31 DOWNTO 28)));
                END IF;
            WHEN "01" => -- 8
                IF mode_i = '0' THEN
                    S <= STD_LOGIC_VECTOR(unsigned(A(7 DOWNTO 0)) + unsigned(B(7 DOWNTO 0))) &
                        STD_LOGIC_VECTOR(unsigned(A(15 DOWNTO 8)) + unsigned(B(15 DOWNTO 8))) &
                        STD_LOGIC_VECTOR(unsigned(A(23 DOWNTO 16)) + unsigned(B(23 DOWNTO 16))) &
                        STD_LOGIC_VECTOR(unsigned(A(31 DOWNTO 24)) + unsigned(B(31 DOWNTO 24)));
                ELSE
                    S <= STD_LOGIC_VECTOR(unsigned(A(7 DOWNTO 0)) - unsigned(B(7 DOWNTO 0))) &
                        STD_LOGIC_VECTOR(unsigned(A(15 DOWNTO 8)) - unsigned(B(15 DOWNTO 8))) &
                        STD_LOGIC_VECTOR(unsigned(A(23 DOWNTO 16)) - unsigned(B(23 DOWNTO 16))) &
                        STD_LOGIC_VECTOR(unsigned(A(31 DOWNTO 24)) - unsigned(B(31 DOWNTO 24)));
                END IF;
            WHEN "10" => -- 16
                IF mode_i = '0' THEN
                    S <= STD_LOGIC_VECTOR(unsigned(A(15 DOWNTO 0)) + unsigned(B(15 DOWNTO 0))) &
                        STD_LOGIC_VECTOR(unsigned(A(31 DOWNTO 16)) + unsigned(B(31 DOWNTO 16)));
                ELSE
                    S <= STD_LOGIC_VECTOR(unsigned(A(15 DOWNTO 0)) - unsigned(B(15 DOWNTO 0))) &
                        STD_LOGIC_VECTOR(unsigned(A(31 DOWNTO 16)) - unsigned(B(31 DOWNTO 16)));
                END IF;
            WHEN "11" => -- 32
                IF mode_i = '0' THEN
                    S <= STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
                ELSE
                    S <= STD_LOGIC_VECTOR(unsigned(A) - unsigned(B));
                END IF;
        END CASE;
    END PROCESS;

    S_o <= S;
END ARCHITECTURE rtl;