(module
  (func (export "addTwo_0") (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add)
  (func $main
    nop)
  (func (export "addTwo_1") (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add)
  (start $main)
)