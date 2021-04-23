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
        ToWasmFpgaInstruction : in T_ToWasmFpgaInstruction;
        FromWasmFpgaInstruction : out T_FromWasmFpgaInstruction;
        FromWasmFpgaStack : in T_FromWasmFpgaStack;
        ToWasmFpgaStack : out T_ToWasmFpgaStack;
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam;
        ToWasmFpgaModuleRam : out T_ToWasmFpgaModuleRam;
        FromWasmFpgaMemory : in T_FromWasmFpgaMemory;
        ToWasmFpgaMemory : out T_ToWasmFpgaMemory
    );
end;

architecture Behavioural of InstructionSelect is

    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(63 downto 0);
    signal OperandB : std_logic_vector(63 downto 0);
    signal OperandC: std_logic_vector(31 downto 0);
    signal OperandAType : std_logic_vector(2 downto 0);
    signal OperandBType : std_logic_vector(2 downto 0);

begin

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          OperandA <= (others => '0');
          OperandAType <= (others => '0');
          OperandB <= (others => '0');
          OperandBType <= (others => '0');
          OperandC <= (others => '0');
          ToWasmFpgaStack <= (
              Run => '0',
              Action => (others => '0'),
              TypeValue => (others => '0'),
              HighValue => (others => '0'),
              LowValue => (others => '0'),
              MaxResults => (others => '0'),
              MaxLocals => (others => '0'),
              ReturnAddress => (others => '0'),
              ModuleInstanceUid => (others => '0'),
              LocalIndex => (others => '0')
          );
          ToWasmFpgaModuleRam <= (
              Run => '0',
              Address => (others => '0')
          );
          FromWasmFpgaInstruction <= (
              Address => (others => '0'),
              Trap => '0',
              Busy => '1'
          );
          PopFromStackState <= StateIdle;
          PushToStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                if (ToWasmFpgaInstruction.Run = '1') then
                    FromWasmFpgaInstruction.Busy <= '1';
                    ToWasmFpgaModuleRam.Address <= ToWasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                PopFromStack(PopFromStackState,
                             FromWasmFpgaStack,
                             ToWasmFpgaStack);
                if(PopFromStackState = StateEnd) then
                    OperandC <= FromWasmFpgaStack.LowValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                PopFromStack(PopFromStackState,
                             FromWasmFpgaStack,
                             ToWasmFpgaStack);
                if(PopFromStackState = StateEnd) then
                    OperandB(31 downto 0) <= FromWasmFpgaStack.LowValue;
                    OperandB(63 downto 32) <= FromWasmFpgaStack.HighValue;
                    OperandBType <= FromWasmFpgaStack.TypeValue;
                    State <= State2;
                end if;
            elsif (State = State2) then
                PopFromStack(PopFromStackState,
                             FromWasmFpgaStack,
                             ToWasmFpgaStack);
                if(PopFromStackState = StateEnd) then
                    OperandA(31 downto 0) <= FromWasmFpgaStack.LowValue;
                    OperandA(63 downto 32) <= FromWasmFpgaStack.HighValue;
                    OperandAType <= FromWasmFpgaStack.TypeValue;
                    State <= State3;
                end if;
            elsif (State = State3) then
                if (OperandC = x"00000000") then
                    ToWasmFpgaStack.LowValue <= OperandB(31 downto 0);
                    ToWasmFpgaStack.HighValue <= OperandB(63 downto 32);
                    ToWasmFpgaStack.TypeValue <= OperandBType;
                else
                    ToWasmFpgaStack.LowValue <= OperandA(31 downto 0);
                    ToWasmFpgaStack.HighValue <= OperandA(63 downto 32);
                    ToWasmFpgaStack.TypeValue <= OperandAType;
                end if;
                State <= State4;
            elsif (State = State4) then
                PushToStack(PushToStackState,
                            FromWasmFpgaStack,
                            ToWasmFpgaStack);
                if(PushToStackState = StateEnd) then
                    FromWasmFpgaInstruction.Address <= FromWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;