library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.mul
--
-- Return the result of multiplying i1​ and i2​ modulo 2N.
--
-- Operation: https://www.w3.org/TR/wasm-core-1/#op-imul
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-binop
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-binop
--
entity InstructionI32Mul is
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

architecture Behavioural of InstructionI32Mul is

    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(31 downto 0);
    signal OperandB : std_logic_vector(31 downto 0);
    signal Result : std_logic_vector(31 downto 0);
    signal PipelineStages : unsigned(3 downto 0);
    signal PipelineCount : unsigned(3 downto 0);

    component WasmFpgaMultiplier32Bit is
        port (
            CLK : in STD_LOGIC;
            A : in STD_LOGIC_VECTOR ( 31 downto 0 );
            B : in STD_LOGIC_VECTOR ( 31 downto 0 );
            P : out STD_LOGIC_VECTOR ( 31 downto 0 )
        );
    end component;

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
          PipelineStages <= x"7";
          PipelineCount <= (others => '0');
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
          PopFromStackState <= StateIdle;
          PushToStackState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                PipelineCount <= x"0";
                FromWasmFpgaInstruction.Busy <= '0';
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
                if (PipelineCount = PipelineStages) then
                    ToWasmFpgaStack.LowValue <= Result;
                    State <= State3;
                else
                    PipelineCount <= PipelineCount + 1;
                end if;
            elsif (State = State3) then
                PushToStack(PushToStackState,
                            ToWasmFpgaStack,
                            FromWasmFpgaStack);
                if(PushToStackState = StateEnd) then
                    FromWasmFpgaInstruction.Address <= ToWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

    WasmFpgaMultiplier32Bit_i : WasmFpgaMultiplier32Bit
        port map (
            CLK => Clk,
            A => OperandA,
            B => OperandB,
            P => Result
        );

end;