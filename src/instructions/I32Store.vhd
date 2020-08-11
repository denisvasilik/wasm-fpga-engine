library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.store
--
-- Return the result of subtracting i2​ from i1​ modulo 2N.
--
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-store
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-store
--
entity InstructionI32Store is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : buffer T_WasmFpgaInstruction_WasmFpgaModuleRam;
        WasmFpgaMemory_WasmFpgaInstruction : in T_WasmFpgaMemory_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaMemory : out T_WasmFpgaInstruction_WasmFpgaMemory
    );
end entity;

architecture InstructionI32StoreArchitecture of InstructionI32Store is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(31 downto 0);
    signal OperandB : std_logic_vector(31 downto 0);

begin

    Rst <= not nRst;

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
          -- Invocation
          WasmFpgaInstruction_WasmFpgaInvocation.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Trap <= '0';
          WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
          -- Stack
          WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
          WasmFpgaInstruction_WasmFpgaStack.Action <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.TypeValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.HighValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.LowValue <= (others => '0');
          -- Module
          WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '0';
          WasmFpgaInstruction_WasmFpgaModuleRam.Address <= (others => '0');
          -- Memory
          WasmFpgaInstruction_WasmFpgaMemory.Run <= '0';
          WasmFpgaInstruction_WasmFpgaMemory.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaMemory.WriteData <= (others => '0');
          WasmFpgaInstruction_WasmFpgaMemory.WriteEnable <= '0';
          OperandA <= (others => '0');
          OperandB <= (others => '0');
          PopFromStackState <= (others => '0');
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '0';
                WasmFpgaInstruction_WasmFpgaMemory.Run <= '0';
                WasmFpgaInstruction_WasmFpgaMemory.WriteEnable <= '0';
                if (WasmFpgaInvocation_WasmFpgaInstruction.Run = '1') then
                    WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
                    WasmFpgaInstruction_WasmFpgaModuleRam.Address <= WasmFpgaInvocation_WasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                PopFromStack(PopFromStackState,
                             WasmFpgaInstruction_WasmFpgaStack,
                             WasmFpgaStack_WasmFpgaInstruction);
                if(PopFromStackState = StateEnd) then
                    OperandB <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                PopFromStack(PopFromStackState,
                             WasmFpgaInstruction_WasmFpgaStack,
                             WasmFpgaStack_WasmFpgaInstruction);
                if(PopFromStackState = StateEnd) then
                    OperandA <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    State <= State2;
                end if;
            elsif (State = State2) then
                WasmFpgaInstruction_WasmFpgaMemory.Run <= '1';
                WasmFpgaInstruction_WasmFpgaMemory.WriteEnable <= '1';
                WasmFpgaInstruction_WasmFpgaMemory.WriteData <= OperandB;
                WasmFpgaInstruction_WasmFpgaMemory.Address <= OperandA(23 downto 0);
                State <= State3;
            elsif (State = State3) then
                WasmFpgaInstruction_WasmFpgaMemory.Run <= '0';
                State <= State4;
            elsif (State = State4) then
                State <= State5;
            elsif (State = State5) then
                State <= State6;
            elsif (State = State6) then
                if(WasmFpgaMemory_WasmFpgaInstruction.Busy = '0') then
                    WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end architecture;