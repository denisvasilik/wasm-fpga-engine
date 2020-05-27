library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.ctz
--
-- Return the count of trailing zero bits in i; all bits are considered
-- trailing zeros if i is 0.
--
entity InstructionI32Ctz is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack
    );
end entity;

architecture InstructionI32CtzArchitecture of InstructionI32Ctz is

    signal Rst : std_logic;
    signal Instruction : T_WasmFpgaEngine;
    signal Stack : T_WasmFpgaStack;

begin

    Rst <= not nRst;

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
            Busy <= '1';
            WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
            WasmFpgaInstruction_WasmFpgaStack.Action <= '0';
            WasmFpgaInstruction_WasmFpgaStack.ValueType <= (others => '0');
            WasmFpgaInstruction_WasmFpgaStack.HighValue <= (others => '0');
            WasmFpgaInstruction_WasmFpgaStack.LowValue <= (others => '0');
        elsif rising_edge(Clk) then
            Stack.Busy <= WasmFpgaStack_WasmFpgaInstruction.Busy;
            WasmFpgaInstruction_WasmFpgaStack.Run <= Stack.Run;
            WasmFpgaInstruction_WasmFpgaStack.Action <= Stack.Action;
            if(Instruction.State = StateIdle) then
                Busy <= '0';
                if (Run = '1') then
                    Busy <= '1';
                    Instruction.State <= State0;
                end if;
            elsif(Instruction.State = State0) then
                PopFromStack(Instruction.State, State1, Instruction, Stack);
            elsif(Instruction.State = State1) then
                WasmFpgaInstruction_WasmFpgaStack.LowValue <= ctz(WasmFpgaStack_WasmFpgaInstruction.LowValue);
                Instruction.State <= State2;
            elsif(Instruction.State = State2) then
                PushToStack(Instruction.State, StateIdle, Instruction, Stack);
            end if;
        end if;
    end process;

end architecture;