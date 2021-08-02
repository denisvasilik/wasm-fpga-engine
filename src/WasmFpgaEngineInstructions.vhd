library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaEnginePackage.all;
  use work.WasmFpgaStackWshBn_Package.all;

entity WasmFpgaEngineInstructions is
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        ToWasmFpgaInstruction : in T_ToWasmFpgaInstruction_Array;
        FromWasmFpgaInstruction : out T_FromWasmFpgaInstruction_Array;
        FromWasmFpgaStack : in T_FromWasmFpgaStack_Array;
        ToWasmFpgaStack : out T_ToWasmFpgaStack_Array;
        FromWasmFpgaModuleRam : in T_FromWasmFpgaModuleRam_Array;
        ToWasmFpgaModuleRam : out T_ToWasmFpgaModuleRam_Array;
        FromWasmFpgaMemory : in T_FromWasmFpgaMemory_Array;
        ToWasmFpgaMemory : out T_ToWasmFpgaMemory_Array;
        FromWasmFpgaStore : in T_FromWasmFpgaStore_Array;
        ToWasmFpgaStore : out T_ToWasmFpgaStore_Array
    );
end;

architecture WasmFpgaEngineInstructionsDefault of WasmFpgaEngineInstructions is

begin

    InstructionI32Ctz_i : entity work.InstructionI32Ctz
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CTZ)))
        );

    InstructionI32Const_i : entity work.InstructionI32Const
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CONST)))
        );

    InstructionEnd_i : entity work.InstructionEnd
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_END))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_END))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_END))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_END))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_END))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_END)))
        );

    InstructionNop_i : entity work.InstructionNop
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_NOP))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_NOP))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_NOP))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_NOP))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_NOP))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_NOP)))
        );

    InstructionI32And_i : entity work.InstructionI32And
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_AND)))
        );

    InstructionI32Popcnt_i : entity work.InstructionI32Popcnt
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_POPCNT)))
        );

    InstructionI32Or_i : entity work.InstructionI32Or
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_OR)))
        );

    InstructionDrop_i : entity work.InstructionDrop
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_DROP))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_DROP))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_DROP))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_DROP))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_DROP))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_DROP)))
        );

    InstructionI32Clz_i : entity work.InstructionI32Clz
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CLZ)))
        );

    InstructionI32Xor_i : entity work.InstructionI32Xor
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_XOR)))
        );

    InstructionI32Rotl_i : entity work.InstructionI32Rotl
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTL)))
        );

    InstructionI32Rotr_i : entity work.InstructionI32Rotr
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTR)))
        );

    InstructionI32Shl_i : entity work.InstructionI32Shl
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHL)))
        );

    InstructionI32Shrs_i : entity work.InstructionI32Shrs
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_S)))
        );

    InstructionI32Shru_i : entity work.InstructionI32Shru
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_U)))
        );

    InstructionUnreachable_i : entity work.InstructionUnreachable
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_UNREACHABLE)))
        );

    InstructionI32Eqz_i : entity work.InstructionI32Eqz
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQZ)))
        );

    InstructionI32Eq_i : entity work.InstructionI32Eq
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQ)))
        );

    InstructionI32Ne_i : entity work.InstructionI32Ne
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_NE)))
        );

    InstructionI32Lts_i : entity work.InstructionI32Lts
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_S)))
        );

    InstructionI32Ltu_i : entity work.InstructionI32Ltu
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_U)))
        );

    InstructionI32Ges_i : entity work.InstructionI32Ges
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_S)))
        );

    InstructionI32Geu_i : entity work.InstructionI32Geu
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_U)))
        );

    InstructionI32Gts_i : entity work.InstructionI32Gts
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_S)))
        );

    InstructionI32Gtu_i : entity work.InstructionI32Gtu
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_U)))
        );

    InstructionI32Les_i : entity work.InstructionI32Les
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_S)))
        );

    InstructionI32Leu_i : entity work.InstructionI32Leu
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_U)))
        );

    InstructionSelect_i : entity work.InstructionSelect
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_SELECT))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_SELECT))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_SELECT))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_SELECT))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_SELECT))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_SELECT)))
        );

    InstructionI32Add_i : entity work.InstructionI32Add
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ADD)))
        );

    InstructionI32Sub_i : entity work.InstructionI32Sub
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SUB)))
        );

    InstructionI32Mul_i : entity work.InstructionI32Mul
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_MUL)))
        );

    InstructionI32Divs_i : entity work.InstructionI32Divs
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_S)))
        );

    InstructionI32Divu_i : entity work.InstructionI32Divu
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_U)))
        );

    InstructionI32Rems_i : entity work.InstructionI32Rems
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_S)))
        );

    InstructionI32Remu_i : entity work.InstructionI32Remu
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_U)))
        );

    InstructionI32Store_i : entity work.InstructionI32Store
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_STORE)))
        );

    InstructionI32Load_i : entity work.InstructionI32Load
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LOAD)))
        );

    InstructionLocalGet_i : entity work.InstructionLocalGet
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_GET)))
        );

    InstructionLocalSet_i : entity work.InstructionLocalSet
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_SET)))
        );

    InstructionLocalTee_i : entity work.InstructionLocalTee
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_TEE)))
        );

    InstructionCall_i : entity work.InstructionCall
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaStore => FromWasmFpgaStore(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaStore => ToWasmFpgaStore(to_integer(unsigned(WASM_OPCODE_CALL)))
        );

    InstructionReturn_i : entity work.InstructionReturn
        port map (
            Clk => Clk,
            nRst => nRst,
            ToWasmFpgaInstruction => ToWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_RETURN))),
            FromWasmFpgaInstruction => FromWasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_RETURN))),
            FromWasmFpgaStack => FromWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_RETURN))),
            ToWasmFpgaStack => ToWasmFpgaStack(to_integer(unsigned(WASM_OPCODE_RETURN))),
            FromWasmFpgaModuleRam => FromWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_RETURN))),
            ToWasmFpgaModuleRam => ToWasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_RETURN))),
            FromWasmFpgaMemory => FromWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_RETURN))),
            ToWasmFpgaMemory => ToWasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_RETURN))),
            FromWasmFpgaStore => FromWasmFpgaStore(to_integer(unsigned(WASM_OPCODE_RETURN))),
            ToWasmFpgaStore => ToWasmFpgaStore(to_integer(unsigned(WASM_OPCODE_RETURN)))
        );

end;