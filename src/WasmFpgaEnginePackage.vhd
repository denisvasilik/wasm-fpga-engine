library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
  use work.WasmFpgaStackWshBn_Package.all;

package WasmFpgaEnginePackage is

    --
    -- Sections UIDs
    --
    constant SECTION_UID_TYPE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"01";
    constant SECTION_UID_IMPORT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"02";
    constant SECTION_UID_FUNCTION : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"03";
    constant SECTION_UID_TABLE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"04";
    constant SECTION_UID_MEMORY : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"05";
    constant SECTION_UID_GLOBAL : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"06";
    constant SECTION_UID_EXPORT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"07";
    constant SECTION_UID_START : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"08";
    constant SECTION_UID_ELEMENT : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"09";
    constant SECTION_UID_CODE : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"0A";
    constant SECTION_UID_DATA : std_logic_vector(31 downto 0) := (31 downto 8 => '0') & x"0B";

    --
    -- WebAssembly Opcodes
    --
    constant WASM_NO_OPCODE : std_logic_vector(7 downto 0) := x"FF";

    constant WASM_OPCODE_UNREACHABLE : std_logic_vector(7 downto 0) := x"00";
    constant WASM_OPCODE_NOP : std_logic_vector(7 downto 0) := x"01";
    constant WASM_OPCODE_BLOCK : std_logic_vector(7 downto 0) := x"02";
    constant WASM_OPCODE_LOOP : std_logic_vector(7 downto 0) := x"03";
    constant WASM_OPCODE_IF : std_logic_vector(7 downto 0) := x"04";
    constant WASM_OPCODE_ELSE : std_logic_vector(7 downto 0) := x"05";
    constant WASM_OPCODE_END : std_logic_vector(7 downto 0) := x"0B";
    constant WASM_OPCODE_BR : std_logic_vector(7 downto 0) := x"0C";
    constant WASM_OPCODE_BR_IF : std_logic_vector(7 downto 0) := x"0D";
    constant WASM_OPCODE_BR_TABLE : std_logic_vector(7 downto 0) := x"0E";
    constant WASM_OPCODE_RETURN : std_logic_vector(7 downto 0) := x"0F";
    constant WASM_OPCODE_CALL : std_logic_vector(7 downto 0) := x"10";
    constant WASM_OPCODE_CALL_INDIRECT : std_logic_vector(7 downto 0) := x"11";
    constant WASM_OPCODE_DROP : std_logic_vector(7 downto 0) := x"1A";
    constant WASM_OPCODE_SELECT : std_logic_vector(7 downto 0) := x"1B";
    constant WASM_OPCODE_LOCAL_GET : std_logic_vector(7 downto 0) := x"20";
    constant WASM_OPCODE_LOCAL_SET : std_logic_vector(7 downto 0) := x"21";
    constant WASM_OPCODE_LOCAL_TEE : std_logic_vector(7 downto 0) := x"22";
    constant WASM_OPCODE_GLOBAL_GET : std_logic_vector(7 downto 0) := x"23";
    constant WASM_OPCODE_GLOBAL_SET : std_logic_vector(7 downto 0) := x"24";
    constant WASM_OPCODE_I32_LOAD : std_logic_vector(7 downto 0) := x"28";
    constant WASM_OPCODE_I64_LOAD : std_logic_vector(7 downto 0) := x"29";
    constant WASM_OPCODE_F32_LOAD : std_logic_vector(7 downto 0) := x"2A";
    constant WASM_OPCODE_F64_LOAD : std_logic_vector(7 downto 0) := x"2B";
    constant WASM_OPCODE_I32_LOAD8_S : std_logic_vector(7 downto 0) := x"2C";
    constant WASM_OPCODE_I32_LOAD8_U : std_logic_vector(7 downto 0) := x"2D";
    constant WASM_OPCODE_I32_LOAD16_S : std_logic_vector(7 downto 0) := x"2E";
    constant WASM_OPCODE_I32_LOAD16_U : std_logic_vector(7 downto 0) := x"2F";
    constant WASM_OPCODE_I64_LOAD8_S : std_logic_vector(7 downto 0) := x"30";
    constant WASM_OPCODE_I64_LOAD8_U : std_logic_vector(7 downto 0) := x"31";
    constant WASM_OPCODE_I64_LOAD16_S : std_logic_vector(7 downto 0) := x"32";
    constant WASM_OPCODE_I64_LOAD16_U : std_logic_vector(7 downto 0) := x"33";
    constant WASM_OPCODE_I64_LOAD32_S : std_logic_vector(7 downto 0) := x"34";
    constant WASM_OPCODE_I64_LOAD32_U : std_logic_vector(7 downto 0) := x"35";
    constant WASM_OPCODE_I32_STORE : std_logic_vector(7 downto 0) := x"36";
    constant WASM_OPCODE_I64_STORE : std_logic_vector(7 downto 0) := x"37";
    constant WASM_OPCODE_F32_STORE : std_logic_vector(7 downto 0) := x"38";
    constant WASM_OPCODE_F64_STORE : std_logic_vector(7 downto 0) := x"39";
    constant WASM_OPCODE_I32_STORE8 : std_logic_vector(7 downto 0) := x"3A";
    constant WASM_OPCODE_I32_STORE16 : std_logic_vector(7 downto 0) := x"3B";
    constant WASM_OPCODE_I64_STORE8 : std_logic_vector(7 downto 0) := x"3A";
    constant WASM_OPCODE_I64_STORE16 : std_logic_vector(7 downto 0) := x"3D";
    constant WASM_OPCODE_I64_STORE32 : std_logic_vector(7 downto 0) := x"3E";
    constant WASM_OPCODE_MEMORY_SIZE : std_logic_vector(7 downto 0) := x"3F";
    constant WASM_OPCODE_MEMORY_GROW : std_logic_vector(7 downto 0) := x"40";
    constant WASM_OPCODE_I32_CONST : std_logic_vector(7 downto 0) := x"41";
    constant WASM_OPCODE_I64_CONST : std_logic_vector(7 downto 0) := x"42";
    constant WASM_OPCODE_F32_CONST : std_logic_vector(7 downto 0) := x"43";
    constant WASM_OPCODE_F64_CONST : std_logic_vector(7 downto 0) := x"44";
    constant WASM_OPCODE_I32_EQZ : std_logic_vector(7 downto 0) := x"45";
    constant WASM_OPCODE_I32_EQ : std_logic_vector(7 downto 0) := x"46";
    constant WASM_OPCODE_I32_NE : std_logic_vector(7 downto 0) := x"47";
    constant WASM_OPCODE_I32_LT_S : std_logic_vector(7 downto 0) := x"48";
    constant WASM_OPCODE_I32_LT_U : std_logic_vector(7 downto 0) := x"49";
    constant WASM_OPCODE_I32_GT_S : std_logic_vector(7 downto 0) := x"4A";
    constant WASM_OPCODE_I32_GT_U : std_logic_vector(7 downto 0) := x"4B";
    constant WASM_OPCODE_I32_LE_S : std_logic_vector(7 downto 0) := x"4C";
    constant WASM_OPCODE_I32_LE_U : std_logic_vector(7 downto 0) := x"4D";
    constant WASM_OPCODE_I32_GE_S : std_logic_vector(7 downto 0) := x"4E";
    constant WASM_OPCODE_I32_GE_U : std_logic_vector(7 downto 0) := x"4F";
    constant WASM_OPCODE_I64_EQZ : std_logic_vector(7 downto 0) := x"50";
    constant WASM_OPCODE_I64_EQ : std_logic_vector(7 downto 0) := x"51";
    constant WASM_OPCODE_I64_NE : std_logic_vector(7 downto 0) := x"52";
    constant WASM_OPCODE_I64_LT_S : std_logic_vector(7 downto 0) := x"53";
    constant WASM_OPCODE_I64_LT_U : std_logic_vector(7 downto 0) := x"54";
    constant WASM_OPCODE_I64_GT_S : std_logic_vector(7 downto 0) := x"55";
    constant WASM_OPCODE_I64_GT_U : std_logic_vector(7 downto 0) := x"56";
    constant WASM_OPCODE_I64_LE_S : std_logic_vector(7 downto 0) := x"57";
    constant WASM_OPCODE_I64_LE_U : std_logic_vector(7 downto 0) := x"58";
    constant WASM_OPCODE_I64_GE_S : std_logic_vector(7 downto 0) := x"59";
    constant WASM_OPCODE_I64_GE_U : std_logic_vector(7 downto 0) := x"5A";
    constant WASM_OPCODE_F32_EQ : std_logic_vector(7 downto 0) := x"5B";
    constant WASM_OPCODE_F32_NE : std_logic_vector(7 downto 0) := x"5C";
    constant WASM_OPCODE_F32_LT : std_logic_vector(7 downto 0) := x"5D";
    constant WASM_OPCODE_F32_GT : std_logic_vector(7 downto 0) := x"5E";
    constant WASM_OPCODE_F32_LE : std_logic_vector(7 downto 0) := x"5F";
    constant WASM_OPCODE_F32_GE : std_logic_vector(7 downto 0) := x"60";
    constant WASM_OPCODE_F64_EQ : std_logic_vector(7 downto 0) := x"61";
    constant WASM_OPCODE_F64_NE : std_logic_vector(7 downto 0) := x"62";
    constant WASM_OPCODE_F64_LT : std_logic_vector(7 downto 0) := x"63";
    constant WASM_OPCODE_F64_GT : std_logic_vector(7 downto 0) := x"64";
    constant WASM_OPCODE_F64_LE : std_logic_vector(7 downto 0) := x"65";
    constant WASM_OPCODE_F64_GE : std_logic_vector(7 downto 0) := x"66";
    constant WASM_OPCODE_I32_CLZ : std_logic_vector(7 downto 0) := x"67";
    constant WASM_OPCODE_I32_CTZ : std_logic_vector(7 downto 0) := x"68";
    constant WASM_OPCODE_I32_POPCNT : std_logic_vector(7 downto 0) := x"69";
    constant WASM_OPCODE_I32_ADD : std_logic_vector(7 downto 0) := x"6A";
    constant WASM_OPCODE_I32_SUB : std_logic_vector(7 downto 0) := x"6B";
    constant WASM_OPCODE_I32_MUL : std_logic_vector(7 downto 0) := x"6C";
    constant WASM_OPCODE_I32_DIV_S : std_logic_vector(7 downto 0) := x"6D";
    constant WASM_OPCODE_I32_DIV_U : std_logic_vector(7 downto 0) := x"6E";
    constant WASM_OPCODE_I32_REM_S : std_logic_vector(7 downto 0) := x"6F";
    constant WASM_OPCODE_I32_REM_U : std_logic_vector(7 downto 0) := x"70";
    constant WASM_OPCODE_I32_AND : std_logic_vector(7 downto 0) := x"71";
    constant WASM_OPCODE_I32_OR : std_logic_vector(7 downto 0) := x"72";
    constant WASM_OPCODE_I32_XOR : std_logic_vector(7 downto 0) := x"73";
    constant WASM_OPCODE_I32_SHL : std_logic_vector(7 downto 0) := x"74";
    constant WASM_OPCODE_I32_SHR_S : std_logic_vector(7 downto 0) := x"75";
    constant WASM_OPCODE_I32_SHR_U : std_logic_vector(7 downto 0) := x"76";
    constant WASM_OPCODE_I32_ROTL : std_logic_vector(7 downto 0) := x"77";
    constant WASM_OPCODE_I32_ROTR : std_logic_vector(7 downto 0) := x"78";
    constant WASM_OPCODE_I64_CLZ : std_logic_vector(7 downto 0) := x"79";
    constant WASM_OPCODE_I64_CTZ : std_logic_vector(7 downto 0) := x"7A";
    constant WASM_OPCODE_I64_POPCNT : std_logic_vector(7 downto 0) := x"7B";
    constant WASM_OPCODE_I64_ADD : std_logic_vector(7 downto 0) := x"7C";
    constant WASM_OPCODE_I64_SUB : std_logic_vector(7 downto 0) := x"7D";
    constant WASM_OPCODE_I64_MUL : std_logic_vector(7 downto 0) := x"7E";
    constant WASM_OPCODE_I64_DIV_S : std_logic_vector(7 downto 0) := x"7F";
    constant WASM_OPCODE_I64_DIV_U : std_logic_vector(7 downto 0) := x"80";
    constant WASM_OPCODE_I64_REM_S : std_logic_vector(7 downto 0) := x"81";
    constant WASM_OPCODE_I64_REM_U : std_logic_vector(7 downto 0) := x"82";
    constant WASM_OPCODE_I64_AND : std_logic_vector(7 downto 0) := x"83";
    constant WASM_OPCODE_I64_OR : std_logic_vector(7 downto 0) := x"84";
    constant WASM_OPCODE_I64_XOR : std_logic_vector(7 downto 0) := x"85";
    constant WASM_OPCODE_I64_SHL : std_logic_vector(7 downto 0) := x"86";
    constant WASM_OPCODE_I64_SHR_S : std_logic_vector(7 downto 0) := x"87";
    constant WASM_OPCODE_I64_SHR_U : std_logic_vector(7 downto 0) := x"88";
    constant WASM_OPCODE_I64_ROTL : std_logic_vector(7 downto 0) := x"89";
    constant WASM_OPCODE_I64_ROTR : std_logic_vector(7 downto 0) := x"8A";
    constant WASM_OPCODE_F32_ABS : std_logic_vector(7 downto 0) := x"8B";
    constant WASM_OPCODE_F32_NEG : std_logic_vector(7 downto 0) := x"8C";
    constant WASM_OPCODE_F32_CEIL : std_logic_vector(7 downto 0) := x"8D";
    constant WASM_OPCODE_F32_FLOOR : std_logic_vector(7 downto 0) := x"8E";
    constant WASM_OPCODE_F32_TRUNC : std_logic_vector(7 downto 0) := x"8F";
    constant WASM_OPCODE_F32_NEAREST : std_logic_vector(7 downto 0) := x"90";
    constant WASM_OPCODE_F32_SQRT : std_logic_vector(7 downto 0) := x"91";
    constant WASM_OPCODE_F32_ADD : std_logic_vector(7 downto 0) := x"92";
    constant WASM_OPCODE_F32_SUB : std_logic_vector(7 downto 0) := x"93";
    constant WASM_OPCODE_F32_MUL : std_logic_vector(7 downto 0) := x"94";
    constant WASM_OPCODE_F32_DIV : std_logic_vector(7 downto 0) := x"95";
    constant WASM_OPCODE_F32_MIN : std_logic_vector(7 downto 0) := x"96";
    constant WASM_OPCODE_F32_MAX : std_logic_vector(7 downto 0) := x"97";
    constant WASM_OPCODE_F32_COPYSIGN : std_logic_vector(7 downto 0) := x"98";
    constant WASM_OPCODE_F64_ABS : std_logic_vector(7 downto 0) := x"99";
    constant WASM_OPCODE_F64_NEG : std_logic_vector(7 downto 0) := x"9A";
    constant WASM_OPCODE_F64_CEIL : std_logic_vector(7 downto 0) := x"9B";
    constant WASM_OPCODE_F64_FLOOR : std_logic_vector(7 downto 0) := x"9C";
    constant WASM_OPCODE_F64_TRUNC : std_logic_vector(7 downto 0) := x"9D";
    constant WASM_OPCODE_F64_NEAREST : std_logic_vector(7 downto 0) := x"9E";
    constant WASM_OPCODE_F64_SQRT : std_logic_vector(7 downto 0) := x"9F";
    constant WASM_OPCODE_F64_ADD : std_logic_vector(7 downto 0) := x"A0";
    constant WASM_OPCODE_F64_SUB : std_logic_vector(7 downto 0) := x"A1";
    constant WASM_OPCODE_F64_MUL : std_logic_vector(7 downto 0) := x"A2";
    constant WASM_OPCODE_F64_DIV : std_logic_vector(7 downto 0) := x"A3";
    constant WASM_OPCODE_F64_MIN : std_logic_vector(7 downto 0) := x"A4";
    constant WASM_OPCODE_F64_MAX : std_logic_vector(7 downto 0) := x"A5";
    constant WASM_OPCODE_F64_COPYSIGN : std_logic_vector(7 downto 0) := x"A6";
    constant WASM_OPCODE_I32_WRAP_I64 : std_logic_vector(7 downto 0) := x"A7";
    constant WASM_OPCODE_I32_TRuNC_F32_S : std_logic_vector(7 downto 0) := x"A8";
    constant WASM_OPCODE_I32_TRUNC_F32_U : std_logic_vector(7 downto 0) := x"A9";
    constant WASM_OPCODE_I32_TRUNC_F64_S : std_logic_vector(7 downto 0) := x"AA";
    constant WASM_OPCODE_I32_TRUNC_F64_U : std_logic_vector(7 downto 0) := x"AB";
    constant WASM_OPCODE_I64_EXTEND_I32_S : std_logic_vector(7 downto 0) := x"AC";
    constant WASM_OPCODE_I64_EXTEND_I32_U : std_logic_vector(7 downto 0) := x"AD";
    constant WASM_OPCODE_I64_TRUNC_F32_S : std_logic_vector(7 downto 0) := x"AE";
    constant WASM_OPCODE_I64_TRUNC_F32_U : std_logic_vector(7 downto 0) := x"AF";
    constant WASM_OPCODE_I64_TRUNC_F64_S : std_logic_vector(7 downto 0) := x"B0";
    constant WASM_OPCODE_I64_TRUNC_F64_U : std_logic_vector(7 downto 0) := x"B1";
    constant WASM_OPCODE_F32_CONVERT_I32_S : std_logic_vector(7 downto 0) := x"B2";
    constant WASM_OPCODE_F32_CONVERT_I32_U : std_logic_vector(7 downto 0) := x"B3";
    constant WASM_OPCODE_F32_CONVERT_I64_S : std_logic_vector(7 downto 0) := x"B4";
    constant WASM_OPCODE_F32_CONVERT_I64_U : std_logic_vector(7 downto 0) := x"B5";
    constant WASM_OPCODE_F32_DEMOTE_F64 : std_logic_vector(7 downto 0) := x"B6";
    constant WASM_OPCODE_F64_CONVERT_I32_S : std_logic_vector(7 downto 0) := x"B7";
    constant WASM_OPCODE_F64_CONVERT_I32_U : std_logic_vector(7 downto 0) := x"B8";
    constant WASM_OPCODE_F64_CONVERT_I64_S : std_logic_vector(7 downto 0) := x"B9";
    constant WASM_OPCODE_F64_CONVERT_I64_U : std_logic_vector(7 downto 0) := x"BA";
    constant WASM_OPCODE_F64_PROMOTE_F32 : std_logic_vector(7 downto 0) := x"BB";
    constant WASM_OPCODE_I32_REINTERPRET_F32 : std_logic_vector(7 downto 0) := x"BC";
    constant WASM_OPCODE_I64_REINTERPRET_F64 : std_logic_vector(7 downto 0) := x"BD";
    constant WASM_OPCODE_F32_REINTERPRET_I32 : std_logic_vector(7 downto 0) := x"BE";
    constant WASM_OPCODE_F64_REINTERPRET_I64 : std_logic_vector(7 downto 0) := x"BF";

    --
    -- WebAssembly Engine States
    --
    constant EngineStateIdle : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"00";
    constant EngineStateExec0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"01";
    constant EngineStateDispatch0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"02";
    constant EngineStateReadRam0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"03";
    constant EngineStateReadRam1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"04";
    constant EngineStateReadRam2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"05";
    constant EngineStateStartFuncIdx0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"06";
    constant EngineStateStartFuncIdx1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"07";
    constant EngineStateStartFuncIdx2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"08";
    constant EngineStateStartFuncIdx3 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"09";
    constant EngineStateStartFuncIdx4 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0A";
    constant EngineStateStartFuncIdx5 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0B";
    constant EngineStateStartFuncIdx6 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0C";
    constant EngineStateStartFuncIdx7 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0D";
    constant EngineStateStartFuncIdx8 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"0E";
    constant EngineStateActivationFrame0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"10";
    constant EngineStateActivationFrame1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"11";
    constant EngineStateActivationFrame2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"12";
    constant EngineStateActivationFrame3 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"13";
    constant EngineStatePush0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"20";
    constant EngineStatePush1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"21";
    constant EngineStatePush2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"22";
    constant EngineStatePop0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"23";
    constant EngineStatePop1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"24";
    constant EngineStatePop2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"25";
    constant EngineStateReadU32_0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A0";
    constant EngineStateReadU32_1 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A1";
    constant EngineStateReadU32_2 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A2";
    constant EngineStateReadU32_3 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A3";
    constant EngineStateReadU32_4 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A4";
    constant EngineStateReadU32_5 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"A5";
    constant EngineStateTrap0 : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"FE";
    constant EngineStateError : std_logic_vector(15 downto 0) := WASM_NO_OPCODE & x"FF";
    constant EngineStateOpcodeUnreachable0 : std_logic_vector(15 downto 0) := WASM_OPCODE_UNREACHABLE & x"00";
    constant EngineStateOpcodeNop0 : std_logic_vector(15 downto 0) := WASM_OPCODE_NOP & x"00";
    constant EngineStateOpcodeEnd0 : std_logic_vector(15 downto 0) := WASM_OPCODE_END & x"00";
    constant EngineStateI32Const0 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CONST & x"00";
    constant EngineStateI32Const1 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CONST & x"01";
    constant EngineStateI32Const2 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CONST & x"02";
    constant EngineStateDrop0 : std_logic_vector(15 downto 0) := WASM_OPCODE_DROP & x"00";
    constant EngineStateI32Ctz0 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CTZ & x"00";
    constant EngineStateI32Ctz1 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CTZ & x"01";
    constant EngineStateI32Ctz2 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CTZ & x"02";
    constant EngineStateI32Clz0 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CLZ & x"00";
    constant EngineStateI32Clz1 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CLZ & x"01";
    constant EngineStateI32Clz2 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_CLZ & x"02";
    constant EngineStateI32Popcnt0 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_POPCNT & x"00";
    constant EngineStateI32Popcnt1 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_POPCNT & x"01";
    constant EngineStateI32Popcnt2 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_POPCNT & x"02";
    constant EngineStateI32And0 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_AND & x"00";
    constant EngineStateI32And1 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_AND & x"01";
    constant EngineStateI32And2 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_AND & x"02";
    constant EngineStateI32And3 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_AND & x"03";
    constant EngineStateI32And4 : std_logic_vector(15 downto 0) := WASM_OPCODE_I32_AND & x"04";

    constant StateIdle : std_logic_vector(15 downto 0) := x"0000";
    constant State0 : std_logic_vector(15 downto 0) := x"0001";
    constant State1 : std_logic_vector(15 downto 0) := x"0002";
    constant State2 : std_logic_vector(15 downto 0) := x"0003";
    constant State3 : std_logic_vector(15 downto 0) := x"0004";

    type T_WshBnUp is
    record
        DatOut : std_logic_vector(31 downto 0);
        Ack : std_logic;
    end record;

    type T_WshBnDown is
    record
          Adr : std_logic_vector(23 downto 0);
          Sel : std_logic_vector(3 downto 0);
          DatIn : std_logic_vector(31 downto 0);
          We : std_logic;
          Stb : std_logic;
          Cyc : std_logic_vector(0 downto 0);
    end record;

    type T_WasmFpgaStack is
    record
        Run : std_logic;
        Action : std_logic;
        Busy : std_logic;
    end record;

    type T_WasmFpgaModuleRam is
    record
        Run : std_logic;
        Busy : std_logic;
        Data : std_logic_vector(31 downto 0);
        CurrentByte : std_logic_vector(7 downto 0);
        Address : std_logic_vector(23 downto 0);
        DecodedValue : std_logic_vector(31 downto 0);
    end record;

    type T_WasmFpgaEngine is
    record
        State : std_logic_vector(15 downto 0);
        ReturnState : std_logic_vector(15 downto 0);
        PushToStackState : std_logic_vector(3 downto 0);
        PopFromStackState : std_logic_vector(3 downto 0);
        ReadU32State : std_logic_vector(3 downto 0);
        ReadFromModuleRamState : std_logic_vector(3 downto 0);
    end record;

    type T_WasmFpgaInstruction is
    record
        State : std_logic_vector(15 downto 0);
        ReturnState : std_logic_vector(15 downto 0);
        PushToStackState : std_logic_vector(3 downto 0);
        PopFromStackState : std_logic_vector(3 downto 0);
        ReadU32State : std_logic_vector(3 downto 0);
        ReadFromModuleRamState : std_logic_vector(3 downto 0);
    end record;

    type T_WasmFpgaStack_WasmFpgaInstruction is
    record
        Busy : std_logic;
        HighValue : std_logic_vector(31 downto 0);
        LowValue : std_logic_vector(31 downto 0);
    end record;

    type T_WasmFpgaInstruction_WasmFpgaStack is
    record
        Run : std_logic;
        Action : std_logic;
        ValueType : std_logic_vector(2 downto 0);
        HighValue : std_logic_vector(31 downto 0);
        LowValue : std_logic_vector(31 downto 0);
    end record;

    function ctz(value: std_logic_vector) return std_logic_vector;

    function clz(value: std_logic_vector) return std_logic_vector;

    function popcnt(value: std_logic_vector) return std_logic_vector;

    function i32_and(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

    procedure PopFromStack(signal State : out std_logic_vector;
                           constant ReturnState : in std_logic_vector;
                           signal Engine : inout T_WasmFpgaEngine;
                           signal Stack : inout T_WasmFpgaStack);

    procedure PushToStack(signal State : out std_logic_vector;
                          constant ReturnState : in std_logic_vector;
                          signal Engine : inout T_WasmFpgaEngine;
                          signal Stack : inout T_WasmFpgaStack);

    procedure ReadFromModuleRam(signal State : out std_logic_vector;
                                constant ReturnState : in std_logic_vector;
                                signal Engine : inout T_WasmFpgaEngine;
                                signal ModuleRam : inout T_WasmFpgaModuleRam);

    procedure ReadU32(signal State : out std_logic_vector;
                      constant ReturnState : in std_logic_vector;
                      signal Engine : inout T_WasmFpgaEngine;
                      signal ModuleRam : inout T_WasmFpgaModuleRam);

end;

package body WasmFpgaEnginePackage is

    --
    -- Read u32 (LEB128 encoded)
    --
    procedure ReadU32(signal State : out std_logic_vector;
                      constant ReturnState : in std_logic_vector;
                      signal Engine : inout T_WasmFpgaEngine;
                      signal ModuleRam : inout T_WasmFpgaModuleRam)
    is
        constant State0 : std_logic_vector(3 downto 0) := x"0";
        constant State1 : std_logic_vector(3 downto 0) := x"1";
        constant State2 : std_logic_vector(3 downto 0) := x"2";
        constant State3 : std_logic_vector(3 downto 0) := x"3";
        constant State4 : std_logic_vector(3 downto 0) := x"4";
    begin
        if (Engine.ReadU32State = State0) then
            ModuleRam.DecodedValue <= (others => '0');
            ReadFromModuleRam(Engine.ReadU32State, State1, Engine, ModuleRam);
        elsif (Engine.ReadU32State = State1) then
            if ((ModuleRam.CurrentByte and x"80") = x"00") then
                -- 1 byte
                ModuleRam.DecodedValue(6 downto 0) <= ModuleRam.CurrentByte(6 downto 0);
                Engine.ReadU32State <= (others => '0');
                State <= ReturnState;
            else
                ReadFromModuleRam(Engine.ReadU32State, State2, Engine, ModuleRam);
            end if;
        elsif (Engine.ReadU32State = State2) then
            if ((ModuleRam.CurrentByte and x"80") = x"00") then
                -- 2 byte
                ModuleRam.DecodedValue(13 downto 7) <= ModuleRam.CurrentByte(6 downto 0);
                Engine.ReadU32State <= (others => '0');
                State <= ReturnState;
            else
                ReadFromModuleRam(Engine.ReadU32State, State3, Engine, ModuleRam);
            end if;
        elsif (Engine.ReadU32State = State3) then
            if ((ModuleRam.CurrentByte and x"80") = x"00") then
                -- 3 byte
                ModuleRam.DecodedValue(20 downto 14) <= ModuleRam.CurrentByte(6 downto 0);
                Engine.ReadU32State <= (others => '0');
                State <= ReturnState;
            else
                ReadFromModuleRam(Engine.ReadU32State, State4, Engine, ModuleRam);
            end if;
        elsif (Engine.ReadU32State = State4) then
            if ((ModuleRam.CurrentByte and x"80") = x"00") then
                -- 4 byte
                ModuleRam.DecodedValue(27 downto 21) <= ModuleRam.CurrentByte(6 downto 0);
                Engine.ReadU32State <= (others => '0');
                State <= ReturnState;
            else
                -- Greater than u32 not supported
                State <= (others => '1');
            end if;
        else
            -- Error state by convention
            State <= (others => '1');
        end if;
    end;

    procedure ReadFromModuleRam(signal State : out std_logic_vector;
                                constant ReturnState : in std_logic_vector;
                                signal Engine : inout T_WasmFpgaEngine;
                                signal ModuleRam : inout T_WasmFpgaModuleRam)
    is
        constant State0 : std_logic_vector(3 downto 0) := x"0";
        constant State1 : std_logic_vector(3 downto 0) := x"1";
        constant State2 : std_logic_vector(3 downto 0) := x"2";
        constant State3 : std_logic_vector(3 downto 0) := x"3";
        constant State4 : std_logic_vector(3 downto 0) := x"4";
    begin
        if (Engine.ReadFromModuleRamState = State0) then
            ModuleRam.Run <= '1';
            Engine.ReadFromModuleRamState <= State1;
        elsif (Engine.ReadFromModuleRamState = State1) then
            Engine.ReadFromModuleRamState <= State2;
        elsif (Engine.ReadFromModuleRamState = State2) then
            ModuleRam.Run <= '0';
            Engine.ReadFromModuleRamState <= State3;
        elsif (Engine.ReadFromModuleRamState = State3) then
            Engine.ReadFromModuleRamState <= State4;
        elsif (Engine.ReadFromModuleRamState = State4) then
            if (ModuleRam.Busy = '0') then
                if ModuleRam.Address(1 downto 0) = "00" then
                    ModuleRam.CurrentByte <= ModuleRam.Data(7 downto 0);
                elsif ModuleRam.Address(1 downto 0) = "01" then
                    ModuleRam.CurrentByte <= ModuleRam.Data(15 downto 8);
                elsif ModuleRam.Address(1 downto 0) = "10" then
                    ModuleRam.CurrentByte <= ModuleRam.Data(23 downto 16);
                else
                    ModuleRam.CurrentByte <= ModuleRam.Data(31 downto 24);
                end if;
                ModuleRam.Address <= std_logic_vector(unsigned(ModuleRam.Address) + 1);
                Engine.ReadFromModuleRamState <= (others => '0');
                State <= ReturnState;
            end if;
        else
            -- Error state by convention
            State <= (others => '1');
        end if;
    end;

    procedure PopFromStack(signal State : out std_logic_vector;
                           constant ReturnState : in std_logic_vector;
                           signal Engine : inout T_WasmFpgaEngine;
                           signal Stack : inout T_WasmFpgaStack)
    is
        constant StatePop0 : std_logic_vector(3 downto 0) := x"0";
        constant StatePop1 : std_logic_vector(3 downto 0) := x"1";
        constant StatePop2 : std_logic_vector(3 downto 0) := x"2";
        constant StatePop3 : std_logic_vector(3 downto 0) := x"3";
        constant StatePop4 : std_logic_vector(3 downto 0) := x"4";
        constant StatePop5 : std_logic_vector(3 downto 0) := x"5";
        constant StatePop6 : std_logic_vector(3 downto 0) := x"6";
    begin
        if (Engine.PopFromStackState = StatePop0) then
            Stack.Run <= '1';
            Stack.Action <= WASMFPGASTACK_VAL_Pop;
            Engine.PopFromStackState <= StatePop1;
        elsif (Engine.PopFromStackState = StatePop1) then
            Stack.Run <= '0';
            Engine.PopFromStackState <= StatePop2;
        elsif (Engine.PopFromStackState = StatePop2) then
            Engine.PopFromStackState <= StatePop3;
        elsif (Engine.PopFromStackState = StatePop3) then
            Engine.PopFromStackState <= StatePop4;
        elsif (Engine.PopFromStackState = StatePop4) then
            Engine.PopFromStackState <= StatePop5;
        elsif (Engine.PopFromStackState = StatePop5) then
            Engine.PopFromStackState <= StatePop6;
        elsif (Engine.PopFromStackState = StatePop6) then
            if (Stack.Busy = '0') then
                Engine.PopFromStackState <= (others => '0');
                Engine.State <= ReturnState;
            end if;
        else
            -- Error state by convention
            State <= (others => '1');
        end if;
    end;


    procedure PushToStack(signal State : out std_logic_vector;
                          constant ReturnState : in std_logic_vector;
                          signal Engine : inout T_WasmFpgaEngine;
                          signal Stack : inout T_WasmFpgaStack)
    is
        constant StatePush0 : std_logic_vector(3 downto 0) := x"0";
        constant StatePush1 : std_logic_vector(3 downto 0) := x"1";
        constant StatePush2 : std_logic_vector(3 downto 0) := x"2";
        constant StatePush3 : std_logic_vector(3 downto 0) := x"3";
    begin
        if (Engine.PushToStackState = StatePush0) then
            Stack.Run <= '1';
            Stack.Action <= WASMFPGASTACK_VAL_Push;
            Engine.PushToStackState <= StatePush1;
        elsif (Engine.PushToStackState = StatePush1) then
            Stack.Run <= '0';
            Engine.PushToStackState <= StatePush2;
        elsif (Engine.PushToStackState = StatePush2) then
            Engine.PushToStackState <= StatePush3;
        elsif (Engine.PushToStackState = StatePush3) then
            if (Stack.Busy = '0') then
                Engine.PushToStackState <= (others => '0');
                Engine.State <= ReturnState;
            end if;
        else
            State <= (others => '1');
        end if;
    end;


    function ctz(value: std_logic_vector)
        return std_logic_vector
    is
        variable total : integer range 0 to value'length := 0;
    begin
        for i in value'reverse_range loop
            if value(i) = '1' then
                exit;
            else
                total := total + 1;
            end if;
        end loop;
        return std_logic_vector(to_unsigned(total, value'length));
    end;

    function clz(value: std_logic_vector)
        return std_logic_vector
    is
        variable total : integer range 0 to value'length := 0;
    begin
        for i in value'range loop
            if value(i) = '1' then
                exit;
            else
                total := total + 1;
            end if;
        end loop;
        return std_logic_vector(to_unsigned(total, value'length));
    end;

    function popcnt(value: std_logic_vector)
        return std_logic_vector
    is
        variable total : integer range 0 to value'length := 0;
    begin
        for i in value'range loop
            if value(i) = '1' then
                total := total + 1;
            end if;
        end loop;
        return std_logic_vector(to_unsigned(total, value'length));
    end;

    function i32_and(a: std_logic_vector; b: std_logic_vector)
        return std_logic_vector
    is
    begin
        return a and b;
    end;

end;
