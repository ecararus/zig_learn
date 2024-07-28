const std = @import("std");

test "testing detect leak" {
    var list = std.ArrayList(u21).init(std.testing.allocator);
    try list.append('☔');

    try std.testing.expect(list.items.len == 1);
}
//zig test ./src/examples/testing_detect_leak.zig
