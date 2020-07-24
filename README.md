# WebAssembly FPGA Engine

Executes the WebAssembly [instructions](https://www.w3.org/TR/wasm-core-1/#a7-index-of-instructions).

# Example WAT

The following WAT is used for testing purposes.

```console
(module
  (func $main nop)
  (start $main)
)
```