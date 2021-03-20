library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;

--
-- call
--
entity InstructionCall is
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
        WasmFpgaInstruction_WasmFpgaMemory : out T_WasmFpgaInstruction_WasmFpgaMemory;
        WasmFpgaStore_WasmFpgaInstruction : in T_FromWasmFpgaStore;
        WasmFpgaInstruction_WasmFpgaStore : out T_ToWasmFpgaStore
    );
end;

architecture InstructionCallArchitecture of InstructionCall is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal ReadUnsignedLEB128State : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);

    signal CurrentByte : std_logic_vector(7 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);

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
          WasmFpgaInstruction_WasmFpgaStack.Action <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.TypeValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.HighValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.LowValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '0';
          WasmFpgaInstruction_WasmFpgaModuleRam.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Trap <= '0';
          WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
          CurrentByte <= (others => '0');
          DecodedValue <= (others => '0');
          ReadUnsignedLEB128State <= StateIdle;
          ReadFromModuleRamState <= StateIdle;
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
                -- Read function idx parameter from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        WasmFpgaModuleRam_WasmFpgaInstruction,
                        WasmFpgaInstruction_WasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    State <= State1;
                    WasmFpgaInstruction_WasmFpgaStack.LowValue <= DecodedValue;
                end if;
            elsif (State = State1) then
                -- Use function idx to get type section address from store
            elsif (State = State2) then
                -- Get number of parameters and pop them from stack
                -- PopFromStack(PopFromStackState,
                --              WasmFpgaInstruction_WasmFpgaStack,
                --              WasmFpgaStack_WasmFpgaInstruction);
                -- if(PopFromStackState = StateEnd) then
                --     State <= State1;
                -- end if;
            elsif (State = State3) then
                -- Create new stack frame and push parameters onto stack
            elsif (State = State4) then
                -- Use function idx to get code section address
            elsif (State = State5) then
                -- Jump to address of function to call
                WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;
                State <= StateIdle;
            end if;
        end if;
    end process;

end;