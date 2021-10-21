import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

__tag__ = ""
__build__ = 0
__version__ = "{}".format(__tag__)
__commit__ = "0000000"

setuptools.setup(
    name="wasm-fpga-engine",
    version=__version__,
    author="Denis Vasilìk",
    author_email="contact@denisvasilik.com",
    url="https://github.com/denisvasilik/wasm-fpga-engine/",
    project_urls={
        "Bug Tracker": "https://github.com/denisvasilik/wasm-fpga/",
        "Documentation": "https://wasm-fpga.readthedocs.io/en/latest/",
        "Source Code": "https://github.com/denisvasilik/wasm-fpga-engine/",
    },
    description="WebAssembly FPGA Engine",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3.6",
        "Operating System :: OS Independent",
    ],
    dependency_links=[],
    package_dir={},
    package_data={},
    data_files=[(
        "wasm-fpga-engine/package", [
            "package/component.xml"
        ]),(
        "wasm-fpga-engine/package/bd", [
            "package/bd/bd.tcl"
        ]),(
        "wasm-fpga-engine/package/xgui", [
            "package/xgui/wasm_fpga_engine_v1_0.tcl"
        ]),(
        "wasm-fpga-engine/resources", [
            "resources/wasm_fpga_bus_header.vhd",
            "resources/wasm_fpga_bus_wishbone.vhd",
            "resources/wasm_fpga_engine_header.vhd",
            "resources/wasm_fpga_engine_wishbone.vhd",
            "resources/wasm_fpga_engine_debug_header.vhd",
            "resources/wasm_fpga_engine_debug_wishbone.vhd",
            "resources/wasm_fpga_stack_header.vhd",
            "resources/wasm_fpga_stack_wishbone.vhd",
            "resources/wasm_fpga_store_header.vhd",
            "resources/wasm_fpga_store_wishbone.vhd",
            "resources/debug.coe",
        ]),(
        "wasm-fpga-engine/ip/WasmFpgaDivider32BitSigned", [
            "ip/WasmFpgaDivider32BitSigned/WasmFpgaDivider32BitSigned.xci"
        ]),(
        "wasm-fpga-engine/ip/WasmFpgaDivider32BitUnsigned", [
            "ip/WasmFpgaDivider32BitUnsigned/WasmFpgaDivider32BitUnsigned.xci"
        ]),(
        "wasm-fpga-engine/ip/WasmFpgaMultiplier32Bit", [
            "ip/WasmFpgaMultiplier32Bit/WasmFpgaMultiplier32Bit.xci"
        ]),(
        "wasm-fpga-engine/ip/WasmFpgaTestBenchRam", [
            "ip/WasmFpgaTestBenchRam/WasmFpgaTestBenchRam.xci"
        ]),(
        "wasm-fpga-engine/src", [
            "src/WasmFpgaEngine.vhd",
            "src/WasmFpgaEngineInstructions.vhd",
            "src/WasmFpgaEngineInstantiation.vhd",
            "src/WasmFpgaEngineInvocation.vhd",
            "src/WasmFpgaEnginePackage.vhd",
            "src/WasmFpgaMemoryProxy.vhd",
            "src/WasmFpgaModuleProxy.vhd",
            "src/WasmFpgaStackProxy.vhd",
            "src/WasmFpgaStoreProxy.vhd",
        ]),(
        "wasm-fpga-engine/src/instructions", [
            "src/instructions/Call.vhd",
            "src/instructions/LocalTee.vhd",
            "src/instructions/Return.vhd",
            "src/instructions/Drop.vhd",
            "src/instructions/End.vhd",
            "src/instructions/I32Add.vhd",
            "src/instructions/I32And.vhd",
            "src/instructions/I32Clz.vhd",
            "src/instructions/I32Const.vhd",
            "src/instructions/I32Ctz.vhd",
            "src/instructions/I32Divs.vhd",
            "src/instructions/I32Divu.vhd",
            "src/instructions/I32Eq.vhd",
            "src/instructions/I32Eqz.vhd",
            "src/instructions/I32Ges.vhd",
            "src/instructions/I32Geu.vhd",
            "src/instructions/I32Gts.vhd",
            "src/instructions/I32Gtu.vhd",
            "src/instructions/I32Les.vhd",
            "src/instructions/I32Leu.vhd",
            "src/instructions/I32Load.vhd",
            "src/instructions/I32Lts.vhd",
            "src/instructions/I32Ltu.vhd",
            "src/instructions/I32Mul.vhd",
            "src/instructions/I32Ne.vhd",
            "src/instructions/I32Or.vhd",
            "src/instructions/I32Popcnt.vhd",
            "src/instructions/I32Rems.vhd",
            "src/instructions/I32Remu.vhd",
            "src/instructions/I32Rotl.vhd",
            "src/instructions/I32Rotr.vhd",
            "src/instructions/I32Shl.vhd",
            "src/instructions/I32Shrs.vhd",
            "src/instructions/I32Shru.vhd",
            "src/instructions/I32Store.vhd",
            "src/instructions/I32Sub.vhd",
            "src/instructions/I32Xor.vhd",
            "src/instructions/LocalGet.vhd",
            "src/instructions/LocalSet.vhd",
            "src/instructions/Nop.vhd",
            "src/instructions/Select.vhd",
            "src/instructions/Unreachable.vhd",
        ]),(
        "wasm-fpga-engine/tb", [
            "tb/tb_pkg_helper.vhd",
            "tb/tb_pkg.vhd",
            "tb/tb_std_logic_1164_additions.vhd",
            "tb/tb_Types.vhd",
            "tb/tb_FileIo.vhd",
            "tb/tb_WasmFpgaEngine.vhd",
            "tb/tb_WbRam.vhd",
        ]),(
        'wasm-fpga-engine/simstm', [
            'simstm/WasmFpgaEngineDefines.stm',
            'simstm/WasmFpgaEngineHelper.stm',
            'simstm/WasmFpgaEngine.stm',
            'simstm/WasmFpgaEngineTests.stm',
        ]),(
        'wasm-fpga-engine/simstm/instruction', [
            'simstm/instructions/Call.stm',
            'simstm/instructions/Drop.stm',
            'simstm/instructions/I32Add.stm',
            'simstm/instructions/I32And.stm',
            'simstm/instructions/I32Clz.stm',
            'simstm/instructions/I32Const.stm',
            'simstm/instructions/I32Ctz.stm',
            'simstm/instructions/I32Divs.stm',
            'simstm/instructions/I32Divu.stm',
            'simstm/instructions/I32Eq.stm',
            'simstm/instructions/I32Eqz.stm',
            'simstm/instructions/I32Ges.stm',
            'simstm/instructions/I32Geu.stm',
            'simstm/instructions/I32Gts.stm',
            'simstm/instructions/I32Gtu.stm',
            'simstm/instructions/I32Les.stm',
            'simstm/instructions/I32Leu.stm',
            'simstm/instructions/I32Load.stm',
            'simstm/instructions/I32Lts.stm',
            'simstm/instructions/I32Ltu.stm',
            'simstm/instructions/I32Mul.stm',
            'simstm/instructions/I32Ne.stm',
            'simstm/instructions/I32Or.stm',
            'simstm/instructions/I32Popcnt.stm',
            'simstm/instructions/I32Rems.stm',
            'simstm/instructions/I32Remu.stm',
            'simstm/instructions/I32Rotl.stm',
            'simstm/instructions/I32Rotr.stm',
            'simstm/instructions/I32Shl.stm',
            'simstm/instructions/I32Shrs.stm',
            'simstm/instructions/I32Shru.stm',
            'simstm/instructions/I32Store.stm',
            'simstm/instructions/I32Sub.stm',
            'simstm/instructions/I32Xor.stm',
            'simstm/instructions/LocalGet.stm',
            'simstm/instructions/LocalSet.stm',
            'simstm/instructions/LocalTee.stm',
            'simstm/instructions/Return.stm',
            'simstm/instructions/Select.stm',
            'simstm/instructions/Unreachable.stm',
        ]),(
            "wasm-fpga-engine", [
                "CHANGELOG.md",
                "AUTHORS",
                "LICENSE"
        ])
    ],
    setup_requires=[],
    install_requires=[],
    entry_points={},
)
