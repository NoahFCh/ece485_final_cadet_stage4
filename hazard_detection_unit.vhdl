library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detection_unit is
    Port (
        reset :          in STD_LOGIC;
        if_id_mem_read : in STD_LOGIC;                      -- previous instr mem read
        if_id_load_addr : in STD_LOGIC;                     -- previous instr load addr
        instr    : in STD_LOGIC_VECTOR(31 downto 0);        -- current  instr
        if_id_instr    : in STD_LOGIC_VECTOR(31 downto 0);  -- previous instr
        if_id_rd       : in STD_LOGIC_VECTOR(4 downto 0);   -- previous instr destination register
        rs1      : in STD_LOGIC_VECTOR(4 downto 0);         -- current  instr source register
        rs2      : in STD_LOGIC_VECTOR(4 downto 0);         -- current  instr source register
        -- need any other input registers?
        stall_counter  : in integer range 0 to 3 := 0;
        start_stall    : out STD_LOGIC;
        double_stall   : out STD_LOGIC;
        if_id_opcode   : in STD_LOGIC_VECTOR(6 downto 0);
        opcode   : in STD_LOGIC_VECTOR(6 downto 0);
        mux_select_A   : in STD_LOGIC_VECTOR(1 downto 0)
    );
end hazard_detection_unit;

-- NOTE: only looks one instruction before dependency (not two or three before)
architecture Behavioral of hazard_detection_unit is
    -- declare any internal signals?
begin
    -- would opcodes of instructions be useful?

    process(if_id_mem_read, if_id_rd, rs1, rs2, if_id_opcode, opcode, stall_counter, reset) -- any others?)
    begin      
        if (reset = '1') then
            start_stall <= '0';
            double_stall <= '0';
        -- stall cases, dependency on a (1)load from memory, (2) load_addr
        elsif (stall_counter = 0 and opcode = "0000011" and mux_select_A /= "10") 
              and (rs1 = if_id_rd and if_id_rd /= "00000" ) then -- single stall data dependency case
                start_stall <= '1';
        elsif (stall_counter = 0)
              and (rs1 = if_id_rd and if_id_rd /= "00000" and opcode = "1100011") then --BNE double stall
                    start_stall <= '1';
                    double_stall <= '1';
        elsif (stall_counter = 0 and (opcode = "0010011" or opcode = "0110011") and (if_id_opcode = "0010011" or if_id_opcode = "0110011" or if_id_opcode = "0000011")) --(3) add, (4) addi/subi
              and (rs1 = if_id_rd and if_id_rd /= "00000") then  -- stall data dependency case
                    start_stall <= '1';
        elsif -- stall cases for branch or jump, needing time to calulate branch address, etc
              (stall_counter = 0 and (if_id_opcode = "1100011")) then 
                start_stall <= '1';  
                double_stall <= '0';    
        else        
                start_stall <= '0';
                double_stall <= '0';
        end if;    
        
    end process;
end Behavioral;
