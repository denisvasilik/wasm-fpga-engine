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
        ToWasmFpgaInstruction : in T_ToWasmFpgaInstruction;
        FromWasmFpgaInstruction : out T_FromWasmFpgaInstruction;
        FromWasmFpgaStack : in T_FromWasmFpgaStack;
        ToWasmFpgaStack : out T_ToWasmFpgaStack;
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam;
        ToWasmFpgaModuleRam : buffer T_ToWasmFpgaModuleRam;
        FromWasmFpgaMemory : in T_FromWasmFpgaMemory;
        ToWasmFpgaMemory : out T_ToWasmFpgaMemory
    );
end;

architecture Behavioural of InstructionI32Store is

    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(31 downto 0);
    signal OperandB : std_logic_vector(31 downto 0);

begin

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          OperandA <= (others => '0');
          OperandB <= (others => '0');
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
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                FromWasmFpgaInstruction.Busy <= '0';
                ToWasmFpgaMemory.Run <= '0';
                ToWasmFpgaMemory.WriteEnable <= '0';
                if (ToWasmFpgaInstruction.Run = '1') then
                    FromWasmFpgaInstruction.Busy <= '1';
                    ToWasmFpgaModuleRam.Address <= ToWasmFpgaInstruction.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                PopFromStack(PopFromStackState,
                             ToWasmFpgaStack,
                             FromWasmFpgaStack);
                if(PopFromStackState = StateEnd) then
                    OperandB <= FromWasmFpgaStack.LowValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                PopFromStack(PopFromStackState,
                             ToWasmFpgaStack,
                             FromWasmFpgaStack);
                if(PopFromStackState = StateEnd) then
                    OperandA <= FromWasmFpgaStack.LowValue;
                    State <= State2;
                end if;
            elsif (State = State2) then
                ToWasmFpgaMemory.Run <= '1';
                ToWasmFpgaMemory.WriteEnable <= '1';
                ToWasmFpgaMemory.WriteData <= OperandB;
                ToWasmFpgaMemory.Address <= OperandA(23 downto 0);
                State <= State3;
            elsif (State = State3) then
                ToWasmFpgaMemory.Run <= '0';
                State <= State4;
            elsif (State = State4) then
                State <= State5;
            elsif (State = State5) then
                State <= State6;
            elsif (State = State6) then
                if(FromWasmFpgaMemory.Busy = '0') then
                    FromWasmFpgaInstruction.Address <= ToWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;