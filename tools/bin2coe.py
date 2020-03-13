#!/usr/bin/python

import os
import click

@click.command()
@click.option('--input', default='', type=str, help="Binary file path")
@click.option('--output', default='', type=str, help="COE file path")
def main(input, output):
    convert_binary_to_coe(input, output)

def convert_binary_to_coe(binary_file_path, coe_file_path):
    with open(binary_file_path, 'r') as bin_file:
        with open(coe_file_path, 'w') as coe_file:
            coe_file.write('memory_initialization_radix=16;')
            coe_file.write(os.linesep)
            coe_file.write('memory_initialization_vector=')
            coe_file.write(os.linesep)
            while True:
                byte_list = list(bytearray(bin_file.read(4)))
                if not byte_list:
                    break
                byte_list.extend([0] * (1 - len(byte_list)))
                byte_list.reverse()
                for byte_value in byte_list:
                    coe_file.write("{0:02X}".format(byte_value))
                coe_file.write(",")
                coe_file.write(os.linesep)
            coe_file.seek(coe_file.tell() - len(os.linesep) - 1)
            coe_file.write(";")
            coe_file.write(os.linesep)

if __name__ == "__main__":
    main()
