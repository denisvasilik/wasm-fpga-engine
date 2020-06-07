library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- select
--
-- The select operator selects one of its first two operands based on whether
-- its third operand is zero or not.
--
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-select
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-select
--
entity InstructionSelect is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam
    );
end entity;

architecture InstructionSelectArchitecture of InstructionSelect is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(63 downto 0);
    signal OperandB : std_logic_vector(63 downto 0);
    signal OperandC: std_logic_vector(31 downto 0);

begin

    Rst <= not nRst;

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
          WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
          WasmFpgaInstruction_WasmFpgaStack.Action <= '0';
          WasmFpgaInstruction_WasmFpgaStack.ValueType <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.HighValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.LowValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '0';
          WasmFpgaInstruction_WasmFpgaModuleRam.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Trap <= '0';
          WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
          OperandA <= (others => '0');
          OperandB <= (others => '0');
          OperandC <= (others => '0');
          PopFromStackState <= (others => '0');
          PushToStackState <= (others => '0');
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '0';
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
                    OperandC <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                PopFromStack(PopFromStackState,
                             WasmFpgaInstruction_WasmFpgaStack,
                             WasmFpgaStack_WasmFpgaInstruction);
                if(PopFromStackState = StateEnd) then
                    OperandB(31 downto 0) <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    OperandB(63 downto 32) <= WasmFpgaStack_WasmFpgaInstruction.HighValue;
                    State <= State2;
                end if;
            elsif (State = State2) then
                PopFromStack(PopFromStackState,
                             WasmFpgaInstruction_WasmFpgaStack,
                             WasmFpgaStack_WasmFpgaInstruction);
                if(PopFromStackState = StateEnd) then
                    OperandA(31 downto 0) <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    OperandA(63 downto 32) <= WasmFpgaStack_WasmFpgaInstruction.HighValue;
                    State <= State3;
                end if;
            elsif (State = State3) then
                if (OperandC = x"00000000") then
                    WasmFpgaInstruction_WasmFpgaStack.LowValue <= OperandB(31 downto 0);
                    WasmFpgaInstruction_WasmFpgaStack.HighValue <= OperandB(63 downto 32);
                else
                    WasmFpgaInstruction_WasmFpgaStack.LowValue <= OperandA(31 downto 0);
                    WasmFpgaInstruction_WasmFpgaStack.HighValue <= OperandA(63 downto 32);
                end if;
                State <= State4;
            elsif (State = State4) then
                -- TODO: Distinguish between 32 and 64 bit types.
                PushToStack(PushToStackState,
                            WasmFpgaInstruction_WasmFpgaStack,
                            WasmFpgaStack_WasmFpgaInstruction);
                if(PushToStackState = StateEnd) then
                    State <= State5;
                end if;
            elsif (State = State5) then
                WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;
                State <= StateIdle;
            end if;
        end if;
    end process;

end architecture;