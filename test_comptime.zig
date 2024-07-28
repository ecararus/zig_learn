const std = @import("std");
const expect = std.testing.expect;

// comptime duck typing / generics
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}
fn biggestFloat(a: f32, b: f32) f32 {
    return max(f32, a, b);
}
fn biggestInt(a: i32, b: i32) i32 {
    return max(i32, a, b);
}
test "comptime duck typing" {
    try expect(biggestFloat(1.0, 2.0) == 2.0);
    try expect(biggestInt(1, 2) == 2);
    try expect(max(i32, 1, 2) == 2);
}

// compttime evaluation
const CmdFn = struct {
    name: []const u8,
    func: fn (i32) i32,
};

const cmd_fns = [_]CmdFn{
    CmdFn{ .name = "one", .func = one },
    CmdFn{ .name = "two", .func = two },
    CmdFn{ .name = "three", .func = three },
};
fn one(x: i32) i32 {
    return x + 1;
}
fn two(x: i32) i32 {
    return x + 2;
}
fn three(x: i32) i32 {
    return x + 3;
}

fn performFn(comptime prefix_char: u8, start_val: i32) i32 {
    var result = start_val;
    comptime var i = 0;
    inline while (i < cmd_fns.len) : (i += 1) {
        if (cmd_fns[i].name[0] == prefix_char) {
            result = cmd_fns[i].func(result);
        }
    }
    return result;
}

test "perform comp eval" {
    try expect(performFn('o', 0) == 1);
    try expect(performFn('t', 1) == 6);
    try expect(performFn('w', 99) == 99);
}
