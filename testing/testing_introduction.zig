const std = @import("std");
test "expect addOne add one to 41" {
    try std.testing.expect(addOne(41) == 42);
}

test addOne {
    try std.testing.expect(addOne(41) == 42);
}

test "skip this teest" {
    return error.SkipZigTest;
}

pub fn addOne(number: i32) i32 {
    return number + 1;
}

pub fn main() void {
    std.debug.print("{}\n", .{addOne(41)});
}
//zig run ./src/examples/testing_introduction.zig
//zig test ./src/examples/testing_introduction.zig
