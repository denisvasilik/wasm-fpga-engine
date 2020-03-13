PWD=$(shell pwd)

all: package

convert:
	wat2wasm resources/debug.wat -o resources/debug.wasm
	wat2wasm resources/debug.wat -v > resources/debug.text
	tools/bin2coe.py --input resources/debug.wasm --output resources/debug.coe

prepare:
	@mkdir -p work

project: prepare hxs
	@vivado -mode batch -source scripts/create_project.tcl -notrace -nojournal -tempDir work -log work/vivado.log

package: prepare hxs
	@vivado -mode batch -source scripts/package_ip.tcl -notrace -nojournal -tempDir work -log work/vivado.log

clean:
	@rm -rf .Xil vivado*.log vivado*.str vivado*.jou
	@rm -rf work \
		src-gen \
		hxs_gen

hxs:
	docker run -t \
               -v ${PWD}/hxs:/work/src \
               -v ${PWD}/hxs_gen:/work/gen \
               registry.build.aug:5000/docker/hxs_generator:latest

.PHONY: all prepare project package clean hxs
