

-- ========== WebAssembly Engine Block( EngineBlk) ========== 

-- This block describes the WebAssembly engine block.
-- BUS: 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaEngineDebugWshBn_Package.all;

entity EngineBlk_WasmFpgaEngineDebug is
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
        Reset : out std_logic;
        StepOver : out std_logic;
        StepInto : out std_logic;
        StepOut : out std_logic;
        Continue : out std_logic;
        StopInMain : out std_logic;
        Debug : out std_logic;
        WRegPulse_ControlReg : out std_logic;
        InvocationTrap : in std_logic;
        InstantiationTrap : in std_logic;
        InstantiationRunning : in std_logic;
        InvocationRunning : in std_logic;
        Address : in std_logic_vector(23 downto 0);
        Instruction : in std_logic_vector(7 downto 0);
        Error : in std_logic_vector(7 downto 0);
        Breakpoint0 : out std_logic_vector(31 downto 0)
     );
end EngineBlk_WasmFpgaEngineDebug;



architecture arch_for_synthesys of EngineBlk_WasmFpgaEngineDebug is

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
    signal PreMuxDatOut_AddressReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_AddressReg : std_logic;
    signal PreMuxDatOut_InstructionReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_InstructionReg : std_logic;
    signal PreMuxDatOut_ErrorReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ErrorReg : std_logic;
    signal PreMuxDatOut_Breakpoint0Reg : std_logic_vector(31 downto 0);
    signal PreMuxAck_Breakpoint0Reg : std_logic;

    signal WriteDiff_ControlReg : std_logic;
    signal ReadDiff_ControlReg : std_logic;
     signal DelWriteDiff_ControlReg: std_logic;


    signal WriteDiff_StatusReg : std_logic;
    signal ReadDiff_StatusReg : std_logic;


    signal WriteDiff_AddressReg : std_logic;
    signal ReadDiff_AddressReg : std_logic;


    signal WriteDiff_InstructionReg : std_logic;
    signal ReadDiff_InstructionReg : std_logic;


    signal WriteDiff_ErrorReg : std_logic;
    signal ReadDiff_ErrorReg : std_logic;


    signal WriteDiff_Breakpoint0Reg : std_logic;
    signal ReadDiff_Breakpoint0Reg : std_logic;


    signal WReg_Reset : std_logic;
    signal WReg_StepOver : std_logic;
    signal WReg_StepInto : std_logic;
    signal WReg_StepOut : std_logic;
    signal WReg_Continue : std_logic;
    signal WReg_StopInMain : std_logic;
    signal WReg_Debug : std_logic;
    signal WReg_Breakpoint0 : std_logic_vector(31 downto 0);

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
                                PreMuxDatOut_AddressReg,
                                PreMuxAck_AddressReg,
                                PreMuxDatOut_InstructionReg,
                                PreMuxAck_InstructionReg,
                                PreMuxDatOut_ErrorReg,
                                PreMuxAck_ErrorReg,
                                PreMuxDatOut_Breakpoint0Reg,
                                PreMuxAck_Breakpoint0Reg,
                                PreMuxAck_Unoccupied
                                )
    begin 
        EngineBlk_PreDatOut <= x"0000_0000"; -- default statements
        EngineBlk_PreAck <= '0'; 
        EngineBlk_Unoccupied_PreAck <= '0';
        if ( (Cyc(0) = '1') 
              and (unsigned(Adr) >= unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineBlk) )
              and (unsigned(Adr) <= (unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineBlk) + unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_SIZE_EngineBlk) - 1)) )
        then 
            if ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINEDEBUG_ADR_ControlReg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_ControlReg;
                EngineBlk_PreAck <= PreMuxAck_ControlReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINEDEBUG_ADR_StatusReg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_StatusReg;
                EngineBlk_PreAck <= PreMuxAck_StatusReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINEDEBUG_ADR_AddressReg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_AddressReg;
                EngineBlk_PreAck <= PreMuxAck_AddressReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINEDEBUG_ADR_InstructionReg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_InstructionReg;
                EngineBlk_PreAck <= PreMuxAck_InstructionReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINEDEBUG_ADR_ErrorReg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_ErrorReg;
                EngineBlk_PreAck <= PreMuxAck_ErrorReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAENGINEDEBUG_ADR_Breakpoint0Reg)) ) then
                 EngineBlk_PreDatOut <= PreMuxDatOut_Breakpoint0Reg;
                EngineBlk_PreAck <= PreMuxAck_Breakpoint0Reg;
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
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_ControlReg) ) then 
            WriteDiff_ControlReg <=  We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            WriteDiff_ControlReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_ControlReg) ) then 
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
            WReg_Reset <= '0';
            WReg_StepOver <= '0';
            WReg_StepInto <= '0';
            WReg_StepOut <= '0';
            WReg_Continue <= '0';
            WReg_StopInMain <= '0';
            WReg_Debug <= '0';
        elsif rising_edge(Clk) then
             DelWriteDiff_ControlReg <= WriteDiff_ControlReg;
            PreMuxAck_ControlReg <= WriteDiff_ControlReg or ReadDiff_ControlReg; 
            if (WriteDiff_ControlReg = '1') then
                if (Sel(0) = '1') then WReg_Reset <= DatIn(6); end if;
                if (Sel(0) = '1') then WReg_StepOver <= DatIn(5); end if;
                if (Sel(0) = '1') then WReg_StepInto <= DatIn(4); end if;
                if (Sel(0) = '1') then WReg_StepOut <= DatIn(3); end if;
                if (Sel(0) = '1') then WReg_Continue <= DatIn(2); end if;
                if (Sel(0) = '1') then WReg_StopInMain <= DatIn(1); end if;
                if (Sel(0) = '1') then WReg_Debug <= DatIn(0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ControlReg0 : process (
            WReg_Reset,
            WReg_StepOver,
            WReg_StepInto,
            WReg_StepOut,
            WReg_Continue,
            WReg_StopInMain,
            WReg_Debug
            )
    begin 
         PreMuxDatOut_ControlReg <= x"0000_0000";
         PreMuxDatOut_ControlReg(6) <= WReg_Reset;
         PreMuxDatOut_ControlReg(5) <= WReg_StepOver;
         PreMuxDatOut_ControlReg(4) <= WReg_StepInto;
         PreMuxDatOut_ControlReg(3) <= WReg_StepOut;
         PreMuxDatOut_ControlReg(2) <= WReg_Continue;
         PreMuxDatOut_ControlReg(1) <= WReg_StopInMain;
         PreMuxDatOut_ControlReg(0) <= WReg_Debug;
    end process;



    WRegPulse_ControlReg <= DelWriteDiff_ControlReg;

    Reset <= WReg_Reset;
    StepOver <= WReg_StepOver;
    StepInto <= WReg_StepInto;
    StepOut <= WReg_StepOut;
    Continue <= WReg_Continue;
    StopInMain <= WReg_StopInMain;
    Debug <= WReg_Debug;

    -- .......... StatusReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_StatusReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_StatusReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_StatusReg) ) then 
            WriteDiff_StatusReg <=  We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            WriteDiff_StatusReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_StatusReg) ) then 
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
            InvocationTrap,
            InstantiationTrap,
            InstantiationRunning,
            InvocationRunning
            )
    begin 
         PreMuxDatOut_StatusReg <= x"0000_0000";
         PreMuxDatOut_StatusReg(3) <= InvocationTrap;
         PreMuxDatOut_StatusReg(2) <= InstantiationTrap;
         PreMuxDatOut_StatusReg(1) <= InstantiationRunning;
         PreMuxDatOut_StatusReg(0) <= InvocationRunning;
    end process;





    -- .......... AddressReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_AddressReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_AddressReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_AddressReg) ) then 
            WriteDiff_AddressReg <=  We and Stb and Cyc(0) and not PreMuxAck_AddressReg;
        else
            WriteDiff_AddressReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_AddressReg) ) then 
            ReadDiff_AddressReg <= not We and Stb and Cyc(0) and not PreMuxAck_AddressReg;
        else
            ReadDiff_AddressReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_AddressReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_AddressReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_AddressReg <= WriteDiff_AddressReg or ReadDiff_AddressReg; 
        end if;
    end process;

    mux_premuxdatout_AddressReg0 : process (
            Address
            )
    begin 
         PreMuxDatOut_AddressReg <= x"0000_0000";
         PreMuxDatOut_AddressReg(23 downto 0) <= Address;
    end process;





    -- .......... InstructionReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_InstructionReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_InstructionReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_InstructionReg) ) then 
            WriteDiff_InstructionReg <=  We and Stb and Cyc(0) and not PreMuxAck_InstructionReg;
        else
            WriteDiff_InstructionReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_InstructionReg) ) then 
            ReadDiff_InstructionReg <= not We and Stb and Cyc(0) and not PreMuxAck_InstructionReg;
        else
            ReadDiff_InstructionReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_InstructionReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_InstructionReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_InstructionReg <= WriteDiff_InstructionReg or ReadDiff_InstructionReg; 
        end if;
    end process;

    mux_premuxdatout_InstructionReg0 : process (
            Instruction
            )
    begin 
         PreMuxDatOut_InstructionReg <= x"0000_0000";
         PreMuxDatOut_InstructionReg(7 downto 0) <= Instruction;
    end process;





    -- .......... ErrorReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ErrorReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ErrorReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_ErrorReg) ) then 
            WriteDiff_ErrorReg <=  We and Stb and Cyc(0) and not PreMuxAck_ErrorReg;
        else
            WriteDiff_ErrorReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_ErrorReg) ) then 
            ReadDiff_ErrorReg <= not We and Stb and Cyc(0) and not PreMuxAck_ErrorReg;
        else
            ReadDiff_ErrorReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_ErrorReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_ErrorReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_ErrorReg <= WriteDiff_ErrorReg or ReadDiff_ErrorReg; 
        end if;
    end process;

    mux_premuxdatout_ErrorReg0 : process (
            Error
            )
    begin 
         PreMuxDatOut_ErrorReg <= x"0000_0000";
         PreMuxDatOut_ErrorReg(7 downto 0) <= Error;
    end process;





    -- .......... Breakpoint0Reg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_Breakpoint0Reg0 : process (Adr, We, Stb, Cyc, PreMuxAck_Breakpoint0Reg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_Breakpoint0Reg) ) then 
            WriteDiff_Breakpoint0Reg <=  We and Stb and Cyc(0) and not PreMuxAck_Breakpoint0Reg;
        else
            WriteDiff_Breakpoint0Reg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAENGINEDEBUG_ADR_Breakpoint0Reg) ) then 
            ReadDiff_Breakpoint0Reg <= not We and Stb and Cyc(0) and not PreMuxAck_Breakpoint0Reg;
        else
            ReadDiff_Breakpoint0Reg <= '0';
        end if;
    end process;

    reg_syn_clk_part_Breakpoint0Reg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_Breakpoint0Reg <= '0';
            WReg_Breakpoint0 <= "00000000000000000000000000000000";
        elsif rising_edge(Clk) then
            PreMuxAck_Breakpoint0Reg <= WriteDiff_Breakpoint0Reg or ReadDiff_Breakpoint0Reg; 
            if (WriteDiff_Breakpoint0Reg = '1') then
                if (Sel(3) = '1') then WReg_Breakpoint0(31 downto 24) <= DatIn(31 downto 24); end if;
                if (Sel(2) = '1') then WReg_Breakpoint0(23 downto 16) <= DatIn(23 downto 16); end if;
                if (Sel(1) = '1') then WReg_Breakpoint0(15 downto 8) <= DatIn(15 downto 8); end if;
                if (Sel(0) = '1') then WReg_Breakpoint0(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_Breakpoint0Reg0 : process (
            WReg_Breakpoint0
            )
    begin 
         PreMuxDatOut_Breakpoint0Reg <= x"0000_0000";
         PreMuxDatOut_Breakpoint0Reg(31 downto 0) <= WReg_Breakpoint0;
    end process;




    Breakpoint0 <= WReg_Breakpoint0;


end architecture;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaEngineDebugWshBn_Package.all;

-- ========== Wishbone for WasmFpgaEngineDebug (WasmFpgaEngineDebugWishbone) ========== 

entity WasmFpgaEngineDebugWshBn is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        WasmFpgaEngineDebugWshBnDn : in T_WasmFpgaEngineDebugWshBnDn;
        WasmFpgaEngineDebugWshBnUp : out T_WasmFpgaEngineDebugWshBnUp;
        WasmFpgaEngineDebugWshBn_UnOccpdRcrd : out T_WasmFpgaEngineDebugWshBn_UnOccpdRcrd;
        WasmFpgaEngineDebugWshBn_EngineBlk : out T_WasmFpgaEngineDebugWshBn_EngineBlk;
        EngineBlk_WasmFpgaEngineDebugWshBn : in T_EngineBlk_WasmFpgaEngineDebugWshBn
     );
end WasmFpgaEngineDebugWshBn;



architecture arch_for_synthesys of WasmFpgaEngineDebugWshBn is

    component EngineBlk_WasmFpgaEngineDebug is
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
            Reset : out std_logic;
            StepOver : out std_logic;
            StepInto : out std_logic;
            StepOut : out std_logic;
            Continue : out std_logic;
            StopInMain : out std_logic;
            Debug : out std_logic;
            WRegPulse_ControlReg : out std_logic;
            InvocationTrap : in std_logic;
            InstantiationTrap : in std_logic;
            InstantiationRunning : in std_logic;
            InvocationRunning : in std_logic;
            Address : in std_logic_vector(23 downto 0);
            Instruction : in std_logic_vector(7 downto 0);
            Error : in std_logic_vector(7 downto 0);
            Breakpoint0 : out std_logic_vector(31 downto 0)
         );
    end component; 


    -- ---------- internal wires ----------

    signal Sel : std_logic_vector(3 downto 0);
    signal EngineBlk_DatOut : std_logic_vector(31 downto 0);
    signal EngineBlk_Ack : std_logic;
    signal EngineBlk_Unoccupied_Ack : std_logic;


begin 


    -- ---------- Connect register instances ----------

    i_EngineBlk_WasmFpgaEngineDebug :  EngineBlk_WasmFpgaEngineDebug
     port map (
        Clk => Clk,
        Rst => Rst,
        Adr => WasmFpgaEngineDebugWshBnDn.Adr,
        Sel => Sel,
        DatIn => WasmFpgaEngineDebugWshBnDn.DatIn,
        We =>  WasmFpgaEngineDebugWshBnDn.We,
        Stb => WasmFpgaEngineDebugWshBnDn.Stb,
        Cyc => WasmFpgaEngineDebugWshBnDn.Cyc,
        EngineBlk_DatOut => EngineBlk_DatOut,
        EngineBlk_Ack => EngineBlk_Ack,
        EngineBlk_Unoccupied_Ack => EngineBlk_Unoccupied_Ack,
        Reset => WasmFpgaEngineDebugWshBn_EngineBlk.Reset,
        StepOver => WasmFpgaEngineDebugWshBn_EngineBlk.StepOver,
        StepInto => WasmFpgaEngineDebugWshBn_EngineBlk.StepInto,
        StepOut => WasmFpgaEngineDebugWshBn_EngineBlk.StepOut,
        Continue => WasmFpgaEngineDebugWshBn_EngineBlk.Continue,
        StopInMain => WasmFpgaEngineDebugWshBn_EngineBlk.StopInMain,
        Debug => WasmFpgaEngineDebugWshBn_EngineBlk.Debug,
        WRegPulse_ControlReg => WasmFpgaEngineDebugWshBn_EngineBlk.WRegPulse_ControlReg,
        InvocationTrap => EngineBlk_WasmFpgaEngineDebugWshBn.InvocationTrap,
        InstantiationTrap => EngineBlk_WasmFpgaEngineDebugWshBn.InstantiationTrap,
        InstantiationRunning => EngineBlk_WasmFpgaEngineDebugWshBn.InstantiationRunning,
        InvocationRunning => EngineBlk_WasmFpgaEngineDebugWshBn.InvocationRunning,
        Address => EngineBlk_WasmFpgaEngineDebugWshBn.Address,
        Instruction => EngineBlk_WasmFpgaEngineDebugWshBn.Instruction,
        Error => EngineBlk_WasmFpgaEngineDebugWshBn.Error,
        Breakpoint0 => WasmFpgaEngineDebugWshBn_EngineBlk.Breakpoint0
     );


    Sel <= WasmFpgaEngineDebugWshBnDn.Sel;                                                      

    WasmFpgaEngineDebugWshBn_UnOccpdRcrd.forRecord_Adr <= WasmFpgaEngineDebugWshBnDn.Adr;
    WasmFpgaEngineDebugWshBn_UnOccpdRcrd.forRecord_Sel <= Sel;
    WasmFpgaEngineDebugWshBn_UnOccpdRcrd.forRecord_We <= WasmFpgaEngineDebugWshBnDn.We;
    WasmFpgaEngineDebugWshBn_UnOccpdRcrd.forRecord_Cyc <= WasmFpgaEngineDebugWshBnDn.Cyc;

    -- ---------- Or all DataOuts and Acks of blocks ----------

     WasmFpgaEngineDebugWshBnUp.DatOut <= 
        EngineBlk_DatOut;

     WasmFpgaEngineDebugWshBnUp.Ack <= 
        EngineBlk_Ack;

     WasmFpgaEngineDebugWshBn_UnOccpdRcrd.Unoccupied_Ack <= 
        EngineBlk_Unoccupied_Ack;





end architecture;



