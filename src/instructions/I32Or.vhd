library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- i32.and
--
-- Return the bitwise conjunction of i1​ and i2​. .
--
entity InstructionI32Or is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        WasmFpgaInstruction_WasmFpgaModuleRam : out T_WasmFpgaInstruction_WasmFpgaModuleRam
    );
end entity;

architecture InstructionI32OrArchitecture of InstructionI32Or is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal OperandA : std_logic_vector(31 downto 0);
    signal OperandB : std_logic_vector(31 downto 0);

begin

    Rst <= not nRst;

    WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;

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
          OperandA <= (others => '0');
          OperandB <= (others => '0');
          Busy <= '1';
          PopFromStackState <= (others => '0');
          PushToStackState <= (others => '0');
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                Busy <= '0';
                if (Run = '1') then
                    Busy <= '1';
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
                WasmFpgaInstruction_WasmFpgaStack.LowValue <= i32_or(OperandA, OperandB);
                State <= State3;
            elsif (State = State3) then
                PushToStack(PushToStackState,
                            WasmFpgaInstruction_WasmFpgaStack,
                            WasmFpgaStack_WasmFpgaInstruction);
                if(PushToStackState = StateEnd) then
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end architecture;