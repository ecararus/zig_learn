const std = @import("std");
const expect = std.testing.expect;

test "0-terminanted sentinel array" {
    const array = [_:0]u8{ 1, 2, 3, 4 };
    try expect(@TypeOf(array) == [4:0]u8);
    try expect(array.len == 4);
    try expect(array[4] == 0);
}

test "extra 0s in 0-terminated sentinel array" {
    const array = [_:0]u8{ 1, 0, 0, 4 };

    try expect(@TypeOf(array) == [4:0]u8);
    try expect(array.len == 4);
    try expect(array[4] == 0);

    for (array) |item| {
        std.debug.print("{}\n", .{item});
    }
    std.debug.print("{}\n", .{array[4]});
}
