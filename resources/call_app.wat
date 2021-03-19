(module
    (func $my_func (param $a i32) (param $b i32)
        get_local $a
        get_local $b
        i32.sub
        drop)

    (func $main
        i32.const 3
        i32.const 4
        call $my_func)

    (start $main)
)