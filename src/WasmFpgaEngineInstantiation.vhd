library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;
  use work.WasmFpgaStackWshBn_Package.all;


entity WasmFpgaEngineInstantiation is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Busy : out std_logic;
        Trap : out std_logic;
        ModuleInstanceUid : in std_logic_vector(31 downto 0);
        EntryPointAddress : out std_logic_vector(23 downto 0);
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam;
        ToWasmFpgaModuleRam : out T_ToWasmFpgaModuleRam;
        FromWasmFpgaStore : in T_FromWasmFpgaStore;
        ToWasmFpgaStore : out T_ToWasmFpgaStore;
        FromWasmFpgaStack : in T_FromWasmFpgaStack;
        ToWasmFpgaStack : out T_ToWasmFpgaStack
    );
end;

architecture Behavioural of WasmFpgaEngineInstantiation is

    signal LocalDeclCount : std_logic_vector(31 downto 0);
    signal State : std_logic_vector(15 downto 0);
    signal ActivationFrameState : std_logic_vector(15 downto 0);
    signal Read32UState : std_logic_vector(15 downto 0);
    signal ReadFromModuleRamState : std_logic_vector(15 downto 0);
    signal StoreState : std_logic_vector(15 downto 0);
    signal DecodedValue : std_logic_vector(31 downto 0);
    signal CurrentByte : std_logic_vector(7 downto 0);

    signal ToWasmFpgaStackBuf : T_ToWasmFpgaStack;
    signal ToWasmFpgaStoreBuf : T_ToWasmFpgaStore;
    signal ToWasmFpgaModuleRamBuf : T_ToWasmFpgaModuleRam;

begin

    ToWasmFpgaStack <= ToWasmFpgaStackBuf;
    ToWasmFpgaStore <= ToWasmFpgaStoreBuf;
    ToWasmFpgaModuleRam <= ToWasmFpgaModuleRamBuf;

  Instantiation : process (Clk, nRst) is
  begin
    if (nRst = '0') then
      Trap <= '0';
      LocalDeclCount <= (others => '0');
      DecodedValue <= (others => '0');
      CurrentByte <= (others => '0');
      EntryPointAddress <= (others => '0');
      -- Module
      ToWasmFpgaModuleRamBuf <= (
          Run => '0',
          Address => (others => '0')
      );
      -- Stack
      ToWasmFpgaStackBuf <= (
          Run => '0',
          Action => (others => '0'),
          HighValue => (others => '0'),
          LowValue => (others => '0'),
          TypeValue => (others => '0'),
          MaxLocals => (others => '0'),
          MaxResults => (others => '0'),
          ReturnAddress => (others => '0'),
          ModuleInstanceUid => (others => '0'),
          LocalIndex => (others => '0')
      );
      -- Store
      ToWasmFpgaStoreBuf <= (
          ModuleInstanceUid => (others => '0'),
          SectionUID => (others => '0'),
          Idx => (others => '0'),
          Run => '0'
      );
      -- States
      StoreState <= StateIdle;
      ReadFromModuleRamState <= StateIdle;
      Read32UState <= StateIdle;
      ActivationFrameState <= StateIdle;
      State <= StateIdle;
    elsif rising_edge(Clk) then
        if (State = StateIdle) then
            Busy <= '0';
            if (Run = '1') then
                Busy <= '1';
                State <= State0;
            end if;
        --
        -- RetrieveStartFunctionIdx
        --
        -- Use ModuleInstanceUid = 0, SectionUid = 8 (Start) and Idx = 0 in order
        -- to retrieve the function Idx of the start function.
        --
        elsif(State = State0) then
            ToWasmFpgaStoreBuf.ModuleInstanceUid <= ModuleInstanceUid;
            ToWasmFpgaStoreBuf.SectionUID <= SECTION_UID_START;
            ToWasmFpgaStoreBuf.Idx <= (others => '0');
            State <= State1;
        elsif(State = State1) then
            ReadModuleAddressFromStore(StoreState,
                                       ToWasmFpgaStoreBuf,
                                       FromWasmFpgaStore);
            if (StoreState = StateEnd) then
                -- Start section size address
                ToWasmFpgaModuleRamBuf.Address <= FromWasmFpgaStore.Address;
                State <= State2;
            end if;
        elsif(State = State2) then
            -- Read section size
            ReadUnsignedLEB128(Read32UState,
                               ReadFromModuleRamState,
                               DecodedValue,
                               CurrentByte,
                               FromWasmFpgaModuleRam,
                               ToWasmFpgaModuleRamBuf);
            if (Read32UState = StateEnd) then
                State <= State4;
            end if;
        elsif(State = State4) then
            -- Read start funx idx
            ReadUnsignedLEB128(Read32UState,
                               ReadFromModuleRamState,
                               DecodedValue,
                               CurrentByte,
                               FromWasmFpgaModuleRam,
                               ToWasmFpgaModuleRamBuf);
            if (Read32UState = StateEnd) then
                State <= State5;
            end if;
        --
        -- RetrieveStartFunctionAddress
        --
        -- Use ModuleInstanceUid = 0, SectionUid = 10 (Code) and function Idx of
        -- start function to get address of start function body.
        --
        elsif(State = State5) then
            ToWasmFpgaStoreBuf.ModuleInstanceUid <= ModuleInstanceUid;
            ToWasmFpgaStoreBuf.SectionUID <= SECTION_UID_CODE;
            ToWasmFpgaStoreBuf.Idx <= DecodedValue; -- Use start function idx
            State <= State6;
        elsif(State = State6) then
            ReadModuleAddressFromStore(StoreState,
                                       ToWasmFpgaStoreBuf,
                                       FromWasmFpgaStore);
            if (StoreState = StateEnd) then
                -- Start section size address
                ToWasmFpgaModuleRamBuf.Address <= FromWasmFpgaStore.Address;
                State <= State8;
            end if;
        elsif(State = State8) then
            -- Read function body size
            ReadUnsignedLEB128(Read32UState,
                               ReadFromModuleRamState,
                               DecodedValue,
                               CurrentByte,
                               FromWasmFpgaModuleRam,
                               ToWasmFpgaModuleRamBuf);
            if (Read32UState = StateEnd) then
                State <= State9;
            end if;
        --
        -- CreateInitialActivationFrame
        --
        elsif(State = State9) then
            -- Ignore function body size
            -- Read local decl count
            ReadUnsignedLEB128(Read32UState,
                               ReadFromModuleRamState,
                               DecodedValue,
                               CurrentByte,
                               FromWasmFpgaModuleRam,
                               ToWasmFpgaModuleRamBuf);
            if (Read32UState = StateEnd) then
                State <= State10;
            end if;
        elsif(State = State10) then
            if (DecodedValue = x"00000000") then
                ToWasmFpgaStackBuf.MaxResults <= (others => '0');
                ToWasmFpgaStackBuf.ModuleInstanceUid <= ModuleInstanceUid;
                ToWasmFpgaStackBuf.MaxLocals <= (others => '0');
                ToWasmFpgaStackBuf.ReturnAddress <= (others => '0');
                State <= State11;
            else
                -- The start function type must be [] -> []
                Trap <= '1';
            end if;
        elsif (State = State11) then
            -- Create activation frame
            CreateActivationFrame(ActivationFrameState,
                                  FromWasmFpgaStack,
                                  ToWasmFpgaStackBuf);
            if (ActivationFrameState = StateEnd) then
                EntryPointAddress <= FromWasmFpgaModuleRam.Address;
                Busy <= '0';
                State <= StateIdle;
            end if;
        end if;
    end if;
  end process;

end;