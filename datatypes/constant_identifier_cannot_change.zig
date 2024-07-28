const print = @import("std").debug.print;
const x = 1234;

fn foo() void {
    // It works at file scope as well as inside functions.
    var y: u32 = 5678;
    //var_must_be_initialize or use undefined
    var u: int = undefined;
    var z: u32;
    z = 100; 

    // Once assigned, an identifier cannot be changed.
    x += 1;
    y += 1;
    print("{d}\n", .{x});
    print("{d}\n", .{y});
}

pub fn main() void {
    foo();
}
