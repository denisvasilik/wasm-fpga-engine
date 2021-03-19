

-- ========== WebAssembly Store Block( StoreBlk) ========== 

-- This block describes the WebAssembly store block.
-- BUS: 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaStoreWshBn_Package.all;

entity StoreBlk_WasmFpgaStore is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : in std_logic_vector(23 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        DatIn : in std_logic_vector(31 downto 0);
        We : in std_logic;
        Stb : in std_logic;
        Cyc : in  std_logic_vector(0 downto 0);
        StoreBlk_DatOut : out std_logic_vector(31 downto 0);
        StoreBlk_Ack : out std_logic;
        StoreBlk_Unoccupied_Ack : out std_logic;
        Operation : out std_logic;
        Run : out std_logic;
        WRegPulse_ControlReg : out std_logic;
        Busy : in std_logic;
        ModuleInstanceUID : out std_logic_vector(31 downto 0);
        SectionUID : out std_logic_vector(31 downto 0);
        Idx : out std_logic_vector(31 downto 0);
        Address_ToBeRead : in std_logic_vector(31 downto 0);
        Address_Written : out std_logic_vector(31 downto 0)
     );
end StoreBlk_WasmFpgaStore;



architecture arch_for_synthesys of StoreBlk_WasmFpgaStore is

    -- ---------- block variables ---------- 
    signal PreMuxAck_Unoccupied : std_logic;
    signal UnoccupiedDec : std_logic_vector(1 downto 0);
    signal StoreBlk_PreDatOut : std_logic_vector(31 downto 0);
    signal StoreBlk_PreAck : std_logic;
    signal StoreBlk_Unoccupied_PreAck : std_logic;
    signal PreMuxDatOut_ControlReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ControlReg : std_logic;
    signal PreMuxDatOut_StatusReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_StatusReg : std_logic;
    signal PreMuxDatOut_ModuleInstanceUidReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ModuleInstanceUidReg : std_logic;
    signal PreMuxDatOut_SectionUidReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_SectionUidReg : std_logic;
    signal PreMuxDatOut_IdxReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_IdxReg : std_logic;
    signal PreMuxDatOut_AddressReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_AddressReg : std_logic;

    signal WriteDiff_ControlReg : std_logic;
    signal ReadDiff_ControlReg : std_logic;
     signal DelWriteDiff_ControlReg: std_logic;


    signal WriteDiff_StatusReg : std_logic;
    signal ReadDiff_StatusReg : std_logic;


    signal WriteDiff_ModuleInstanceUidReg : std_logic;
    signal ReadDiff_ModuleInstanceUidReg : std_logic;


    signal WriteDiff_SectionUidReg : std_logic;
    signal ReadDiff_SectionUidReg : std_logic;


    signal WriteDiff_IdxReg : std_logic;
    signal ReadDiff_IdxReg : std_logic;


    signal WriteDiff_AddressReg : std_logic;
    signal ReadDiff_AddressReg : std_logic;


    signal WReg_Operation : std_logic;
    signal WReg_Run : std_logic;
    signal WReg_ModuleInstanceUID : std_logic_vector(31 downto 0);
    signal WReg_SectionUID : std_logic_vector(31 downto 0);
    signal WReg_Idx : std_logic_vector(31 downto 0);
    signal WReg_Address_Written : std_logic_vector(31 downto 0);

begin 

    -- ---------- block DatOut mux ----------

    gen_unoccupied_ack : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_Unoccupied <= '0';
            UnoccupiedDec <= "00";
        elsif rising_edge(Clk) then
            UnoccupiedDec(0) <= UnoccupiedDec(1); 
            UnoccupiedDec(1)  <= (Cyc(0)  and Stb);
            PreMuxAck_Unoccupied <= UnoccupiedDec(1) and not UnoccupiedDec(0);
        end if;
    end process;

    StoreBlk_DatOut <= StoreBlk_PreDatOut;
    StoreBlk_Ack <=  StoreBlk_PreAck;
    StoreBlk_Unoccupied_Ack <= StoreBlk_Unoccupied_PreAck;

    mux_data_ack_out : process (Cyc, Adr, 
                                PreMuxDatOut_ControlReg,
                                PreMuxAck_ControlReg,
                                PreMuxDatOut_StatusReg,
                                PreMuxAck_StatusReg,
                                PreMuxDatOut_ModuleInstanceUidReg,
                                PreMuxAck_ModuleInstanceUidReg,
                                PreMuxDatOut_SectionUidReg,
                                PreMuxAck_SectionUidReg,
                                PreMuxDatOut_IdxReg,
                                PreMuxAck_IdxReg,
                                PreMuxDatOut_AddressReg,
                                PreMuxAck_AddressReg,
                                PreMuxAck_Unoccupied
                                )
    begin 
        StoreBlk_PreDatOut <= x"0000_0000"; -- default statements
        StoreBlk_PreAck <= '0'; 
        StoreBlk_Unoccupied_PreAck <= '0';
        if ( (Cyc(0) = '1') 
              and (unsigned(Adr) >= unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk) )
              and (unsigned(Adr) <= (unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk) + unsigned(WASMFPGASTORE_ADR_BLK_SIZE_StoreBlk) - 1)) )
        then 
            if ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTORE_ADR_ControlReg)) ) then
                 StoreBlk_PreDatOut <= PreMuxDatOut_ControlReg;
                StoreBlk_PreAck <= PreMuxAck_ControlReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTORE_ADR_StatusReg)) ) then
                 StoreBlk_PreDatOut <= PreMuxDatOut_StatusReg;
                StoreBlk_PreAck <= PreMuxAck_StatusReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTORE_ADR_ModuleInstanceUidReg)) ) then
                 StoreBlk_PreDatOut <= PreMuxDatOut_ModuleInstanceUidReg;
                StoreBlk_PreAck <= PreMuxAck_ModuleInstanceUidReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTORE_ADR_SectionUidReg)) ) then
                 StoreBlk_PreDatOut <= PreMuxDatOut_SectionUidReg;
                StoreBlk_PreAck <= PreMuxAck_SectionUidReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTORE_ADR_IdxReg)) ) then
                 StoreBlk_PreDatOut <= PreMuxDatOut_IdxReg;
                StoreBlk_PreAck <= PreMuxAck_IdxReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGASTORE_ADR_AddressReg)) ) then
                 StoreBlk_PreDatOut <= PreMuxDatOut_AddressReg;
                StoreBlk_PreAck <= PreMuxAck_AddressReg;
            else 
                StoreBlk_PreAck <= PreMuxAck_Unoccupied;
                StoreBlk_Unoccupied_PreAck <= PreMuxAck_Unoccupied;
            end if;
        end if;
    end process;


    -- ---------- block functions ---------- 


    -- .......... ControlReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ControlReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ControlReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_ControlReg) ) then 
            WriteDiff_ControlReg <=  We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            WriteDiff_ControlReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_ControlReg) ) then 
            ReadDiff_ControlReg <= not We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            ReadDiff_ControlReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_ControlReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
             DelWriteDiff_ControlReg <= '0'; 
            PreMuxAck_ControlReg <= '0';
            WReg_Operation <= '0';
            WReg_Run <= '0';
        elsif rising_edge(Clk) then
             DelWriteDiff_ControlReg <= WriteDiff_ControlReg;
            PreMuxAck_ControlReg <= WriteDiff_ControlReg or ReadDiff_ControlReg; 
            if (WriteDiff_ControlReg = '1') then
                if (Sel(0) = '1') then WReg_Operation <= DatIn(1); end if;
                if (Sel(0) = '1') then WReg_Run <= DatIn(0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ControlReg0 : process (
            WReg_Operation,
            WReg_Run
            )
    begin 
         PreMuxDatOut_ControlReg <= x"0000_0000";
         PreMuxDatOut_ControlReg(1) <= WReg_Operation;
         PreMuxDatOut_ControlReg(0) <= WReg_Run;
    end process;



    WRegPulse_ControlReg <= DelWriteDiff_ControlReg;

    Operation <= WReg_Operation;
    Run <= WReg_Run;

    -- .......... StatusReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_StatusReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_StatusReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_StatusReg) ) then 
            WriteDiff_StatusReg <=  We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            WriteDiff_StatusReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_StatusReg) ) then 
            ReadDiff_StatusReg <= not We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            ReadDiff_StatusReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_StatusReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_StatusReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_StatusReg <= WriteDiff_StatusReg or ReadDiff_StatusReg; 
        end if;
    end process;

    mux_premuxdatout_StatusReg0 : process (
            Busy
            )
    begin 
         PreMuxDatOut_StatusReg <= x"0000_0000";
         PreMuxDatOut_StatusReg(0) <= Busy;
    end process;





    -- .......... ModuleInstanceUidReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ModuleInstanceUidReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ModuleInstanceUidReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_ModuleInstanceUidReg) ) then 
            WriteDiff_ModuleInstanceUidReg <=  We and Stb and Cyc(0) and not PreMuxAck_ModuleInstanceUidReg;
        else
            WriteDiff_ModuleInstanceUidReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_ModuleInstanceUidReg) ) then 
            ReadDiff_ModuleInstanceUidReg <= not We and Stb and Cyc(0) and not PreMuxAck_ModuleInstanceUidReg;
        else
            ReadDiff_ModuleInstanceUidReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_ModuleInstanceUidReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_ModuleInstanceUidReg <= '0';
            WReg_ModuleInstanceUID <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_ModuleInstanceUidReg <= WriteDiff_ModuleInstanceUidReg or ReadDiff_ModuleInstanceUidReg; 
            if (WriteDiff_ModuleInstanceUidReg = '1') then
                if (Sel(3) = '1') then WReg_ModuleInstanceUID(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_ModuleInstanceUID(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_ModuleInstanceUID(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_ModuleInstanceUID(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ModuleInstanceUidReg0 : process (
            WReg_ModuleInstanceUID
            )
    begin 
         PreMuxDatOut_ModuleInstanceUidReg <= x"0000_0000";
         PreMuxDatOut_ModuleInstanceUidReg(31 downto 0) <= WReg_ModuleInstanceUID;
    end process;




    ModuleInstanceUID <= WReg_ModuleInstanceUID;

    -- .......... SectionUidReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_SectionUidReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_SectionUidReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_SectionUidReg) ) then 
            WriteDiff_SectionUidReg <=  We and Stb and Cyc(0) and not PreMuxAck_SectionUidReg;
        else
            WriteDiff_SectionUidReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_SectionUidReg) ) then 
            ReadDiff_SectionUidReg <= not We and Stb and Cyc(0) and not PreMuxAck_SectionUidReg;
        else
            ReadDiff_SectionUidReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_SectionUidReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_SectionUidReg <= '0';
            WReg_SectionUID <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_SectionUidReg <= WriteDiff_SectionUidReg or ReadDiff_SectionUidReg; 
            if (WriteDiff_SectionUidReg = '1') then
                if (Sel(3) = '1') then WReg_SectionUID(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_SectionUID(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_SectionUID(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_SectionUID(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_SectionUidReg0 : process (
            WReg_SectionUID
            )
    begin 
         PreMuxDatOut_SectionUidReg <= x"0000_0000";
         PreMuxDatOut_SectionUidReg(31 downto 0) <= WReg_SectionUID;
    end process;




    SectionUID <= WReg_SectionUID;

    -- .......... IdxReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_IdxReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_IdxReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_IdxReg) ) then 
            WriteDiff_IdxReg <=  We and Stb and Cyc(0) and not PreMuxAck_IdxReg;
        else
            WriteDiff_IdxReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_IdxReg) ) then 
            ReadDiff_IdxReg <= not We and Stb and Cyc(0) and not PreMuxAck_IdxReg;
        else
            ReadDiff_IdxReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_IdxReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_IdxReg <= '0';
            WReg_Idx <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_IdxReg <= WriteDiff_IdxReg or ReadDiff_IdxReg; 
            if (WriteDiff_IdxReg = '1') then
                if (Sel(3) = '1') then WReg_Idx(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_Idx(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_Idx(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_Idx(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_IdxReg0 : process (
            WReg_Idx
            )
    begin 
         PreMuxDatOut_IdxReg <= x"0000_0000";
         PreMuxDatOut_IdxReg(31 downto 0) <= WReg_Idx;
    end process;




    Idx <= WReg_Idx;

    -- .......... AddressReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_AddressReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_AddressReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_AddressReg) ) then 
            WriteDiff_AddressReg <=  We and Stb and Cyc(0) and not PreMuxAck_AddressReg;
        else
            WriteDiff_AddressReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGASTORE_ADR_AddressReg) ) then 
            ReadDiff_AddressReg <= not We and Stb and Cyc(0) and not PreMuxAck_AddressReg;
        else
            ReadDiff_AddressReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_AddressReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_AddressReg <= '0';
            WReg_Address_Written <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_AddressReg <= WriteDiff_AddressReg or ReadDiff_AddressReg; 
            if (WriteDiff_AddressReg = '1') then
                if (Sel(3) = '1') then WReg_Address_Written(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_Address_Written(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_Address_Written(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_Address_Written(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_AddressReg0 : process (
            Address_ToBeRead
            )
    begin 
         PreMuxDatOut_AddressReg <= x"0000_0000";
         PreMuxDatOut_AddressReg(31 downto 0) <= Address_ToBeRead;
    end process;




    Address_Written <= WReg_Address_Written;


end architecture;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaStoreWshBn_Package.all;

-- ========== Wishbone for WasmFpgaStore (WasmFpgaStoreWishbone) ========== 

entity WasmFpgaStoreWshBn is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        WasmFpgaStoreWshBnDn : in T_WasmFpgaStoreWshBnDn;
        WasmFpgaStoreWshBnUp : out T_WasmFpgaStoreWshBnUp;
        WasmFpgaStoreWshBn_UnOccpdRcrd : out T_WasmFpgaStoreWshBn_UnOccpdRcrd;
        WasmFpgaStoreWshBn_StoreBlk : out T_WasmFpgaStoreWshBn_StoreBlk;
        StoreBlk_WasmFpgaStoreWshBn : in T_StoreBlk_WasmFpgaStoreWshBn
     );
end WasmFpgaStoreWshBn;



architecture arch_for_synthesys of WasmFpgaStoreWshBn is

    component StoreBlk_WasmFpgaStore is
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            Adr : in std_logic_vector(23 downto 0);
            Sel : in std_logic_vector(3 downto 0);
            DatIn : in std_logic_vector(31 downto 0);
            We : in std_logic;
            Stb : in std_logic;
            Cyc : in  std_logic_vector(0 downto 0);
            StoreBlk_DatOut : out std_logic_vector(31 downto 0);
            StoreBlk_Ack : out std_logic;
            StoreBlk_Unoccupied_Ack : out std_logic;
            Operation : out std_logic;
            Run : out std_logic;
            WRegPulse_ControlReg : out std_logic;
            Busy : in std_logic;
            ModuleInstanceUID : out std_logic_vector(31 downto 0);
            SectionUID : out std_logic_vector(31 downto 0);
            Idx : out std_logic_vector(31 downto 0);
            Address_ToBeRead : in std_logic_vector(31 downto 0);
            Address_Written : out std_logic_vector(31 downto 0)
         );
    end component; 


    -- ---------- internal wires ----------

    signal Sel : std_logic_vector(3 downto 0);
    signal StoreBlk_DatOut : std_logic_vector(31 downto 0);
    signal StoreBlk_Ack : std_logic;
    signal StoreBlk_Unoccupied_Ack : std_logic;


begin 


    -- ---------- Connect register instances ----------

    i_StoreBlk_WasmFpgaStore :  StoreBlk_WasmFpgaStore
     port map (
        Clk => Clk,
        Rst => Rst,
        Adr => WasmFpgaStoreWshBnDn.Adr,
        Sel => Sel,
        DatIn => WasmFpgaStoreWshBnDn.DatIn,
        We =>  WasmFpgaStoreWshBnDn.We,
        Stb => WasmFpgaStoreWshBnDn.Stb,
        Cyc => WasmFpgaStoreWshBnDn.Cyc,
        StoreBlk_DatOut => StoreBlk_DatOut,
        StoreBlk_Ack => StoreBlk_Ack,
        StoreBlk_Unoccupied_Ack => StoreBlk_Unoccupied_Ack,
        Operation => WasmFpgaStoreWshBn_StoreBlk.Operation,
        Run => WasmFpgaStoreWshBn_StoreBlk.Run,
        WRegPulse_ControlReg => WasmFpgaStoreWshBn_StoreBlk.WRegPulse_ControlReg,
        Busy => StoreBlk_WasmFpgaStoreWshBn.Busy,
        ModuleInstanceUID => WasmFpgaStoreWshBn_StoreBlk.ModuleInstanceUID,
        SectionUID => WasmFpgaStoreWshBn_StoreBlk.SectionUID,
        Idx => WasmFpgaStoreWshBn_StoreBlk.Idx,
        Address_ToBeRead => StoreBlk_WasmFpgaStoreWshBn.Address_ToBeRead,
        Address_Written => WasmFpgaStoreWshBn_StoreBlk.Address_Written
     );


    Sel <= WasmFpgaStoreWshBnDn.Sel;                                                      

    WasmFpgaStoreWshBn_UnOccpdRcrd.forRecord_Adr <= WasmFpgaStoreWshBnDn.Adr;
    WasmFpgaStoreWshBn_UnOccpdRcrd.forRecord_Sel <= Sel;
    WasmFpgaStoreWshBn_UnOccpdRcrd.forRecord_We <= WasmFpgaStoreWshBnDn.We;
    WasmFpgaStoreWshBn_UnOccpdRcrd.forRecord_Cyc <= WasmFpgaStoreWshBnDn.Cyc;

    -- ---------- Or all DataOuts and Acks of blocks ----------

     WasmFpgaStoreWshBnUp.DatOut <= 
        StoreBlk_DatOut;

     WasmFpgaStoreWshBnUp.Ack <= 
        StoreBlk_Ack;

     WasmFpgaStoreWshBn_UnOccpdRcrd.Unoccupied_Ack <= 
        StoreBlk_Unoccupied_Ack;





end architecture;



