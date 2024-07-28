const std = @import("std");

test "expectEqual demo" {
    const expected: i32 = 42;
    const actual = 42;

    try std.testing.expectEqual(expected, actual);
}

test "expectError deom" {
    const expected_error = error.DemoError;
    const actual_error_union: anyerror!void = error.DemoError;
    try std.testing.expectError(expected_error, actual_error_union);
}

//  zig test ./src/examples/testing_namespaces.zig
