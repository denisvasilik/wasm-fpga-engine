


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package WasmFpgaEngineWshBn_Package is


-- type decalarations ---------------------------------                    

    type WasmFpgaEngine_arr_of_std_logic_vector_2_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_3_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_4_t is                                        
      array (natural range <>) of std_logic_vector(3 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_5_t is                                        
      array (natural range <>) of std_logic_vector(4 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_6_t is                                        
      array (natural range <>) of std_logic_vector(5 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_7_t is                                        
      array (natural range <>) of std_logic_vector(6 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_8_t is                                        
      array (natural range <>) of std_logic_vector(7 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_9_t is                                        
      array (natural range <>) of std_logic_vector(8 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_10_t is                                    
      array (natural range <>) of std_logic_vector(9 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_11_t is                                    
      array (natural range <>) of std_logic_vector(10 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_12_t is                                    
      array (natural range <>) of std_logic_vector(11 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_13_t is                                    
      array (natural range <>) of std_logic_vector(12 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_14_t is                                    
      array (natural range <>) of std_logic_vector(13 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_15_t is                                    
      array (natural range <>) of std_logic_vector(14 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_16_t is                                    
      array (natural range <>) of std_logic_vector(15 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_24_t is                                    
      array (natural range <>) of std_logic_vector(23 downto 0);     

    type WasmFpgaEngine_arr_of_std_logic_vector_32_t is                                    
      array (natural range <>) of std_logic_vector(31 downto 0);    


    type T_WasmFpgaEngineWshBnDn is
    record
        Adr :   std_logic_vector(23 downto 0);
        Sel :   std_logic_vector(3 downto 0);
        DatIn :   std_logic_vector(31 downto 0);
        We :   std_logic;
        Stb :   std_logic;
        Cyc :   std_logic_vector(0 downto 0);
    end record;

    type array_of_T_WasmFpgaEngineWshBnDn is
      array (natural range <>) of T_WasmFpgaEngineWshBnDn;


    type T_WasmFpgaEngineWshBnUp is
    record
        DatOut :   std_logic_vector(31 downto 0);
        Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaEngineWshBnUp is
      array (natural range <>) of T_WasmFpgaEngineWshBnUp;

    type T_WasmFpgaEngineWshBn_UnOccpdRcrd is
    record
        forRecord_Adr :   std_logic_vector(23 downto 0);
        forRecord_Sel :   std_logic_vector(3 downto 0);
        forRecord_We :   std_logic;
        forRecord_Cyc :   std_logic_vector(0 downto 0);
        Unoccupied_Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaEngineWshBn_UnOccpdRcrd is
      array (natural range <>) of T_WasmFpgaEngineWshBn_UnOccpdRcrd;

    type T_WasmFpgaEngineWshBn_EngineBlk is
    record
        Run :   std_logic;
        WRegPulse_ControlReg :   std_logic;
        ModuleInstanceUid :   std_logic_vector(31 downto 0);
    end record;

    type array_of_T_WasmFpgaEngineWshBn_EngineBlk is
      array (natural range <>) of T_WasmFpgaEngineWshBn_EngineBlk;


    type T_EngineBlk_WasmFpgaEngineWshBn is
    record
        Trap :   std_logic;
        Busy :   std_logic;
    end record;

    type array_of_T_EngineBlk_WasmFpgaEngineWshBn is
      array (natural range <>) of T_EngineBlk_WasmFpgaEngineWshBn;




    -- ---------- WebAssembly Engine Block( EngineBlk ) ----------
    -- BUS: 

    constant WASMFPGAENGINE_ADR_BLK_BASE_EngineBlk                                                   : std_logic_vector(23 downto 0) := x"000000";
    constant WASMFPGAENGINE_ADR_BLK_SIZE_EngineBlk                                                   : std_logic_vector(23 downto 0) := x"000020";

        -- ControlReg: Control Register 
        constant WASMFPGAENGINE_WIDTH_ControlReg                                                     : integer := 32;
        constant WASMFPGAENGINE_ADR_ControlReg                                                       : std_logic_vector(23 downto 0) := std_logic_vector(x"000000" + unsigned(WASMFPGAENGINE_ADR_BLK_BASE_EngineBlk));

            -- 
            constant WASMFPGAENGINE_BUS_MASK_Run                                                     : std_logic_vector(31 downto 0) := x"00000001";

                -- Do not run
                constant WASMFPGAENGINE_VAL_DoNotRun                                                 : std_logic := '0';
                -- Run
                constant WASMFPGAENGINE_VAL_DoRun                                                    : std_logic := '1';


        -- StatusReg: Status Register 
        constant WASMFPGAENGINE_WIDTH_StatusReg                                                      : integer := 32;
        constant WASMFPGAENGINE_ADR_StatusReg                                                        : std_logic_vector(23 downto 0) := std_logic_vector(x"000004" + unsigned(WASMFPGAENGINE_ADR_BLK_BASE_EngineBlk));

            -- 
            constant WASMFPGAENGINE_BUS_MASK_Trap                                                    : std_logic_vector(31 downto 0) := x"00000002";

                -- Engine is not trapped.
                constant WASMFPGAENGINE_VAL_IsNotTrapped                                             : std_logic := '0';
                -- Engine is trapped.
                constant WASMFPGAENGINE_VAL_IsTrapped                                                : std_logic := '1';


            -- 
            constant WASMFPGAENGINE_BUS_MASK_Busy                                                    : std_logic_vector(31 downto 0) := x"00000001";

                -- Engine is idle.
                constant WASMFPGAENGINE_VAL_IsNotBusy                                                : std_logic := '0';
                -- Engine is busy.
                constant WASMFPGAENGINE_VAL_IsBusy                                                   : std_logic := '1';


        -- ModuleInstanceUidReg: Module Instance UID Register 
        constant WASMFPGAENGINE_WIDTH_ModuleInstanceUidReg                                           : integer := 32;
        constant WASMFPGAENGINE_ADR_ModuleInstanceUidReg                                             : std_logic_vector(23 downto 0) := std_logic_vector(x"000008" + unsigned(WASMFPGAENGINE_ADR_BLK_BASE_EngineBlk));

            -- 

            constant WASMFPGAENGINE_BUS_MASK_ModuleInstanceUid                                       : std_logic_vector(31 downto 0) := x"FFFFFFFF";




end WasmFpgaEngineWshBn_Package;
