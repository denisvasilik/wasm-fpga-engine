library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.load
--
-- Return the result of subtracting i2​ from i1​ modulo 2N.
--
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-load
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-load
--
entity InstructionI32Load is
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

architecture Behavioural of InstructionI32Load is

    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(31 downto 0);

begin

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          OperandA <= (others => '0');
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
          ToWasmFpgaMemory <= (
              Run => '0',
              Address => (others => '0'),
              WriteData => (others => '0'),
              WriteEnable => '0'
          );
          PopFromStackState <= StateIdle;
          PushToStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                ToWasmFpgaMemory.Run <= '0';
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
                    OperandA <= FromWasmFpgaStack.LowValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                ToWasmFpgaMemory.Run <= '1';
                ToWasmFpgaMemory.Address <= OperandA(23 downto 0);
                State <= State2;
            elsif (State = State2) then
                ToWasmFpgaMemory.Run <= '0';
                State <= State3;
            elsif (State = State3) then
                State <= State4;
            elsif (State = State4) then
                State <= State5;
            elsif (State = State5) then
                if(FromWasmFpgaMemory.Busy = '0') then
                    ToWasmFpgaStack.LowValue <= FromWasmFpgaMemory.ReadData;
                    State <= State6;
                end if;
            elsif (State = State6) then
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