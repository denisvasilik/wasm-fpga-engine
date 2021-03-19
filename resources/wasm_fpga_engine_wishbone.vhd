

-- ========== WebAssembly Engine Block( EngineBlk) ========== 

-- This block describes the WebAssembly engine block.
-- BUS: 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaEngineWshBn_Package.all;

entity EngineBlk_WasmFpgaEngine is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : in std_logic_vector(23 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        DatIn : in std_logic_vector(31 downto 0);
        We : in std_logic;
        Stb : in std_logic;
        Cyc : in  std_logic_vector(0 downto 0);
        EngineBlk_DatOut : out std_logic_vector(31 downto 0);
        EngineBlk_Ack : out std_logic;
        EngineBlk_Unoccupied_Ack : out std_logic;
        Run : out std_logic;
        WRegPulse_ControlReg : out std_logic;
        Trap : in std_logic;
        Busy : in std_logic
     );
end EngineBlk_WasmFpgaEngine;



architecture arch_for_synthesys of EngineBlk_WasmFpgaEngine is

    -- ---------- block variables ---------- 
    signal PreMuxAck_Unoccupied : std_logic;
    signal UnoccupiedDec : std_logic_vector(1 downto 0);
    signal EngineBlk_PreDatOut : std_logic_vector(31 downto 0);
    signal EngineBlk_PreAck : std_logic;
    signal EngineBlk_Unoccupied_PreAck : std_logic;
    signal PreMuxDatOut_ControlReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ControlReg : std_logic;
    signal PreMuxDatOut_StatusReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_StatusReg : std_logic;

    signal WriteDiff_ControlReg : std_logic;
    signal ReadDiff_ControlReg : std_logic;
     signal DelWriteDiff_ControlReg: std_logic;


    signal WriteDiff_StatusReg : std_logic;
    signal ReadDiff_StatusReg : std_logic;


    signal WReg_Run : std_logic;

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

    EngineBlk_DatOut <= EngineBlk_PreDatOut;
    EngineBlk_Ack <=  EngineBlk_PreAck;
    EngineBlk_Unoccupied_Ack <= EngineBlk_Unoccupied_PreAck;

    mux_data_ack_out : process (Cyc, Adr, 
                                PreMuxDatOut_ControlReg,
                                PreMuxAck_ControlReg,
                                PreMuxDatOut_StatusReg,
                                PreMuxAck_StatusReg,
                                PreMuxAck_Unoccupied
                                )
    begin 
        EngineBlk_PreDatOut <= x"0000_0000"; -- default statements
        EngineBlk_PreAck <= '0'; 
        EngineBlk_Unoccupied_PreAck <= '0';
        if ( (Cyc(0) = '1') 
              and (unsigned(Adr) >= unsigned(WASMFPGAENGINE_ADR_BLK_BASE_EngineBlk) )
              and (unsigned(Adr) <= (unsigned(WASMFPGAENGINE_ADR_BLK_BASE_EngineBlk) + unsigned(WASMFPGAENGINE_ADR_BLK_SIZE_EngineBlk) - 1)) )
        then 
            if ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINE_ADR_ControlReg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_ControlReg;
                EngineBlk_PreAck <= PreMuxAck_ControlReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINE_ADR_StatusReg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_StatusReg;
                EngineBlk_PreAck <= PreMuxAck_StatusReg;
            else 
                EngineBlk_PreAck <= PreMuxAck_Unoccupied;
                EngineBlk_Unoccupied_PreAck <= PreMuxAck_Unoccupied;
            end if;
        end if;
    end process;


    -- ---------- block functions ---------- 


    -- .......... ControlReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ControlReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ControlReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINE_ADR_ControlReg) ) then 
            WriteDiff_ControlReg <=  We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            WriteDiff_ControlReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINE_ADR_ControlReg) ) then 
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
            WReg_Run <= '0';
        elsif rising_edge(Clk) then
             DelWriteDiff_ControlReg <= WriteDiff_ControlReg;
            PreMuxAck_ControlReg <= WriteDiff_ControlReg or ReadDiff_ControlReg; 
            if (WriteDiff_ControlReg = '1') then
                if (Sel(0) = '1') then WReg_Run <= DatIn(0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ControlReg0 : process (
            WReg_Run
            )
    begin 
         PreMuxDatOut_ControlReg <= x"0000_0000";
         PreMuxDatOut_ControlReg(0) <= WReg_Run;
    end process;



    WRegPulse_ControlReg <= DelWriteDiff_ControlReg;

    Run <= WReg_Run;

    -- .......... StatusReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_StatusReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_StatusReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINE_ADR_StatusReg) ) then 
            WriteDiff_StatusReg <=  We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            WriteDiff_StatusReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINE_ADR_StatusReg) ) then 
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
            Trap,
            Busy
            )
    begin 
         PreMuxDatOut_StatusReg <= x"0000_0000";
         PreMuxDatOut_StatusReg(1) <= Trap;
         PreMuxDatOut_StatusReg(0) <= Busy;
    end process;






end architecture;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaEngineWshBn_Package.all;

-- ========== Wishbone for WasmFpgaEngine (WasmFpgaEngineWishbone) ========== 

entity WasmFpgaEngineWshBn is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        WasmFpgaEngineWshBnDn : in T_WasmFpgaEngineWshBnDn;
        WasmFpgaEngineWshBnUp : out T_WasmFpgaEngineWshBnUp;
        WasmFpgaEngineWshBn_UnOccpdRcrd : out T_WasmFpgaEngineWshBn_UnOccpdRcrd;
        WasmFpgaEngineWshBn_EngineBlk : out T_WasmFpgaEngineWshBn_EngineBlk;
        EngineBlk_WasmFpgaEngineWshBn : in T_EngineBlk_WasmFpgaEngineWshBn
     );
end WasmFpgaEngineWshBn;



architecture arch_for_synthesys of WasmFpgaEngineWshBn is

    component EngineBlk_WasmFpgaEngine is
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            Adr : in std_logic_vector(23 downto 0);
            Sel : in std_logic_vector(3 downto 0);
            DatIn : in std_logic_vector(31 downto 0);
            We : in std_logic;
            Stb : in std_logic;
            Cyc : in  std_logic_vector(0 downto 0);
            EngineBlk_DatOut : out std_logic_vector(31 downto 0);
            EngineBlk_Ack : out std_logic;
            EngineBlk_Unoccupied_Ack : out std_logic;
            Run : out std_logic;
            WRegPulse_ControlReg : out std_logic;
            Trap : in std_logic;
            Busy : in std_logic
         );
    end component; 


    -- ---------- internal wires ----------

    signal Sel : std_logic_vector(3 downto 0);
    signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
    signal EngineBlk_Ack : std_logic;
    signal EngineBlk_Unoccupied_Ack : std_logic;


begin 


    -- ---------- Connect register instances ----------

    i_EngineBlk_WasmFpgaEngine :  EngineBlk_WasmFpgaEngine
     port map (
        Clk => Clk,
        Rst => Rst,
        Adr => WasmFpgaEngineWshBnDn.Adr,
        Sel => Sel,
        DatIn => WasmFpgaEngineWshBnDn.DatIn,
        We =>  WasmFpgaEngineWshBnDn.We,
        Stb => WasmFpgaEngineWshBnDn.Stb,
        Cyc => WasmFpgaEngineWshBnDn.Cyc,
        EngineBlk_DatOut => EngineBlk_DatOut,
        EngineBlk_Ack => EngineBlk_Ack,
        EngineBlk_Unoccupied_Ack => EngineBlk_Unoccupied_Ack,
        Run => WasmFpgaEngineWshBn_EngineBlk.Run,
        WRegPulse_ControlReg => WasmFpgaEngineWshBn_EngineBlk.WRegPulse_ControlReg,
        Trap => EngineBlk_WasmFpgaEngineWshBn.Trap,
        Busy => EngineBlk_WasmFpgaEngineWshBn.Busy
     );


    Sel <= WasmFpgaEngineWshBnDn.Sel;                                                      

    WasmFpgaEngineWshBn_UnOccpdRcrd.forRecord_Adr <= WasmFpgaEngineWshBnDn.Adr;
    WasmFpgaEngineWshBn_UnOccpdRcrd.forRecord_Sel <= Sel;
    WasmFpgaEngineWshBn_UnOccpdRcrd.forRecord_We <= WasmFpgaEngineWshBnDn.We;
    WasmFpgaEngineWshBn_UnOccpdRcrd.forRecord_Cyc <= WasmFpgaEngineWshBnDn.Cyc;

    -- ---------- Or all DataOuts and Acks of blocks ----------

     WasmFpgaEngineWshBnUp.DatOut <= 
        EngineBlk_DatOut;

     WasmFpgaEngineWshBnUp.Ack <= 
        EngineBlk_Ack;

     WasmFpgaEngineWshBn_UnOccpdRcrd.Unoccupied_Ack <= 
        EngineBlk_Unoccupied_Ack;





end architecture;



