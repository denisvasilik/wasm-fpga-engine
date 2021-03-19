


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package WasmFpgaStoreWshBn_Package is


-- type decalarations ---------------------------------                    

    type WasmFpgaStore_arr_of_std_logic_vector_2_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_3_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_4_t is                                        
      array (natural range <>) of std_logic_vector(3 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_5_t is                                        
      array (natural range <>) of std_logic_vector(4 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_6_t is                                        
      array (natural range <>) of std_logic_vector(5 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_7_t is                                        
      array (natural range <>) of std_logic_vector(6 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_8_t is                                        
      array (natural range <>) of std_logic_vector(7 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_9_t is                                        
      array (natural range <>) of std_logic_vector(8 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_10_t is                                    
      array (natural range <>) of std_logic_vector(9 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_11_t is                                    
      array (natural range <>) of std_logic_vector(10 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_12_t is                                    
      array (natural range <>) of std_logic_vector(11 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_13_t is                                    
      array (natural range <>) of std_logic_vector(12 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_14_t is                                    
      array (natural range <>) of std_logic_vector(13 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_15_t is                                    
      array (natural range <>) of std_logic_vector(14 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_16_t is                                    
      array (natural range <>) of std_logic_vector(15 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_24_t is                                    
      array (natural range <>) of std_logic_vector(23 downto 0);     

    type WasmFpgaStore_arr_of_std_logic_vector_32_t is                                    
      array (natural range <>) of std_logic_vector(31 downto 0);    


    type T_WasmFpgaStoreWshBnDn is
    record
        Adr :   std_logic_vector(23 downto 0);
        Sel :   std_logic_vector(3 downto 0);
        DatIn :   std_logic_vector(31 downto 0);
        We :   std_logic;
        Stb :   std_logic;
        Cyc :   std_logic_vector(0 downto 0);
    end record;

    type array_of_T_WasmFpgaStoreWshBnDn is
      array (natural range <>) of T_WasmFpgaStoreWshBnDn;


    type T_WasmFpgaStoreWshBnUp is
    record
        DatOut :   std_logic_vector(31 downto 0);
        Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaStoreWshBnUp is
      array (natural range <>) of T_WasmFpgaStoreWshBnUp;

    type T_WasmFpgaStoreWshBn_UnOccpdRcrd is
    record
        forRecord_Adr :   std_logic_vector(23 downto 0);
        forRecord_Sel :   std_logic_vector(3 downto 0);
        forRecord_We :   std_logic;
        forRecord_Cyc :   std_logic_vector(0 downto 0);
        Unoccupied_Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaStoreWshBn_UnOccpdRcrd is
      array (natural range <>) of T_WasmFpgaStoreWshBn_UnOccpdRcrd;

    type T_WasmFpgaStoreWshBn_StoreBlk is
    record
        Operation :   std_logic;
        Run :   std_logic;
        WRegPulse_ControlReg :   std_logic;
        ModuleInstanceUID :   std_logic_vector(31 downto 0);
        SectionUID :   std_logic_vector(31 downto 0);
        Idx :   std_logic_vector(31 downto 0);
        Address_Written :   std_logic_vector(31 downto 0);
    end record;

    type array_of_T_WasmFpgaStoreWshBn_StoreBlk is
      array (natural range <>) of T_WasmFpgaStoreWshBn_StoreBlk;


    type T_StoreBlk_WasmFpgaStoreWshBn is
    record
        Busy :   std_logic;
        Address_ToBeRead :   std_logic_vector(31 downto 0);
    end record;

    type array_of_T_StoreBlk_WasmFpgaStoreWshBn is
      array (natural range <>) of T_StoreBlk_WasmFpgaStoreWshBn;




    -- ---------- WebAssembly Store Block( StoreBlk ) ----------
    -- BUS: 

    constant WASMFPGASTORE_ADR_BLK_BASE_StoreBlk                                                     : std_logic_vector(23 downto 0) := x"000000";
    constant WASMFPGASTORE_ADR_BLK_SIZE_StoreBlk                                                     : std_logic_vector(23 downto 0) := x"000020";

        -- ControlReg: Control Register 
        constant WASMFPGASTORE_WIDTH_ControlReg                                                      : integer := 32;
        constant WASMFPGASTORE_ADR_ControlReg                                                        : std_logic_vector(23 downto 0) := std_logic_vector(x"000000" + unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk));

            -- 
            constant WASMFPGASTORE_BUS_MASK_Operation                                                : std_logic_vector(31 downto 0) := x"00000002";

                -- Use ModuleInstanceUID, SectionUID and Idx to read address from store
                constant WASMFPGASTORE_VAL_Read                                                      : std_logic := '0';
                -- Write ModuleInstanceUID, SectionUID and Idx to store
                constant WASMFPGASTORE_VAL_Write                                                     : std_logic := '1';


            -- 
            constant WASMFPGASTORE_BUS_MASK_Run                                                      : std_logic_vector(31 downto 0) := x"00000001";

                -- Do not load modules
                constant WASMFPGASTORE_VAL_DoNotRun                                                  : std_logic := '0';
                -- Load modules
                constant WASMFPGASTORE_VAL_DoRun                                                     : std_logic := '1';


        -- StatusReg: Status Register 
        constant WASMFPGASTORE_WIDTH_StatusReg                                                       : integer := 32;
        constant WASMFPGASTORE_ADR_StatusReg                                                         : std_logic_vector(23 downto 0) := std_logic_vector(x"000004" + unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk));

            -- 
            constant WASMFPGASTORE_BUS_MASK_Busy                                                     : std_logic_vector(31 downto 0) := x"00000001";

                -- Module loader is idle.
                constant WASMFPGASTORE_VAL_IsNotBusy                                                 : std_logic := '0';
                -- Module loader is busy.
                constant WASMFPGASTORE_VAL_IsBusy                                                    : std_logic := '1';


        -- ModuleInstanceUidReg: Module Instance UID Register 
        constant WASMFPGASTORE_WIDTH_ModuleInstanceUidReg                                            : integer := 32;
        constant WASMFPGASTORE_ADR_ModuleInstanceUidReg                                              : std_logic_vector(23 downto 0) := std_logic_vector(x"000008" + unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk));

            -- 

            constant WASMFPGASTORE_BUS_MASK_ModuleInstanceUID                                        : std_logic_vector(31 downto 0) := x"FFFFFFFF";

        -- SectionUidReg: Section Instance UID Register 
        constant WASMFPGASTORE_WIDTH_SectionUidReg                                                   : integer := 32;
        constant WASMFPGASTORE_ADR_SectionUidReg                                                     : std_logic_vector(23 downto 0) := std_logic_vector(x"00000C" + unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk));

            -- 

            constant WASMFPGASTORE_BUS_MASK_SectionUID                                               : std_logic_vector(31 downto 0) := x"FFFFFFFF";

        -- IdxReg: Module Section Idx Register 
        constant WASMFPGASTORE_WIDTH_IdxReg                                                          : integer := 32;
        constant WASMFPGASTORE_ADR_IdxReg                                                            : std_logic_vector(23 downto 0) := std_logic_vector(x"000010" + unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk));

            -- 

            constant WASMFPGASTORE_BUS_MASK_Idx                                                      : std_logic_vector(31 downto 0) := x"FFFFFFFF";

        -- AddressReg: Module Address Register 
        constant WASMFPGASTORE_WIDTH_AddressReg                                                      : integer := 32;
        constant WASMFPGASTORE_ADR_AddressReg                                                        : std_logic_vector(23 downto 0) := std_logic_vector(x"000014" + unsigned(WASMFPGASTORE_ADR_BLK_BASE_StoreBlk));

            -- 

            constant WASMFPGASTORE_BUS_MASK_Address                                                  : std_logic_vector(31 downto 0) := x"FFFFFFFF";




end WasmFpgaStoreWshBn_Package;
