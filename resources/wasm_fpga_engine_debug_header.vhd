


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package WasmFpgaEngineDebugWshBn_Package is


-- type decalarations ---------------------------------                    

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_2_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_3_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_4_t is                                        
      array (natural range <>) of std_logic_vector(3 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_5_t is                                        
      array (natural range <>) of std_logic_vector(4 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_6_t is                                        
      array (natural range <>) of std_logic_vector(5 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_7_t is                                        
      array (natural range <>) of std_logic_vector(6 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_8_t is                                        
      array (natural range <>) of std_logic_vector(7 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_9_t is                                        
      array (natural range <>) of std_logic_vector(8 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_10_t is                                    
      array (natural range <>) of std_logic_vector(9 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_11_t is                                    
      array (natural range <>) of std_logic_vector(10 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_12_t is                                    
      array (natural range <>) of std_logic_vector(11 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_13_t is                                    
      array (natural range <>) of std_logic_vector(12 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_14_t is                                    
      array (natural range <>) of std_logic_vector(13 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_15_t is                                    
      array (natural range <>) of std_logic_vector(14 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_16_t is                                    
      array (natural range <>) of std_logic_vector(15 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_24_t is                                    
      array (natural range <>) of std_logic_vector(23 downto 0);     

    type WasmFpgaEngineDebug_arr_of_std_logic_vector_32_t is                                    
      array (natural range <>) of std_logic_vector(31 downto 0);    


    type T_WasmFpgaEngineDebugWshBnDn is
    record
        Adr :   std_logic_vector(23 downto 0);
        Sel :   std_logic_vector(3 downto 0);
        DatIn :   std_logic_vector(31 downto 0);
        We :   std_logic;
        Stb :   std_logic;
        Cyc :   std_logic_vector(0 downto 0);
    end record;

    type array_of_T_WasmFpgaEngineDebugWshBnDn is
      array (natural range <>) of T_WasmFpgaEngineDebugWshBnDn;


    type T_WasmFpgaEngineDebugWshBnUp is
    record
        DatOut :   std_logic_vector(31 downto 0);
        Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaEngineDebugWshBnUp is
      array (natural range <>) of T_WasmFpgaEngineDebugWshBnUp;

    type T_WasmFpgaEngineDebugWshBn_UnOccpdRcrd is
    record
        forRecord_Adr :   std_logic_vector(23 downto 0);
        forRecord_Sel :   std_logic_vector(3 downto 0);
        forRecord_We :   std_logic;
        forRecord_Cyc :   std_logic_vector(0 downto 0);
        Unoccupied_Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaEngineDebugWshBn_UnOccpdRcrd is
      array (natural range <>) of T_WasmFpgaEngineDebugWshBn_UnOccpdRcrd;

    type T_WasmFpgaEngineDebugWshBn_EngineDebugBlk is
    record
        StopDebugging :   std_logic;
        Reset :   std_logic;
        StepOver :   std_logic;
        StepInto :   std_logic;
        StepOut :   std_logic;
        Continue :   std_logic;
        StopInMain :   std_logic;
        Debug :   std_logic;
        WRegPulse_ControlReg :   std_logic;
        Breakpoint0 :   std_logic_vector(31 downto 0);
    end record;

    type array_of_T_WasmFpgaEngineDebugWshBn_EngineDebugBlk is
      array (natural range <>) of T_WasmFpgaEngineDebugWshBn_EngineDebugBlk;


    type T_EngineDebugBlk_WasmFpgaEngineDebugWshBn is
    record
        InvocationTrap :   std_logic;
        InstantiationTrap :   std_logic;
        InstantiationRunning :   std_logic;
        InvocationRunning :   std_logic;
        Address :   std_logic_vector(23 downto 0);
        Instruction :   std_logic_vector(7 downto 0);
        Error :   std_logic_vector(7 downto 0);
    end record;

    type array_of_T_EngineDebugBlk_WasmFpgaEngineDebugWshBn is
      array (natural range <>) of T_EngineDebugBlk_WasmFpgaEngineDebugWshBn;




    -- ---------- WebAssembly Engine Block( EngineDebugBlk ) ----------
    -- BUS: 

    constant WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineDebugBlk                                         : std_logic_vector(23 downto 0) := x"000000";
    constant WASMFPGAENGINEDEBUG_ADR_BLK_SIZE_EngineDebugBlk                                         : std_logic_vector(23 downto 0) := x"000018";

        -- ControlReg: Debug Control Register 
        constant WASMFPGAENGINEDEBUG_WIDTH_ControlReg                                                : integer := 32;
        constant WASMFPGAENGINEDEBUG_ADR_ControlReg                                                  : std_logic_vector(23 downto 0) := std_logic_vector(x"000000" + unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineDebugBlk));

            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_StopDebugging                                      : std_logic_vector(31 downto 0) := x"00000080";

                -- Do nothing.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotStopDebugging                                  : std_logic := '0';
                -- End program execution at current instruction.
                constant WASMFPGAENGINEDEBUG_VAL_DoStopDebugging                                     : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_Reset                                              : std_logic_vector(31 downto 0) := x"00000040";

                -- Do not reset the engine state.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotReset                                          : std_logic := '0';
                -- Reset the engine state.
                constant WASMFPGAENGINEDEBUG_VAL_DoReset                                             : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_StepOver                                           : std_logic_vector(31 downto 0) := x"00000020";

                -- Do nothing.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotStepOver                                       : std_logic := '0';
                -- Step over the next instruction.
                constant WASMFPGAENGINEDEBUG_VAL_DoStepOver                                          : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_StepInto                                           : std_logic_vector(31 downto 0) := x"00000010";

                -- Do nothing.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotStepInto                                       : std_logic := '0';
                -- Step into a function.
                constant WASMFPGAENGINEDEBUG_VAL_DoStepInto                                          : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_StepOut                                            : std_logic_vector(31 downto 0) := x"00000008";

                -- Do nothing.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotStepOut                                        : std_logic := '0';
                -- Step out of a function.
                constant WASMFPGAENGINEDEBUG_VAL_DoStepOut                                           : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_Continue                                           : std_logic_vector(31 downto 0) := x"00000004";

                -- Do nothing.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotContinue                                       : std_logic := '0';
                -- Continue execution until next breakpoint.
                constant WASMFPGAENGINEDEBUG_VAL_DoContinue                                          : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_StopInMain                                         : std_logic_vector(31 downto 0) := x"00000002";

                -- Do not stop in main.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotStopInMain                                     : std_logic := '0';
                -- Do stop in main.
                constant WASMFPGAENGINEDEBUG_VAL_DoStopInMain                                        : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_Debug                                              : std_logic_vector(31 downto 0) := x"00000001";

                -- Do nothing.
                constant WASMFPGAENGINEDEBUG_VAL_DoNotDebug                                          : std_logic := '0';
                -- Start debugging.
                constant WASMFPGAENGINEDEBUG_VAL_DoDebug                                             : std_logic := '1';


        -- StatusReg: Status Register 
        constant WASMFPGAENGINEDEBUG_WIDTH_StatusReg                                                 : integer := 32;
        constant WASMFPGAENGINEDEBUG_ADR_StatusReg                                                   : std_logic_vector(23 downto 0) := std_logic_vector(x"000004" + unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineDebugBlk));

            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_InvocationTrap                                     : std_logic_vector(31 downto 0) := x"00000008";

                -- Invocation is not trapped.
                constant WASMFPGAENGINEDEBUG_VAL_IsInvocationNotTrapped                              : std_logic := '0';
                -- Invocation is trapped.
                constant WASMFPGAENGINEDEBUG_VAL_IsInvocationTrapped                                 : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_InstantiationTrap                                  : std_logic_vector(31 downto 0) := x"00000004";

                -- Instantiation is not trapped.
                constant WASMFPGAENGINEDEBUG_VAL_IsInstantiationNotTrapped                           : std_logic := '0';
                -- Instantiation is trapped.
                constant WASMFPGAENGINEDEBUG_VAL_IsInstantiationTrapped                              : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_InstantiationRunning                               : std_logic_vector(31 downto 0) := x"00000002";

                -- Instantiation is not running.
                constant WASMFPGAENGINEDEBUG_VAL_IsInstantiationNotRunning                           : std_logic := '0';
                -- Instantiation is running.
                constant WASMFPGAENGINEDEBUG_VAL_IsInstantiationRunning                              : std_logic := '1';


            -- 
            constant WASMFPGAENGINEDEBUG_BUS_MASK_InvocationRunning                                  : std_logic_vector(31 downto 0) := x"00000001";

                -- Invocation is not running.
                constant WASMFPGAENGINEDEBUG_VAL_IsInvocationNotRunning                              : std_logic := '0';
                -- Invocation is running.
                constant WASMFPGAENGINEDEBUG_VAL_IsInvocationRunning                                 : std_logic := '1';


        -- AddressReg: Address Register 
        constant WASMFPGAENGINEDEBUG_WIDTH_AddressReg                                                : integer := 32;
        constant WASMFPGAENGINEDEBUG_ADR_AddressReg                                                  : std_logic_vector(23 downto 0) := std_logic_vector(x"000008" + unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineDebugBlk));

            -- Address of the current instruction residing in the module ram.

            constant WASMFPGAENGINEDEBUG_BUS_MASK_Address                                            : std_logic_vector(31 downto 0) := x"00FFFFFF";

        -- InstructionReg: Instruction Register 
        constant WASMFPGAENGINEDEBUG_WIDTH_InstructionReg                                            : integer := 32;
        constant WASMFPGAENGINEDEBUG_ADR_InstructionReg                                              : std_logic_vector(23 downto 0) := std_logic_vector(x"00000C" + unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineDebugBlk));

            -- Instruction currently executed by the engine.

            constant WASMFPGAENGINEDEBUG_BUS_MASK_Instruction                                        : std_logic_vector(31 downto 0) := x"000000FF";

        -- ErrorReg: Error Register 
        constant WASMFPGAENGINEDEBUG_WIDTH_ErrorReg                                                  : integer := 32;
        constant WASMFPGAENGINEDEBUG_ADR_ErrorReg                                                    : std_logic_vector(23 downto 0) := std_logic_vector(x"000010" + unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineDebugBlk));

            -- Internal error code of the engine.

            constant WASMFPGAENGINEDEBUG_BUS_MASK_Error                                              : std_logic_vector(31 downto 0) := x"000000FF";

        -- Breakpoint0Reg: Breakpoint Register 0 
        constant WASMFPGAENGINEDEBUG_WIDTH_Breakpoint0Reg                                            : integer := 32;
        constant WASMFPGAENGINEDEBUG_ADR_Breakpoint0Reg                                              : std_logic_vector(23 downto 0) := std_logic_vector(x"000014" + unsigned(WASMFPGAENGINEDEBUG_ADR_BLK_BASE_EngineDebugBlk));

            -- 

            constant WASMFPGAENGINEDEBUG_BUS_MASK_Breakpoint0                                        : std_logic_vector(31 downto 0) := x"FFFFFFFF";




end WasmFpgaEngineDebugWshBn_Package;
