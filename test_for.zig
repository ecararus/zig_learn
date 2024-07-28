const std = @import("std");
const expect = std.testing.expect;

test "basic for loop " {
    const items = [_]i32{ 1, 2, 3, 4 };
    var sum: i32 = 0;

    // For loops iterate over slices and arrays.
    for (items) |item| {
        if (item == 0) {
            continue;
        }
        sum += item;
    }

    try expect(sum == 10);

    // To iterate over a portion of a slice, reslice.
    for (items[1..4]) |item| {
        sum += item;
    }
    try expect(sum == 19);

    // To access the index of iteration, specify a second condition as well
    // as a second capture value.
    var sum2: i32 = 0;
    for (items, 0..) |_, i| {
        try expect(@TypeOf(i) == usize);
        sum2 += @as(i32, @intCast(i));
    }
    std.debug.print("sum2 = {}\n", .{sum2});
    try expect(sum2 == 6);

    // To iterate over consecutive integers, use the range syntax.
    // Unbounded range is always a compile error.
    var sum3: usize = 0;
    for (0..5) |i| {
        sum3 += i;
    }
    try expect(sum3 == 10);
}

test "multi object for" {
    const items = [_]usize{ 1, 2, 3 };
    const items2 = [_]usize{ 4, 5, 6 };
    var count: usize = 0;

    // Iterate over multiple objects.
    // All lengths must be equal at the start of the loop, otherwise detectable
    // illegal behavior occurs.
    for (items, items2) |item, item2| {
        count += item + item2;
    }
    try expect(count == 21);
}

test "for reference" {
    var items = [_]i32{ 3, 4, 2 };
    for (&items) |*item| {
        item.* += 2;
    }
    try expect(items[0] == 5);
    try expect(items[1] == 6);
    try expect(items[2] == 4);
}

test "for else" {
    const items = [_]?i32{ 3, 4, null, 5 };
    var sum: i32 = 0;
    const result = for (items) |item| {
        if (item != null) {
            sum += item.?;
        }
    } else blk: {
        try expect(sum == 12);
        break :blk sum;
    };
    try expect(result == 12);
}

//labeled for
test "nested break" {
    var count: usize = 0;
    outer: for (1..6) |_| {
        for (1..6) |_| {
            count += 1;
            break :outer;
        }
    }
    try expect(count == 1);
}

test "nested continue" {
    var count: usize = 0;
    outer: for (1..9) |_| {
        for (1..6) |_| {
            count += 1;
            continue :outer;
        }
    }

    try expect(count == 8);
}

// inline for
test "inline for loop" {
    const nums = [_]i32{ 2, 4, 6 };
    var sum: usize = 0;
    inline for (nums) |i| {
        const T = switch (i) {
            2 => f32,
            4 => i8,
            6 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T);
    }
    try expect(sum == 9);
}

fn typeNameLength(comptime T: type) usize {
    return @typeName(T).len;
}
