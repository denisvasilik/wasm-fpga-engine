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
        ToWasmFpgaInstruction : in T_ToWasmFpgaInstruction;
        FromWasmFpgaInstruction : out T_FromWasmFpgaInstruction;
        FromWasmFpgaStack : in T_FromWasmFpgaStack;
        ToWasmFpgaStack : out T_ToWasmFpgaStack;
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam;
        ToWasmFpgaModuleRam : buffer T_ToWasmFpgaModuleRam;
        FromWasmFpgaMemory : in T_FromWasmFpgaMemory;
        ToWasmFpgaMemory : out T_ToWasmFpgaMemory;
        FromWasmFpgaStore : in T_FromWasmFpgaStore;
        ToWasmFpgaStore : out T_ToWasmFpgaStore
    );
end;

architecture Behavioural of InstructionCall is

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

    ToWasmFpgaMemory <= (
        Run => '0',
        Address => (others => '0'),
        WriteData => (others => '0'),
        WriteEnable => '0'
    );

    ModuleInstanceUid <= ToWasmFpgaInstruction.ModuleInstanceUid;

    process (Clk, nRst) is
    begin
        if (nRst = '0') then
          FuncIdx <= (others => '0');
          CurrentByte <= (others => '0');
          DecodedValue <= (others => '0');
          NumberOfParameters <= (others => '0');
          ReturnAddress <= (others => '0');
          -- Stack
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
          -- Module
          ToWasmFpgaModuleRam <= (
              Run => '0',
              Address => (others => '0')
          );
          -- Invocation
          FromWasmFpgaInstruction <= (
              Address => (others => '0'),
              Trap => '0',
              Busy => '1'
          );
          -- Store
          ToWasmFpgaStore <= (
              ModuleInstanceUid => (others => '0'),
              SectionUID => (others => '0'),
              Idx => (others => '0'),
              Run => '0'
          );
          -- States
          ReadUnsignedLEB128State <= StateIdle;
          ReadFromModuleRamState <= StateIdle;
          ActivationFrameStackState <= StateIdle;
          StoreState <= StateIdle;
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
                    ToWasmFpgaStore.SectionUID <= SECTION_UID_CODE;
                    ToWasmFpgaStore.Idx <= FuncIdx;
                    State <= State7;
                end if;
            elsif (State = State7) then
                -- Read calling function's address from store
                ReadModuleAddressFromStore(StoreState,
                                           ToWasmFpgaStore,
                                           FromWasmFpgaStore);
                if (StoreState = StateEnd) then
                    ToWasmFpgaModuleRam.Address <= FromWasmFpgaStore.Address;
                    State <= State8;
                end if;
            elsif (State = State8) then
                -- Read function's body size
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                                   ReadFromModuleRamState,
                                   DecodedValue,
                                   CurrentByte,
                                   FromWasmFpgaModuleRam,
                                   ToWasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    State <= State9;
                end if;
            elsif (State = State9) then
                -- Read function's decl count
                ReadUnsignedLEB128(ReadUnsignedLEB128State,
                                   ReadFromModuleRamState,
                                   DecodedValue,
                                   CurrentByte,
                                   FromWasmFpgaModuleRam,
                                   ToWasmFpgaModuleRam);
                if(ReadUnsignedLEB128State = StateEnd) then
                    -- Jump to address of called function
                    FromWasmFpgaInstruction.Address <= ToWasmFpgaModuleRam.Address;
                    State <= StateIdle;
                end if;
            end if;
        end if;
    end process;

end;