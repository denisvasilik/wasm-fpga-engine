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

architecture InstructionI32MulArchitecture of InstructionI32Mul is

    signal Rst : std_logic;
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

    Rst <= not nRst;

    WasmFpgaInstruction_WasmFpgaMemory.Run <= '0';
    WasmFpgaInstruction_WasmFpgaMemory.Address <= (others => '0');
    WasmFpgaInstruction_WasmFpgaMemory.WriteData <= (others => '0');
    WasmFpgaInstruction_WasmFpgaMemory.WriteEnable <= '0';

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
          WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
          WasmFpgaInstruction_WasmFpgaStack.Action <= '0';
          WasmFpgaInstruction_WasmFpgaStack.TypeValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.HighValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.LowValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '0';
          WasmFpgaInstruction_WasmFpgaModuleRam.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Trap <= '0';
          WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
          PipelineStages <= x"7";
          PipelineCount <= (others => '0');
          OperandA <= (others => '0');
          OperandB <= (others => '0');
          PopFromStackState <= (others => '0');
          PushToStackState <= (others => '0');
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                PipelineCount <= x"0";
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
                if (PipelineCount = PipelineStages) then
                    WasmFpgaInstruction_WasmFpgaStack.LowValue <= Result;
                    State <= State3;
                else
                    PipelineCount <= PipelineCount + 1;
                end if;
            elsif (State = State3) then
                PushToStack(PushToStackState,
                            WasmFpgaInstruction_WasmFpgaStack,
                            WasmFpgaStack_WasmFpgaInstruction);
                if(PushToStackState = StateEnd) then
                    State <= State4;
                end if;
            elsif (State = State4) then
                WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;
                State <= StateIdle;
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

end architecture;