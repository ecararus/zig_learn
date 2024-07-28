const std = @import("std");
const expect = std.testing.expect;

test "tuple" {
    const tup = .{
        @as(u32, 1234),
        @as(f32, 12.34),
        true,
        "hi",
    } ++ .{false} ** 2;
    try expect(tup[0] == 1234);
    try expect(tup[1] == 12.34);
    try expect(tup[2] == true);
    try expect(tup[3][0] == 'h');
    try expect(tup[3][1] == 'i');
    try expect(tup[4] == false);

    inline for (tup, 0..) |v, i| {
        if (i != 2) continue;
        try expect(v);
    }
    try expect(tup.len == 6);
    try expect(tup.@"3"[0] == 'h');
    try expect(!tup.@"4");
}
