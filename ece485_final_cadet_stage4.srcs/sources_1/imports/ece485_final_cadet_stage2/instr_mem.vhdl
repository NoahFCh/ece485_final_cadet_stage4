library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_mem is
    Port (
        addr    : in  STD_LOGIC_VECTOR(31 downto 0);
        instr   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instr_mem;

-- Note: the Real RISC-V uses the ADDI for the NOP instruction, but I'm pretending 0x0000000000000000 is a NOP
-- inserting NOPs to avoid hazards
architecture Behavioral of instr_mem is
    type memory_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : memory_array := (
        0 => x"00900293", -- addi x5, x0, 9         000000001001 00000 000 00101 0010011
        1 => x"00000317",                  -- load_addr x6, array (custom instruction), where array is 0x10000000 10000317
        --2 => x"00000000",                  -- NOP
        --3 => x"00000000",
        --4 => x"00000000",
        2 => x"00032383",                  -- lw x7, 0(x6)           
        3 => x"00430313",                  -- loop: addi x6, x6, 4   
        --7 => x"00000000",                  -- NOP
        --8 => x"00000000",
        --9 => x"00000000",
        4 => x"00032503",                 -- lw x10, 0(x6)
        --11 => x"00000000",                 -- NOP
        --12 => x"00000000",
        --13 => x"00000000",    
        5 => x"007503B3",                  -- add x7, x10, x7 
        6 => x"FFF28293",                  -- subi x5, x5, 1 (or   addi x5, x5, -1) 

       -- 6 => x"FFF28293",                  -- subi x5, x5, 1 (or   addi x5, x5, -1) 
        --16 => x"00000000",                 -- NOP
        --17 => x"00000000",
        --18 => x"00000000",  
        7 => x"FA0298E3",                  -- bne x5, x0, loop  original: 1111 1010 0000 0010 1001 1000 1110 0011  FFF28293
                                            --                   original imm: 11111101100
                                            --                   new imm: 1111 1110 1100 (-20) 
                                            --                   new: 1 111110 00000 00101 001 110 0 1 1100011
        --20 => x"00000000",                  -- NOP
        --21 => x"00000000",
        8 => x"FF9FF06F", -- done: j done            [-4; note: assumes PC is already incremented by 4] FA02983
        others => (others => '0')
    );
begin
    process(addr)
    begin
        instr <= memory(to_integer(unsigned(addr(7 downto 0))));
    end process;
end Behavioral;