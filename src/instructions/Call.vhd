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
        FromWasmFpgaInvocation : in T_WasmFpgaInvocation_WasmFpgaInstruction;
        ToWasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation;
        FromWasmFpgaStack : in T_WasmFpgaStack_WasmFpgaInstruction;
        ToWasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack;
        FromWasmFpgaModuleRam : in T_WasmFpgaModuleRam_WasmFpgaInstruction;
        ToWasmFpgaModuleRam : buffer T_WasmFpgaInstruction_WasmFpgaModuleRam;
        FromWasmFpgaMemory : in T_WasmFpgaMemory_WasmFpgaInstruction;
        ToWasmFpgaMemory : out T_WasmFpgaInstruction_WasmFpgaMemory;
        FromWasmFpgaStore : in T_FromWasmFpgaStore;
        ToWasmFpgaStore : out T_ToWasmFpgaStore
    );
end;

architecture InstructionCallArchitecture of InstructionCall is

    signal Rst : std_logic;
    signal State : std_logic_vector(15 downto 0);
    signal ReadUnsignedLEB128State : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal ActivationFrameStackState : std_logic_vector(15 downto 0);
    signal StoreState : std_logic_vector(15 downto 0);
    signal CurrentByte : std_logic_vector(7 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);
    signal NumberOfParameters : std_logic_vector(31 downto 0);
    signal FuncIdx : std_logic_vector(31 downto 0);
    signal ReturnAddress : std_logic_vector(23 downto 0);
    signal ModuleInstanceUid : std_logic_vector(31 downto 0);

begin

    Rst <= not nRst;

    ToWasmFpgaMemory.Run <= '0';
    ToWasmFpgaMemory.Address <= (others => '0');
    ToWasmFpgaMemory.WriteData <= (others => '0');
    ToWasmFpgaMemory.WriteEnable <= '0';

    ModuleInstanceUid <= FromWasmFpgaInvocation.ModuleInstanceUid;

    process (Clk, Rst) is
    begin
        if (Rst = '1') then
          FuncIdx <= (others => '0');
          CurrentByte <= (others => '0');
          DecodedValue <= (others => '0');
          NumberOfParameters <= (others => '0');
          ReturnAddress <= (others => '0');
          -- Stack
          ToWasmFpgaStack.Run <= '0';
          ToWasmFpgaStack.Action <= (others => '0');
          ToWasmFpgaStack.TypeValue <= (others => '0');
          ToWasmFpgaStack.HighValue <= (others => '0');
          ToWasmFpgaStack.LowValue <= (others => '0');
          ToWasmFpgaStack.MaxResults <= (others => '0');
          ToWasmFpgaStack.MaxLocals <= (others => '0');
          ToWasmFpgaStack.ReturnAddress <= (others => '0');
          -- Module
          ToWasmFpgaModuleRam.Run <= '0';
          ToWasmFpgaModuleRam.Address <= (others => '0');
          ToWasmFpgaInvocation.Address <= (others => '0');
          ToWasmFpgaInvocation.Trap <= '0';
          ToWasmFpgaInvocation.Busy <= '1';
          -- Store
          ToWasmFpgaStore.ModuleInstanceUid <= (others => '0');
          ToWasmFpgaStore.SectionUID <= (others => '0');
          ToWasmFpgaStore.Idx <= (others => '0');
          ToWasmFpgaStore.Run <= '0';
          -- States
          ReadUnsignedLEB128State <= StateIdle;
          ReadFromModuleRamState <= StateIdle;
          ActivationFrameStackState <= StateIdle;
          StoreState <= StateIdle;
          State <= StateIdle;
        elsif rising_edge(Clk) then
            if (State = StateIdle) then
                ToWasmFpgaInvocation.Busy <= '0';
                if (FromWasmFpgaInvocation.Run = '1') then
                    ToWasmFpgaInvocation.Busy <= '1';
                    ToWasmFpgaModuleRam.Address <= FromWasmFpgaInvocation.Address;
                    State <= State0;
                end if;
            elsif (State = State0) then
                -- Read function idx parameter from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        FromWasmFpgaModuleRam,
                        ToWasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    -- Use function idx to get address of function section's
                    -- index to type section.
                    ToWasmFpgaStore.ModuleInstanceUid <= ModuleInstanceUid;
                    ToWasmFpgaStore.SectionUID <= SECTION_UID_FUNCTION;
                    ToWasmFpgaStore.Idx <= DecodedValue;
                    FuncIdx <= DecodedValue;
                    ReturnAddress <= ToWasmFpgaModuleRam.Address;
                    State <= State1;
                end if;
            elsif(State = State1) then
                ReadModuleAddressFromStore(StoreState,
                                           ToWasmFpgaStore,
                                           FromWasmFpgaStore);
                if (StoreState = StateEnd) then
                    -- Function section address of function's type idx
                    ToWasmFpgaModuleRam.Address <= FromWasmFpgaStore.Address;

                    State <= State2;
                end if;
            elsif (State = State2) then
                -- Read function's type idx from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        FromWasmFpgaModuleRam,
                        ToWasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    -- Use function's type idx to get address of type idx from
                    -- type section.
                    ToWasmFpgaStore.ModuleInstanceUid <= ModuleInstanceUid;
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
                    ToWasmFpgaModuleRam.Address <= FromWasmFpgaStore.Address;
                    State <= State4;
                end if;
            elsif (State = State4) then
                -- Read function's number of parameters from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        FromWasmFpgaModuleRam,
                        ToWasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    NumberOfParameters <= DecodedValue;
                    ToWasmFpgaModuleRam.Address <=
                        std_logic_vector(unsigned(ToWasmFpgaModuleRam.Address) +
                                         unsigned(DecodedValue(23 downto 0)));
                    State <= State5;
                end if;
            elsif (State = State5) then
                -- Read function's number of results from module RAM
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                        ReadFromModuleRamState,
                        DecodedValue,
                        CurrentByte,
                        FromWasmFpgaModuleRam,
                        ToWasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    ToWasmFpgaStack.MaxResults <= DecodedValue;
                    ToWasmFpgaStack.ModuleInstanceUid <= ModuleInstanceUid;
                    ToWasmFpgaStack.MaxLocals <= NumberOfParameters;
                    ToWasmFpgaStack.ReturnAddress <= std_logic_vector(resize(
                        unsigned(ReturnAddress),
                        ToWasmFpgaStack.ReturnAddress'LENGTH
                    ));
                    State <= State6;
                end if;
            elsif (State = State6) then
                CreateActivationFrame(ActivationFrameStackState,
                                      ToWasmFpgaStack,
                                      FromWasmFpgaStack);
                if(ActivationFrameStackState = StateEnd) then
                    -- Use function idx to get code section address
                    ToWasmFpgaStore.ModuleInstanceUid <= ModuleInstanceUid;
                    ToWasmFpgaStore.SectionUID <= SECTION_UID_FUNCTION;
                    ToWasmFpgaStore.Idx <= FuncIdx;
                    State <= State7;
                end if;
            elsif (State = State7) then
                ReadModuleAddressFromStore(StoreState,
                                           ToWasmFpgaStore,
                                           FromWasmFpgaStore);
                if (StoreState = StateEnd) then
                    -- Jump to address of called function
                    ToWasmFpgaInvocation.Address <= FromWasmFpgaStore.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;