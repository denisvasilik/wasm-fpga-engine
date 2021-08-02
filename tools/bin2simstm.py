#!/usr/bin/python3

import os
import click

from binalyzer import Binalyzer


@click.command()
@click.option("--input", default="", type=str, help="Binary file path")
@click.option("--output", default="", type=str, help="SimStm file path")
def main(input, output):
    with open(input, "rb") as input_file:
        with open(output, "w") as output_file:
            bin2simstm(input_file, output_file)


def generate_module(name, wasm_module, output_file):
    output_file.write(f"""
{name}_PREPARE_MODULE:
BEGIN_SUB
    MESSAGE 0 "{name}_PREPARE_MODULE"
    \n""")

    for (address, data_byte) in enumerate(wasm_module.value):
        output_file.write(f"    WRITE_RAM $WASM_MODULE #x{address:06X} #x{data_byte:02X}\n")

    output_file.write("""
    RETURN_CALL
END_SUB
""")


def generate_store(name, wasm_module, output_file):
    output_file.write(f"""
{name}_PREPARE_STORE:
BEGIN_SUB
    MESSAGE 0 "{name}_PREPARE_STORE"
    \n""")
    offset = 0
    
    offset = generate_start_section_of_store(wasm_module, offset, output_file)
    offset = generate_code_section_of_store(wasm_module, offset, output_file)
    offset = generate_function_section_of_store(wasm_module, offset, output_file)
    offset = generate_type_section_of_store(wasm_module, offset, output_file)

    output_file.write(
"""    RETURN_CALL
END_SUB
""")


def generate_start_section_of_store(wasm_module, offset, output_file):
    start_section_size_address = wasm_module.start_section.length.absolute_address

    output_file.write("    -- Start section\n")

    output_file.write("    WRITE_RAM $WASM_STORE #x0 $WASM_MODULE_INSTANCE_UID\n")
    output_file.write("    WRITE_RAM $WASM_STORE #x1 $WASM_START_SECTION_UID\n")
    output_file.write("    WRITE_RAM $WASM_STORE #x2 #x00 -- Idx\n")
    output_file.write(
        f"    WRITE_RAM $WASM_STORE #x3 #x{start_section_size_address:02X} -- Start Function Address\n\n"
    )
    
    return 4


def generate_code_section_of_store(wasm_module, offset, output_file):   
    output_file.write("    -- Code section\n")
    
    for i, body in enumerate(wasm_module.code_section.code.function):
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset:02X} $WASM_MODULE_INSTANCE_UID\n")
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset + 1:02X} $WASM_CODE_SECTION_UID\n")
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset + 2:02X} #x{i:02X} -- Idx\n")
        output_file.write(
            f"    WRITE_RAM $WASM_STORE #x{offset + 3:02X} #x{body.absolute_address:02X} -- Function Body Address\n\n"
        )
        offset += 4

    return offset


def generate_function_section_of_store(wasm_module, offset, output_file):
    output_file.write("    -- Function section\n")

    for (i, function_signature) in enumerate(wasm_module.function_section.data.function_typeidx):
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset:02X} $WASM_MODULE_INSTANCE_UID\n")
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset + 1:02X} $WASM_FUNCTION_SECTION_UID\n")
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset + 2:02X} #x{i:02X} -- Idx\n")
        output_file.write(
            f"    WRITE_RAM $WASM_STORE #x{offset + 3:02X} #x{function_signature.absolute_address:02X} -- Function Signature Index Address\n\n"
        )
        offset += 4

    return offset

def generate_type_section_of_store(wasm_module, offset, output_file):
    output_file.write("    -- Type section\n")

    for (i, function_type) in enumerate(wasm_module.type_section.data.type):
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset:02X} $WASM_MODULE_INSTANCE_UID\n")
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset + 1:02X} $WASM_TYPE_SECTION_UID\n")
        output_file.write(f"    WRITE_RAM $WASM_STORE #x{offset + 2:02X} #x{i:02X} -- Idx\n")
        output_file.write(
            f"    WRITE_RAM $WASM_STORE #x{offset + 3:02X} #x{function_type.num_params.absolute_address:02X} -- Function Type Address\n\n"
        )
        offset += 4

    return offset


def bin2simstm(input_file, output_file):
    wasm_module_format_url = "https://raw.githubusercontent.com/denisvasilik/binalyzer/master/resources/wasm_module_format.xml"
    binalyzer = Binalyzer(data=input_file)
    binalyzer.xml.from_url(wasm_module_format_url)
    wasm_module = binalyzer.template
    name = "TEST_RETURN"

    generate_store(name, wasm_module, output_file)
    generate_module(name, wasm_module, output_file)


if __name__ == "__main__":
    main()
