

-- ========== WebAssembly Bus Block( BusBlk) ========== 

-- Register description of the WebAssembly Bus Block
-- BUS: 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaBusWshBn_Package.all;

entity BusBlk_WasmFpgaBus is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : in std_logic_vector(23 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        DatIn : in std_logic_vector(31 downto 0);
        We : in std_logic;
        Stb : in std_logic;
        Cyc : in  std_logic_vector(0 downto 0);
        BusBlk_DatOut : out std_logic_vector(31 downto 0);
        BusBlk_Ack : out std_logic;
        BusBlk_Unoccupied_Ack : out std_logic;
        ModuleArea_Adr : out std_logic_vector(23 downto 0);
        ModuleArea_Sel : out std_logic_vector(3 downto 0);
        ModuleArea_We : out std_logic;
        ModuleArea_Stb : out std_logic;
        ModuleArea_DatOut : out std_logic_vector(31 downto 0);
        ModuleArea_DatIn: in std_logic_vector(31 downto 0);
        ModuleArea_Ack : in std_logic;
        ModuleArea_Cyc : out std_logic;
        StackArea_Adr : out std_logic_vector(23 downto 0);
        StackArea_Sel : out std_logic_vector(3 downto 0);
        StackArea_We : out std_logic;
        StackArea_Stb : out std_logic;
        StackArea_DatOut : out std_logic_vector(31 downto 0);
        StackArea_DatIn: in std_logic_vector(31 downto 0);
        StackArea_Ack : in std_logic;
        StackArea_Cyc : out std_logic;
        StoreArea_Adr : out std_logic_vector(23 downto 0);
        StoreArea_Sel : out std_logic_vector(3 downto 0);
        StoreArea_We : out std_logic;
        StoreArea_Stb : out std_logic;
        StoreArea_DatOut : out std_logic_vector(31 downto 0);
        StoreArea_DatIn: in std_logic_vector(31 downto 0);
        StoreArea_Ack : in std_logic;
        StoreArea_Cyc : out std_logic;
        MemoryArea_Adr : out std_logic_vector(23 downto 0);
        MemoryArea_Sel : out std_logic_vector(3 downto 0);
        MemoryArea_We : out std_logic;
        MemoryArea_Stb : out std_logic;
        MemoryArea_DatOut : out std_logic_vector(31 downto 0);
        MemoryArea_DatIn: in std_logic_vector(31 downto 0);
        MemoryArea_Ack : in std_logic;
        MemoryArea_Cyc : out std_logic
     );
end BusBlk_WasmFpgaBus;



architecture arch_for_synthesys of BusBlk_WasmFpgaBus is

    -- ---------- block variables ---------- 
    signal PreMuxAck_Unoccupied : std_logic;
    signal UnoccupiedDec : std_logic_vector(1 downto 0);
    signal BusBlk_PreDatOut : std_logic_vector(31 downto 0);
    signal BusBlk_PreAck : std_logic;
    signal BusBlk_Unoccupied_PreAck : std_logic;
    signal PreMuxDatOut_ModuleArea : std_logic_vector(31 downto 0);
    signal PreMuxAck_ModuleArea : std_logic;
    signal PreMuxDatOut_StackArea : std_logic_vector(31 downto 0);
    signal PreMuxAck_StackArea : std_logic;
    signal PreMuxDatOut_StoreArea : std_logic_vector(31 downto 0);
    signal PreMuxAck_StoreArea : std_logic;
    signal PreMuxDatOut_MemoryArea : std_logic_vector(31 downto 0);
    signal PreMuxAck_MemoryArea : std_logic;


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

    BusBlk_DatOut <= BusBlk_PreDatOut;
    BusBlk_Ack <=  BusBlk_PreAck;
    BusBlk_Unoccupied_Ack <= BusBlk_Unoccupied_PreAck;

    mux_data_ack_out : process (Cyc, Adr, 
                                PreMuxDatOut_ModuleArea,
                                PreMuxAck_ModuleArea,
                                PreMuxDatOut_StackArea,
                                PreMuxAck_StackArea,
                                PreMuxDatOut_StoreArea,
                                PreMuxAck_StoreArea,
                                PreMuxDatOut_MemoryArea,
                                PreMuxAck_MemoryArea,
                                PreMuxAck_Unoccupied
                                )
    begin 
        BusBlk_PreDatOut <= x"0000_0000"; -- default statements
        BusBlk_PreAck <= '0'; 
        BusBlk_Unoccupied_PreAck <= '0';
        if ( (Cyc(0) = '1') 
              and (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BLK_BASE_BusBlk) )
              and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BLK_BASE_BusBlk) + unsigned(WASMFPGABUS_ADR_BLK_SIZE_BusBlk) - 1)) )
        then 
            if  ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_ModuleArea) )
                  and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_ModuleArea) + unsigned(WASMFPGABUS_ADR_SIZE_ModuleArea) - 1)) )
            then 
                BusBlk_PreDatOut <= PreMuxDatOut_ModuleArea;
                BusBlk_PreAck <= PreMuxAck_ModuleArea;
            elsif  ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_StackArea) )
                  and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_StackArea) + unsigned(WASMFPGABUS_ADR_SIZE_StackArea) - 1)) )
            then 
                BusBlk_PreDatOut <= PreMuxDatOut_StackArea;
                BusBlk_PreAck <= PreMuxAck_StackArea;
            elsif  ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_StoreArea) )
                  and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_StoreArea) + unsigned(WASMFPGABUS_ADR_SIZE_StoreArea) - 1)) )
            then 
                BusBlk_PreDatOut <= PreMuxDatOut_StoreArea;
                BusBlk_PreAck <= PreMuxAck_StoreArea;
            elsif  ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_MemoryArea) )
                  and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_MemoryArea) + unsigned(WASMFPGABUS_ADR_SIZE_MemoryArea) - 1)) )
            then 
                BusBlk_PreDatOut <= PreMuxDatOut_MemoryArea;
                BusBlk_PreAck <= PreMuxAck_MemoryArea;
            else
                BusBlk_PreAck <= PreMuxAck_Unoccupied;
                BusBlk_Unoccupied_PreAck <= PreMuxAck_Unoccupied;
            end if;
        end if;
    end process;


    -- ---------- block functions ---------- 

     PreMuxDatOut_ModuleArea <= ModuleArea_DatIn; 
     PreMuxAck_ModuleArea <= ModuleArea_Ack; 
    ModuleArea_Adr <= Adr; 
    ModuleArea_Sel <= Sel; 
    ModuleArea_We <= We; 
    ModuleArea_Stb <= Stb; 
    ModuleArea_DatOut <= DatIn; 
    ModuleArea_Cyc <= Cyc(0)
        when ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_ModuleArea) ) and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_ModuleArea) + unsigned(WasmFpgaBus_ADR_SIZE_ModuleArea) - 1)) )
        else '0';


     PreMuxDatOut_StackArea <= StackArea_DatIn; 
     PreMuxAck_StackArea <= StackArea_Ack; 
    StackArea_Adr <= Adr; 
    StackArea_Sel <= Sel; 
    StackArea_We <= We; 
    StackArea_Stb <= Stb; 
    StackArea_DatOut <= DatIn; 
    StackArea_Cyc <= Cyc(0)
        when ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_StackArea) ) and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_StackArea) + unsigned(WasmFpgaBus_ADR_SIZE_StackArea) - 1)) )
        else '0';


     PreMuxDatOut_StoreArea <= StoreArea_DatIn; 
     PreMuxAck_StoreArea <= StoreArea_Ack; 
    StoreArea_Adr <= Adr; 
    StoreArea_Sel <= Sel; 
    StoreArea_We <= We; 
    StoreArea_Stb <= Stb; 
    StoreArea_DatOut <= DatIn; 
    StoreArea_Cyc <= Cyc(0)
        when ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_StoreArea) ) and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_StoreArea) + unsigned(WasmFpgaBus_ADR_SIZE_StoreArea) - 1)) )
        else '0';


     PreMuxDatOut_MemoryArea <= MemoryArea_DatIn; 
     PreMuxAck_MemoryArea <= MemoryArea_Ack; 
    MemoryArea_Adr <= Adr; 
    MemoryArea_Sel <= Sel; 
    MemoryArea_We <= We; 
    MemoryArea_Stb <= Stb; 
    MemoryArea_DatOut <= DatIn; 
    MemoryArea_Cyc <= Cyc(0)
        when ( (unsigned(Adr) >= unsigned(WASMFPGABUS_ADR_BASE_MemoryArea) ) and (unsigned(Adr) <= (unsigned(WASMFPGABUS_ADR_BASE_MemoryArea) + unsigned(WasmFpgaBus_ADR_SIZE_MemoryArea) - 1)) )
        else '0';




end architecture;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaBusWshBn_Package.all;

-- ========== Wishbone for WasmFpgaBus (WasmFpgaBusWishbone) ========== 

entity WasmFpgaBusWshBn is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        WasmFpgaBusWshBnDn : in T_WasmFpgaBusWshBnDn;
        WasmFpgaBusWshBnUp : out T_WasmFpgaBusWshBnUp;
        WasmFpgaBusWshBn_UnOccpdRcrd : out T_WasmFpgaBusWshBn_UnOccpdRcrd;
        WasmFpgaBusWshBn_BusBlk : out T_WasmFpgaBusWshBn_BusBlk;
        BusBlk_WasmFpgaBusWshBn : in T_BusBlk_WasmFpgaBusWshBn
     );
end WasmFpgaBusWshBn;



architecture arch_for_synthesys of WasmFpgaBusWshBn is

    component BusBlk_WasmFpgaBus is
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            Adr : in std_logic_vector(23 downto 0);
            Sel : in std_logic_vector(3 downto 0);
            DatIn : in std_logic_vector(31 downto 0);
            We : in std_logic;
            Stb : in std_logic;
            Cyc : in  std_logic_vector(0 downto 0);
            BusBlk_DatOut : out std_logic_vector(31 downto 0);
            BusBlk_Ack : out std_logic;
            BusBlk_Unoccupied_Ack : out std_logic;
            ModuleArea_Adr : out std_logic_vector(23 downto 0);
            ModuleArea_Sel : out std_logic_vector(3 downto 0);
            ModuleArea_We : out std_logic;
            ModuleArea_Stb : out std_logic;
            ModuleArea_DatOut : out std_logic_vector(31 downto 0);
            ModuleArea_DatIn: in std_logic_vector(31 downto 0);
            ModuleArea_Ack : in std_logic;
            ModuleArea_Cyc : out std_logic;
            StackArea_Adr : out std_logic_vector(23 downto 0);
            StackArea_Sel : out std_logic_vector(3 downto 0);
            StackArea_We : out std_logic;
            StackArea_Stb : out std_logic;
            StackArea_DatOut : out std_logic_vector(31 downto 0);
            StackArea_DatIn: in std_logic_vector(31 downto 0);
            StackArea_Ack : in std_logic;
            StackArea_Cyc : out std_logic;
            StoreArea_Adr : out std_logic_vector(23 downto 0);
            StoreArea_Sel : out std_logic_vector(3 downto 0);
            StoreArea_We : out std_logic;
            StoreArea_Stb : out std_logic;
            StoreArea_DatOut : out std_logic_vector(31 downto 0);
            StoreArea_DatIn: in std_logic_vector(31 downto 0);
            StoreArea_Ack : in std_logic;
            StoreArea_Cyc : out std_logic;
            MemoryArea_Adr : out std_logic_vector(23 downto 0);
            MemoryArea_Sel : out std_logic_vector(3 downto 0);
            MemoryArea_We : out std_logic;
            MemoryArea_Stb : out std_logic;
            MemoryArea_DatOut : out std_logic_vector(31 downto 0);
            MemoryArea_DatIn: in std_logic_vector(31 downto 0);
            MemoryArea_Ack : in std_logic;
            MemoryArea_Cyc : out std_logic
         );
    end component; 


    -- ---------- internal wires ----------

    signal Sel : std_logic_vector(3 downto 0);
    signal BusBlk_DatOut : std_logic_vector(31 downto 0);
    signal BusBlk_Ack : std_logic;
    signal BusBlk_Unoccupied_Ack : std_logic;


begin 


    -- ---------- Connect register instances ----------

    i_BusBlk_WasmFpgaBus :  BusBlk_WasmFpgaBus
     port map (
        Clk => Clk,
        Rst => Rst,
        Adr => WasmFpgaBusWshBnDn.Adr,
        Sel => Sel,
        DatIn => WasmFpgaBusWshBnDn.DatIn,
        We =>  WasmFpgaBusWshBnDn.We,
        Stb => WasmFpgaBusWshBnDn.Stb,
        Cyc => WasmFpgaBusWshBnDn.Cyc,
        BusBlk_DatOut => BusBlk_DatOut,
        BusBlk_Ack => BusBlk_Ack,
        BusBlk_Unoccupied_Ack => BusBlk_Unoccupied_Ack,
        ModuleArea_DatOut => WasmFpgaBusWshBn_BusBlk.ModuleArea_DatOut,
        ModuleArea_Ack => BusBlk_WasmFpgaBusWshBn.ModuleArea_Ack,
        ModuleArea_Adr => WasmFpgaBusWshBn_BusBlk.ModuleArea_Adr,
        ModuleArea_Sel => WasmFpgaBusWshBn_BusBlk.ModuleArea_Sel,
        ModuleArea_We => WasmFpgaBusWshBn_BusBlk.ModuleArea_We,
        ModuleArea_Stb => WasmFpgaBusWshBn_BusBlk.ModuleArea_Stb,
        ModuleArea_DatIn => BusBlk_WasmFpgaBusWshBn.ModuleArea_DatIn,
        ModuleArea_Cyc => WasmFpgaBusWshBn_BusBlk.ModuleArea_Cyc,
        StackArea_DatOut => WasmFpgaBusWshBn_BusBlk.StackArea_DatOut,
        StackArea_Ack => BusBlk_WasmFpgaBusWshBn.StackArea_Ack,
        StackArea_Adr => WasmFpgaBusWshBn_BusBlk.StackArea_Adr,
        StackArea_Sel => WasmFpgaBusWshBn_BusBlk.StackArea_Sel,
        StackArea_We => WasmFpgaBusWshBn_BusBlk.StackArea_We,
        StackArea_Stb => WasmFpgaBusWshBn_BusBlk.StackArea_Stb,
        StackArea_DatIn => BusBlk_WasmFpgaBusWshBn.StackArea_DatIn,
        StackArea_Cyc => WasmFpgaBusWshBn_BusBlk.StackArea_Cyc,
        StoreArea_DatOut => WasmFpgaBusWshBn_BusBlk.StoreArea_DatOut,
        StoreArea_Ack => BusBlk_WasmFpgaBusWshBn.StoreArea_Ack,
        StoreArea_Adr => WasmFpgaBusWshBn_BusBlk.StoreArea_Adr,
        StoreArea_Sel => WasmFpgaBusWshBn_BusBlk.StoreArea_Sel,
        StoreArea_We => WasmFpgaBusWshBn_BusBlk.StoreArea_We,
        StoreArea_Stb => WasmFpgaBusWshBn_BusBlk.StoreArea_Stb,
        StoreArea_DatIn => BusBlk_WasmFpgaBusWshBn.StoreArea_DatIn,
        StoreArea_Cyc => WasmFpgaBusWshBn_BusBlk.StoreArea_Cyc,
        MemoryArea_DatOut => WasmFpgaBusWshBn_BusBlk.MemoryArea_DatOut,
        MemoryArea_Ack => BusBlk_WasmFpgaBusWshBn.MemoryArea_Ack,
        MemoryArea_Adr => WasmFpgaBusWshBn_BusBlk.MemoryArea_Adr,
        MemoryArea_Sel => WasmFpgaBusWshBn_BusBlk.MemoryArea_Sel,
        MemoryArea_We => WasmFpgaBusWshBn_BusBlk.MemoryArea_We,
        MemoryArea_Stb => WasmFpgaBusWshBn_BusBlk.MemoryArea_Stb,
        MemoryArea_DatIn => BusBlk_WasmFpgaBusWshBn.MemoryArea_DatIn,
        MemoryArea_Cyc => WasmFpgaBusWshBn_BusBlk.MemoryArea_Cyc
     );


    Sel <= WasmFpgaBusWshBnDn.Sel;                                                      

    WasmFpgaBusWshBn_UnOccpdRcrd.forRecord_Adr <= WasmFpgaBusWshBnDn.Adr;
    WasmFpgaBusWshBn_UnOccpdRcrd.forRecord_Sel <= Sel;
    WasmFpgaBusWshBn_UnOccpdRcrd.forRecord_We <= WasmFpgaBusWshBnDn.We;
    WasmFpgaBusWshBn_UnOccpdRcrd.forRecord_Cyc <= WasmFpgaBusWshBnDn.Cyc;

    -- ---------- Or all DataOuts and Acks of blocks ----------

     WasmFpgaBusWshBnUp.DatOut <= 
        BusBlk_DatOut;

     WasmFpgaBusWshBnUp.Ack <= 
        BusBlk_Ack;

     WasmFpgaBusWshBn_UnOccpdRcrd.Unoccupied_Ack <= 
        BusBlk_Unoccupied_Ack;





end architecture;



