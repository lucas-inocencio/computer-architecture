-- Design and implement a 32-bit RISC-V CPU (RV32I) whose microarchitecture is based on a pipeline with at least 5 stages in VHDL. 
-- Instruction and data memories are distinct and each deliver one word per cycle, in addition these memories must be modified to allow asynchronous data loading. 
-- The CPU must be adapted to not operate during this data load (maintain its current internal state), in addition to having a reset signal. 
-- For this task only the integer pipeline will be implemented, without supervisor mode (S Mode , specifically the following instructions must be supported:
-- add, addi, auipc and sub
-- and, andi, or, ori, xor and xori
-- sll, slli, srl and srli
-- lw, lui and sw
-- jal, jalr, beq and bne

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cpu IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32;
        ADDR_WIDTH : INTEGER := 32);
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        mem_read : IN STD_LOGIC;
        mem_write : IN STD_LOGIC;
        mem_to_reg : IN STD_LOGIC;
        reg_write : IN STD_LOGIC;
        reg_dst : IN STD_LOGIC;
        alu_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_src : IN STD_LOGIC;
        branch : IN STD_LOGIC;
        jump : IN STD_LOGIC;
        zero : OUT STD_LOGIC;
        branch_out : OUT STD_LOGIC;
        jump_out : OUT STD_LOGIC;
        reg_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0));
END cpu;

ARCHITECTURE Behavioral OF cpu IS
    TYPE state_type IS (fetch, decode, execute, memory, writeback);
    SIGNAL state : state_type;
    SIGNAL pc : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL pc4 : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL instruction : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL instruction_decode : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL instruction_execute : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL instruction_memory : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL instruction_writeback : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL rs1 : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL rs2 : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_result : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL alu_zero : STD_LOGIC;
    SIGNAL data_memory : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL data_memory_addr : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL data_memory_write : STD_LOGIC;
    SIGNAL data_memory_read : STD_LOGIC;
    SIGNAL data_memory_out : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL reg_write_addr : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL reg_write_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL reg_write_enable : STD_LOGIC;
    SIGNAL reg_write_out : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL alu_op_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_src_out : STD_LOGIC;
    SIGNAL branch_out_out : STD_LOGIC;
    SIGNAL jump_out_out : STD_LOGIC;
    SIGNAL zero_out : STD_LOGIC;
    SIGNAL reg_dst_out : STD_LOGIC;
    SIGNAL reg_out_out : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL reg_out_addr : STD_LOGIC_VECTOR(4 DOWNTO 0);


    COMPONENT instruction_memory IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            mem_read : IN STD_LOGIC;
            mem_write : IN STD_LOGIC);
    END COMPONENT;

    COMPONENT instruction_decode IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            rs1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            rs2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            rd : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            imm : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    COMPONENT instruction_execute IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            rs1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            rs2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            alu_result : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            alu_zero : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT instruction_memory IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            mem_read : IN STD_LOGIC;
            mem_write : IN STD_LOGIC);
    END COMPONENT;

    COMPONENT instruction_writeback IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            alu_result : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_memory_out : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            reg_write_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT data_memory IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            mem_read : IN STD_LOGIC;
            mem_write : IN STD_LOGIC);
    END COMPONENT;

    COMPONENT register_file IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            addr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            reg_write : IN STD_LOGIC;
            reg_write_addr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            reg_write_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            reg_write_enable : IN STD_LOGIC);
    END COMPONENT;

    COMPONENT alu IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            alu_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            alu_src : IN STD_LOGIC;
            rs1 : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            rs2 : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            imm : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            alu_result : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            alu_zero : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT control_unit IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            alu_src : OUT STD_LOGIC;
            branch : OUT STD_LOGIC;
            jump : OUT STD_LOGIC;
            zero : OUT STD_LOGIC;
            reg_dst : OUT STD_LOGIC;
            reg_write : OUT STD_LOGIC;
            reg_write_addr : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            reg_write_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            reg_write_enable : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT program_counter IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            pc4 : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            pc : OUT STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT adder IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            a : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            b : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT mux2x1 IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            data_in_0 : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_in_1 : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            sel : IN STD_LOGIC;
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT sign_extend IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT shift_left_2 IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 32);
        PORT (
            data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0));
    END COMPONENT;

BEGIN
    instruction_memory_0 : instruction_memory
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => instruction_memory_data_memory_out,
        data_out => instruction_memory_out,
        addr => pc4,
        mem_read => '1',
        mem_write => '0');

    instruction_decode_0 : instruction_decode
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => instruction_decode_imm,
        data_out => instruction_decode,
        instruction => instruction_memory_out,
        rs1 => instruction_decode_rs1,
        rs2 => instruction_decode_rs2,
        rd => instruction_decode_rd,
        imm => instruction_decode_imm);

    instruction_execute_0 : instruction_execute
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => instruction_execute_alu_result,
        data_out => instruction_execute,
        instruction => instruction_decode,
        rs1 => instruction_decode_rs1,
        rs2 => instruction_decode_rs2,
        rd => instruction_decode_rd,
        imm => instruction_decode_imm,
        alu_result => instruction_execute_alu_result,
        alu_zero => instruction_execute_alu_zero);

    instruction_memory_1 : instruction_memory
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => instruction_memory_data_memory_out,
        data_out => instruction_memory_data_memory_out,
        addr => instruction_execute_alu_result,
        mem_read => '1',
        mem_write => '0');

    instruction_writeback_0 : instruction_writeback
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => instruction_writeback_reg_write_out,
        data_out => instruction_writeback,
        instruction => instruction_decode,
        rd => instruction_decode_rd,
        alu_result => instruction_execute_alu_result,
        data_memory_out => instruction_memory_data_memory_out,
        reg_write_out => instruction_writeback_reg_write_out);

    data_memory_0 : data_memory
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => data_memory_data_memory_out,
        data_out => data_memory_data_memory_out,
        addr => instruction_execute_alu_result,
        mem_read => '0',
        mem_write => '1');

    register_file_0 : register_file
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => reg_write_out,
        data_out => reg_out_out,
        addr => reg_out_addr,
        reg_write => reg_write_out,
        reg_write_addr => reg_write_addr,
        reg_write_data => reg_write_data,
        reg_write_enable => reg_write_enable);

    alu_0 : alu
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => alu_alu_result,
        data_out => alu_alu_result,
        alu_op => alu_op_out,
        alu_src => alu_src_out,
        rs1 => instruction_decode_rs1,
        rs2 => mux_alu_src_out,
        imm => instruction_decode_imm,
        alu_result => alu_result,
        alu_zero => alu_zero);

    control_unit_0 : control_unit
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => control_unit_reg_write_out,
        data_out => control_unit_reg_write_out,
        instruction => instruction_decode,
        alu_op => control_unit_alu_op_out,
        alu_src => control_unit_alu_src_out,
        branch => control_unit_branch_out_out,
        jump => control_unit_jump_out_out,
        zero => control_unit_zero_out,
        reg_dst => control_unit_reg_dst_out,
        reg_write => control_unit_reg_write_out,
        reg_write_addr => control_unit_reg_write_addr,
        reg_write_data => control_unit_reg_write_data,
        reg_write_enable => control_unit_reg_write_enable);

    program_counter_0 : program_counter
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => program_counter_pc4,
        data_out => program_counter_pc,
        pc4 => program_counter_pc4);

    adder_0 : adder
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => adder_result,
        data_out => adder_result,
        a => program_counter_pc4,
        b => shift_left_2_imm,
        result => pc4);

    mux_alu_src_0 : mux2x1
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        data_in_0 => instruction_execute_alu_result,
        data_in_1 => instruction_execute_alu_result,
        sel => alu_src_out,
        data_out => mux_alu_src_out);

    mux_branch_out_0 : mux2x1
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        data_in_0 => program_counter_pc4,
        data_in_1 => adder_result,
        sel => branch_out_out,
        data_out => mux_branch_out_out);

    mux_jump_out_0 : mux2x1
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        data_in_0 => program_counter_pc4,
        data_in_1 => shift_left_2_imm,
        sel => jump_out_out,
        data_out => mux_jump_out_out);

    mux_reg_write_0 : mux2x1
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        data_in_0 => instruction_execute_alu_result,
        data_in_1 => data_memory_data_memory_out,
        sel => reg_dst_out,
        data_out => mux_reg_write_out);

    mux_reg_out_0 : mux2x1
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        data_in_0 => instruction_execute_alu_result,
        data_in_1 => data_memory_data_memory_out,
        sel => reg_dst_out,
        data_out => mux_reg_out_out);

    sign_extend_0 : sign_extend
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        data_in => instruction_decode_imm,
        data_out => sign_extend_imm);

    shift_left_2_0 : shift_left_2
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH)
    PORT MAP(
        data_in => sign_extend_imm,
        data_out => shift_left_2_imm);

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            state <= fetch;
            pc <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE state IS
                WHEN fetch =>
                    pc4 <= pc + 4;
                    instruction <= instruction_memory_out;
                    state <= decode;
                WHEN decode =>
                    instruction_decode_imm <= instruction(31 DOWNTO 20);
                    instruction_decode_rs1 <= instruction(19 DOWNTO 15);
                    instruction_decode_rs2 <= instruction(24 DOWNTO 20);
                    instruction_decode_rd <= instruction(11 DOWNTO 7);
                    instruction_decode_imm <= instruction(31 DOWNTO 20) & (OTHERS => '0');
                    state <= execute;
                WHEN execute =>
                    instruction_execute_alu_result <= alu_result;
                    instruction_execute_alu_zero <= alu_zero;
                    state <= memory;
                WHEN memory =>
                    instruction_memory_data_memory_out <= data_memory_out;
                    state <= writeback;
                WHEN writeback =>
                    instruction_writeback_reg_write_out <= reg_write_out;
                    state <= fetch;
                WHEN OTHERS =>
                    state <= fetch;
            END CASE;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            pc <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            pc <= mux_branch_out_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            data_memory_addr <= (OTHERS => '0');
            data_memory_write <= '0';
            data_memory_read <= '0';
            data_memory_data_memory_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            data_memory_addr <= instruction_execute_alu_result;
            data_memory_write <= mem_write;
            data_memory_read <= mem_read;
            data_memory_data_memory_out <= data_memory_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            reg_write_addr <= (OTHERS => '0');
            reg_write_data <= (OTHERS => '0');
            reg_write_enable <= '0';
            reg_write_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            reg_write_addr <= instruction_decode_rd;
            reg_write_data <= mux_reg_write_out;
            reg_write_enable <= reg_write;
            reg_write_out <= reg_out_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            alu_op_out <= (OTHERS => '0');
            alu_src_out <= '0';
            branch_out_out <= '0';
            jump_out_out <= '0';
            zero_out <= '0';
            reg_dst_out <= '0';
            reg_write_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            alu_op_out <= alu_op;
            alu_src_out <= alu_src;
            branch_out_out <= branch;
            jump_out_out <= jump;
            zero_out <= alu_zero;
            reg_dst_out <= reg_dst;
            reg_write_out <= reg_write;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            program_counter_pc4 <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            program_counter_pc4 <= pc4;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            adder_result <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            adder_result <= pc4 + shift_left_2_imm;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            mux_alu_src_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            mux_alu_src_out <= mux_alu_src_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            mux_branch_out_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            mux_branch_out_out <= mux_branch_out_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            mux_jump_out_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            mux_jump_out_out <= mux_jump_out_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            mux_reg_write_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            mux_reg_write_out <= mux_reg_write_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            mux_reg_out_out <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            mux_reg_out_out <= mux_reg_out_out;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            sign_extend_imm <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            sign_extend_imm <= sign_extend_imm;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            shift_left_2_imm <= (OTHERS => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            shift_left_2_imm <= shift_left_2_imm;
        END IF;
    END PROCESS;

END Behavioral;