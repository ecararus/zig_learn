const std = @import("std");
const expect = std.testing.expect;

fn deferExample() !usize {
    var a: usize = 0;
    {
        defer a += 100;
        a = 10;
    }
    try expect(a == 110);
    a = 5;
    return a;
}

test "defer basics" {
    try expect((try deferExample()) == 5);
}
//defer_unwind
test "defer unwinding" {
    std.debug.print("defer unwinding\n", .{});
    defer {
        std.debug.print("1\n", .{});
    }
    defer {
        std.debug.print("2\n", .{});
    }
    defer {
        std.debug.print("3\n", .{});
    }
    if (false) {
        // defers are not run if they are never executed.
        defer {
            std.debug.print("4\n", .{});
        }
    }
}
//test_invalid_defer
// fn deferInvalidExample() !void {
//     defer {
//         return error.DeferError;
//     }

//     return error.DeferError;
// }
