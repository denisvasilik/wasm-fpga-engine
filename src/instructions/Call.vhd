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
        FromWasmFpgaStore : in T_FromWasmFpgaStore;
        ToWasmFpgaStore : out T_ToWasmFpgaStore
    );
end;

architecture InstructionCallArchitecture of InstructionCall is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal ReadUnsignedLEB128State : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal PopFromStackState : std_logic_vector(15 downto 0);
    signal PushToStackState : std_logic_vector(15 downto 0);
    signal StoreState : std_logic_vector(15 downto 0);
    signal CurrentByte : std_logic_vector(7 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);
    signal NumberOfParameters : std_logic_vector(31 downto 0);
    signal NumberOfResults : std_logic_vector(31 downto 0);
    signal FuncIdx : std_logic_vector(31 downto 0);

begin

    Rst <= not nRst;

    WasmFpgaInstruction_WasmFpgaMemory.Run <= '0';
    WasmFpgaInstruction_WasmFpgaMemory.Address <= (others => '0');
    WasmFpgaInstruction_WasmFpgaMemory.WriteData <= (others => '0');
    WasmFpgaInstruction_WasmFpgaMemory.WriteEnable <= '0';

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
          FuncIdx <= (others => '0');
          CurrentByte <= (others => '0');
          DecodedValue <= (others => '0');
          NumberOfParameters <= (others => '0');
          NumberOfResults <= (others => '0');
          -- Stack
          WasmFpgaInstruction_WasmFpgaStack.Run <= '0';
          WasmFpgaInstruction_WasmFpgaStack.Action <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.TypeValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.HighValue <= (others => '0');
          WasmFpgaInstruction_WasmFpgaStack.LowValue <= (others => '0');
          -- Module
          WasmFpgaInstruction_WasmFpgaModuleRam.Run <= '0';
          WasmFpgaInstruction_WasmFpgaModuleRam.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Address <= (others => '0');
          WasmFpgaInstruction_WasmFpgaInvocation.Trap <= '0';
          WasmFpgaInstruction_WasmFpgaInvocation.Busy <= '1';
          -- Store
          ToWasmFpgaStore.ModuleInstanceUID <= (others => '0');
          ToWasmFpgaStore.SectionUID <= (others => '0');
          ToWasmFpgaStore.Idx <= (others => '0');
          ToWasmFpgaStore.Run <= '0';
          -- States
          ReadUnsignedLEB128State <= StateIdle;
          ReadFromModuleRamState <= StateIdle;
          PopFromStackState <= StateIdle;
          PushToStackState <= StateIdle;
          StoreState <= StateIdle;
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
                    -- Use function idx to get address of function section's
                    -- index to type section.
                    ToWasmFpgaStore.ModuleInstanceUID <= (others => '0');
                    ToWasmFpgaStore.SectionUID <= SECTION_UID_FUNCTION;
                    ToWasmFpgaStore.Idx <= DecodedValue;
                    FuncIdx <= DecodedValue;
                    State <= State1;
                end if;
            elsif(State = State1) then
                ReadModuleAddressFromStore(StoreState,
                                           ToWasmFpgaStore,
                                           FromWasmFpgaStore);
                if (StoreState = StateEnd) then
                    -- Function section address of function's type idx
                    WasmFpgaInstruction_WasmFpgaModuleRam.Address <= FromWasmFpgaStore.Address(23 downto 0);
                    State <= State2;
                end if;
            elsif (State = State2) then
                -- Read function's type idx from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        WasmFpgaModuleRam_WasmFpgaInstruction,
                        WasmFpgaInstruction_WasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    -- Use function's type idx to get address of type idx from type section
                    ToWasmFpgaStore.ModuleInstanceUID <= (others => '0');
                    ToWasmFpgaStore.SectionUID <= SECTION_UID_TYPE;
                    ToWasmFpgaStore.Idx <= DecodedValue;
                    State <= State3;
                end if;
            elsif (State = State3) then
                ReadModuleAddressFromStore(StoreState,
                                           ToWasmFpgaStore,
                                           FromWasmFpgaStore);
                if (StoreState = StateEnd) then
                    -- Type section address of function's type idx
                    WasmFpgaInstruction_WasmFpgaModuleRam.Address <= FromWasmFpgaStore.Address(23 downto 0);
                    State <= State4;
                end if;
            elsif (State = State4) then
                -- Read function's number of parameters from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        WasmFpgaModuleRam_WasmFpgaInstruction,
                        WasmFpgaInstruction_WasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    NumberOfParameters <= DecodedValue;
                    WasmFpgaInstruction_WasmFpgaModuleRam.Address <=
                        std_logic_vector(unsigned(WasmFpgaInstruction_WasmFpgaModuleRam.Address) +
                                         unsigned(DecodedValue(23 downto 0)));
                    State <= State5;
                end if;
            elsif (State = State5) then
                -- Read function's number of results from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        WasmFpgaModuleRam_WasmFpgaInstruction,
                        WasmFpgaInstruction_WasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    NumberOfResults <= DecodedValue;
                    State <= State6;
                end if;
            elsif (State = State6) then
                -- CreateActivationFrame(PopFromStackState,
                --                       WasmFpgaInstruction_WasmFpgaStack,
                --                       WasmFpgaStack_WasmFpgaInstruction);
                if(PopFromStackState = StateEnd) then
                    -- Use function idx to get code section address
                    ToWasmFpgaStore.ModuleInstanceUID <= (others => '0');
                    ToWasmFpgaStore.SectionUID <= SECTION_UID_FUNCTION;
                    ToWasmFpgaStore.Idx <= FuncIdx;
                    State <= State7;
                end if;
            elsif (State = State7) then
                -- Jump to address of called function
                WasmFpgaInstruction_WasmFpgaInvocation.Address <= WasmFpgaInstruction_WasmFpgaModuleRam.Address;
                State <= StateIdle;
            end if;
        end if;
    end process;

end;