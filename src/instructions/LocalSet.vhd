library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- local.set
--
-- Execution: https://www.w3.org/TR/wasm-core-1/#exec-local-set
-- Validation: https://www.w3.org/TR/wasm-core-1/#valid-local-set
--
entity InstructionLocalSet is
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

architecture InstructionLocalSetArchitecture of InstructionLocalSet is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal SetLocalFromStackState : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);

begin

    Rst <= not nRst;

    -- Memory
    WasmFpgaInstruction_WasmFpgaMemory.Run <= '0';
    WasmFpgaInstruction_WasmFpgaMemory.Address <= (others => '0');
    WasmFpgaInstruction_WasmFpgaMemory.WriteData <= (others => '0');
    WasmFpgaInstruction_WasmFpgaMemory.WriteEnable <= '0';

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
          -- FSM States
          SetLocalFromStackState <= (others => '0');
          PopFromStackState <= (others => '0');
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
                    WasmFpgaInstruction_WasmFpgaStack.LowValue <= WasmFpgaStack_WasmFpgaInstruction.LowValue;
                    WasmFpgaInstruction_WasmFpgaStack.HighValue <= WasmFpgaStack_WasmFpgaInstruction.HighValue;
                    WasmFpgaInstruction_WasmFpgaStack.TypeValue <= WasmFpgaStack_WasmFpgaInstruction.TypeValue;
                    State <= State1;
                end if;
            elsif (State = State1) then
                SetLocalFromStack(SetLocalFromStackState,
                                  WasmFpgaInstruction_WasmFpgaStack,
                                  WasmFpgaStack_WasmFpgaInstruction);
                if(SetLocalFromStackState = StateEnd) then
                    State <= State2;
                end if;
            elsif (State = State2) then
                WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;
                State <= StateIdle;
            end if;
        end if;
    end process;

end architecture;