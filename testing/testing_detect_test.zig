const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;

test "builtin.is_test" {
    try expect(builtin.is_test);
    try expect(isATest());
}

fn isATest() bool {
    return builtin.is_test;
}
// zig test ./src/examples/testing_detect_test.zig
