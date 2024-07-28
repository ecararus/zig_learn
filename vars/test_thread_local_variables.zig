const std = @import("std");
const assert = std.debug.assert;

threadlocal var x: i32 = 1234;

test "thread local variable" {
    const tread1 = try std.Thread.spawn(.{}, testTls, .{});
    const tread2 = try std.Thread.spawn(.{}, testTls, .{});
    testTls();
    tread1.join();
    tread2.join();
}

fn testTls() void {
    assert(x == 1234);
    x = x + 1;
    assert(x == 1235);
}
