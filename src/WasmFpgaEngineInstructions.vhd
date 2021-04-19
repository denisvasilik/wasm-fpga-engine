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
        WasmFpgaInvocation_WasmFpgaInstruction : in T_WasmFpgaInvocation_WasmFpgaInstruction_Array;
        WasmFpgaInstruction_WasmFpgaInvocation : out T_WasmFpgaInstruction_WasmFpgaInvocation_Array;
        WasmFpgaStack_WasmFpgaInstruction : in T_WasmFpgaStack_WasmFpgaInstruction_Array;
        WasmFpgaInstruction_WasmFpgaStack : out T_WasmFpgaInstruction_WasmFpgaStack_Array;
        WasmFpgaModuleRam_WasmFpgaInstruction : in T_WasmFpgaModuleRam_WasmFpgaInstruction_Array;
        WasmFpgaInstruction_WasmFpgaModuleRam : buffer T_WasmFpgaInstruction_WasmFpgaModuleRam_Array;
        WasmFpgaMemory_WasmFpgaInstruction : in T_WasmFpgaMemory_WasmFpgaInstruction_Array;
        WasmFpgaInstruction_WasmFpgaMemory : out T_WasmFpgaInstruction_WasmFpgaMemory_Array;
        WasmFpgaStore_WasmFpgaInstruction : in T_WasmFpgaStore_WasmFpgaInstruction_Array;
        WasmFpgaInstruction_WasmFpgaStore : out T_WasmFpgaInstruction_WasmFpgaStore_Array
    );
end;

architecture WasmFpgaEngineInstructionsDefault of WasmFpgaEngineInstructions is

begin


    InstructionI32Ctz_i : entity work.InstructionI32Ctz
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CTZ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CTZ)))
        );

    InstructionI32Const_i : entity work.InstructionI32Const
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CONST))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CONST)))
        );

    InstructionEnd_i : entity work.InstructionEnd
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_END))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_END)))
        );

    InstructionNop_i : entity work.InstructionNop
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_NOP))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_NOP)))
        );

    InstructionI32And_i : entity work.InstructionI32And
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_AND))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_AND)))
        );

    InstructionI32Popcnt_i : entity work.InstructionI32Popcnt
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_POPCNT))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_POPCNT)))
        );

    InstructionI32Or_i : entity work.InstructionI32Or
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_OR))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_OR)))
        );

    InstructionDrop_i : entity work.InstructionDrop
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_DROP))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_DROP)))
        );

    InstructionI32Clz_i : entity work.InstructionI32Clz
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_CLZ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_CLZ)))
        );

    InstructionI32Xor_i : entity work.InstructionI32Xor
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_XOR))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_XOR)))
        );

    InstructionI32Rotl_i : entity work.InstructionI32Rotl
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTL))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTL)))
        );

    InstructionI32Rotr_i : entity work.InstructionI32Rotr
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ROTR))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ROTR)))
        );

    InstructionI32Shl_i : entity work.InstructionI32Shl
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHL))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHL)))
        );

    InstructionI32Shrs_i : entity work.InstructionI32Shrs
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_S)))
        );

    InstructionI32Shru_i : entity work.InstructionI32Shru
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SHR_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SHR_U)))
        );

    InstructionUnreachable_i : entity work.InstructionUnreachable
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_UNREACHABLE))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_UNREACHABLE)))
        );

    InstructionI32Eqz_i : entity work.InstructionI32Eqz
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQZ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQZ)))
        );

    InstructionI32Eq_i : entity work.InstructionI32Eq
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_EQ))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_EQ)))
        );

    InstructionI32Ne_i : entity work.InstructionI32Ne
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_NE))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_NE)))
        );

    InstructionI32Lts_i : entity work.InstructionI32Lts
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_S)))
        );

    InstructionI32Ltu_i : entity work.InstructionI32Ltu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LT_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LT_U)))
        );

    InstructionI32Ges_i : entity work.InstructionI32Ges
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_S)))
        );

    InstructionI32Geu_i : entity work.InstructionI32Geu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GE_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GE_U)))
        );

    InstructionI32Gts_i : entity work.InstructionI32Gts
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_S)))
        );

    InstructionI32Gtu_i : entity work.InstructionI32Gtu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_GT_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_GT_U)))
        );

    InstructionI32Les_i : entity work.InstructionI32Les
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_S)))
        );

    InstructionI32Leu_i : entity work.InstructionI32Leu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LE_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LE_U)))
        );

    InstructionSelect_i : entity work.InstructionSelect
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_SELECT))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_SELECT)))
        );

    InstructionI32Add_i : entity work.InstructionI32Add
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_ADD))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_ADD)))
        );

    InstructionI32Sub_i : entity work.InstructionI32Sub
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_SUB))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_SUB)))
        );

    InstructionI32Mul_i : entity work.InstructionI32Mul
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_MUL))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_MUL)))
        );

    InstructionI32Divs_i : entity work.InstructionI32Divs
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_S)))
        );

    InstructionI32Divu_i : entity work.InstructionI32Divu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_DIV_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_DIV_U)))
        );

    InstructionI32Rems_i : entity work.InstructionI32Rems
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_S))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_S)))
        );

    InstructionI32Remu_i : entity work.InstructionI32Remu
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_REM_U))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_REM_U)))
        );

    InstructionI32Store_i : entity work.InstructionI32Store
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_STORE))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_STORE)))
        );

    InstructionI32Load_i : entity work.InstructionI32Load
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_I32_LOAD))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_I32_LOAD)))
        );

    InstructionLocalGet_i : entity work.InstructionLocalGet
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_GET))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_GET)))
        );

    InstructionLocalSet_i : entity work.InstructionLocalSet
        port map (
            Clk => Clk,
            nRst => nRst,
            WasmFpgaInvocation_WasmFpgaInstruction => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaStack_WasmFpgaInstruction => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaModuleRam_WasmFpgaInstruction => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaMemory_WasmFpgaInstruction => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_LOCAL_SET))),
            WasmFpgaInstruction_WasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_LOCAL_SET)))
        );

    InstructionCall_i : entity work.InstructionCall
        port map (
            Clk => Clk,
            nRst => nRst,
            FromWasmFpgaInvocation => WasmFpgaInvocation_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaInvocation => WasmFpgaInstruction_WasmFpgaInvocation(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaStack => WasmFpgaStack_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaStack => WasmFpgaInstruction_WasmFpgaStack(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaModuleRam => WasmFpgaModuleRam_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaModuleRam => WasmFpgaInstruction_WasmFpgaModuleRam(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaMemory => WasmFpgaMemory_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaMemory => WasmFpgaInstruction_WasmFpgaMemory(to_integer(unsigned(WASM_OPCODE_CALL))),
            FromWasmFpgaStore => WasmFpgaStore_WasmFpgaInstruction(to_integer(unsigned(WASM_OPCODE_CALL))),
            ToWasmFpgaStore => WasmFpgaInstruction_WasmFpgaStore(to_integer(unsigned(WASM_OPCODE_CALL)))
        );

end;