var y: i32 = add(10, x);
const x: i32 = add(12, 34);

test "container levele vars" {
    try expect(x == 46);
    try expect(y == 56);
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

const std = @import("std");
const expect = std.testing.expect;
// zig test ./src/examples/test_container_level_variables.zig
