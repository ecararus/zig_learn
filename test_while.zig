const std = @import("std");
const expect = std.testing.expect;

test "while basic" {
    var i: usize = 0;
    while (i < 10) : (i += 1) {
        std.debug.print("{}, ", .{i});
    }
    var j: usize = 0;
    while (j < 10) {
        j += 1;
    }
    try expect(j == 10);
}

test "exit from loop" {
    var i: usize = 0;
    while (true) {
        if (i == 10) {
            break;
        }
        i += 1;
    }
    try expect(i == 10);
}

test "continue" {
    var i: usize = 0;
    while (true) {
        i += 1;
        if (i <= 20)
            continue;
        break;
    }
    try expect(i == 21);
}

test "while loop continue experession" {
    var i: usize = 0;
    while (i < 10) : (i += 1) {}
    try expect(i == 10);
}

test "while loop continue expression, more complicated" {
    var i: usize = 1;
    var j: usize = 1;
    while (i * j < 2000) : ({
        i *= 2;
        j *= 3;
        std.debug.print("\n i = {}, j = {}", .{ i, j });
    }) {
        const my_ij = i * j;
        try expect(my_ij < 2000);
        std.debug.print("\n{}, ", .{my_ij});
    }
}

//test while else
test "while else" {
    try expect(rangeHasNumber(0, 10, 5));
    try expect(!rangeHasNumber(0, 10, 15));
}

fn rangeHasNumber(start: usize, end: usize, number: usize) bool {
    var i = start;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

//labeled while
test "nested break" {
    outer: while (true) {
        while (true) {
            break :outer;
        }
    }
}

test "nested continue" {
    var i: usize = 0;
    outer: while (i < 10) : (i += 1) {
        while (true) {
            continue :outer;
        }
    }
    try expect(i == 10);
}

//test_while_error_capture
var number_left: u32 = undefined;
fn eventualyErrorSequence() anyerror!u32 {
    return if (number_left == 0) error.ReachedZero else blk: {
        number_left -= 1;
        break :blk number_left;
    };
}

test "while error union capture" {
    var sum1: u32 = 0;
    number_left = 3;
    while (eventualyErrorSequence()) |x| {
        sum1 += x;
    } else |err| {
        try expect(err == error.ReachedZero);
    }
}

// inline while
test "inline while loop" {
    comptime var i = 0;
    var sum: usize = 0;
    inline while (i < 3) : (i += 1) {
        const T = switch (i) {
            0 => f32,
            1 => i8,
            2 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T);
    }
    try expect(sum == 9);
}

fn typeNameLength(comptime T: type) usize {
    return @typeName(T).len;
}
