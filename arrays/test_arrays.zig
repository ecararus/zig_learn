const testing = @import("std").testing;
const expect = testing.expect;
const assert = @import("std").debug.assert;
const mem = @import("std").mem;

//litteral array
const message = [_]u8{
    'h',
    'e',
    'l',
    'l',
    'o',
};

//alternative initialization using result location
const alt_message: [5]u8 = .{
    'h',
    'e',
    'l',
    'l',
    'o',
};

comptime {
    assert(mem.eql(u8, &message, &alt_message));
}

// get size of array
comptime {
    assert(message.len == 5);
}

// A string literal is a singler-itemn pointer to an array.
const same_message = "hello";
comptime {
    assert(mem.eql(u8, &message, same_message));
}

test "itereate over array" {
    var sum: usize = 0;
    for (message) |byte| {
        sum += byte;
    }
    try expect(sum == 'h' + 'e' + 'l' + 'l' + 'o');
}

//modifieable array
var some_integers: [100]i32 = undefined;
test "modify an array" {
    for (&some_integers, 0..) |*item, i| {
        item.* = @intCast(i);
    }
    try expect(some_integers[10] == 10);
    try expect(some_integers[99] == 99);
}

// array concatenation works if the values are known
// at compile time
const part_one = [_]i32{ 1, 2, 3, 4 };
const part_two = [_]i32{ 5, 6, 7, 8 };
const all_parts = part_one ++ part_two;
comptime {
    assert(mem.eql(i32, &all_parts, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }));
}

// ** does repeating patterns
const pattern = "ab" ** 3;
comptime {
    assert(mem.eql(u8, pattern, "ababab"));
}

// initialize an array to zero
const all_zero = [_]u16{0} ** 10;

comptime {
    assert(all_zero.len == 10);
    assert(all_zero[4] == 0);
}

// array slicing
const numbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
const first_five = numbers[0..5];
const last_five = numbers[5..];
const middle_three = numbers[3..6];
const all_numbers = numbers[0..9];
const empty = numbers[0..0];
// comptime {
//     assert(mem.eql(i32, &first_five, &[_]i32{ 1, 2, 3, 4, 5 }));
//     assert(mem.eql(i32, &last_five, &[_]i32{ 6, 7, 8, 9, 10 }));
//     assert(mem.eql(i32, &middle_three, &[_]i32{ 4, 5, 6 }));
//     assert(mem.eql(i32, &all_numbers, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }));
//     assert(mem.eql(i32, &empty, &[_]i32{}));
//     assert(empty.len == 0);
// }

//use compile time to initilise an array
var fancy_array = init: {
    var initial_value: [10]Point = undefined;
    for (&initial_value, 0..) |*point, i| {
        point.* = Point{
            .x = @intCast(i),
            .y = @intCast(i * 2),
        };
    }
    break :init initial_value;
};
const Point = struct {
    x: i32,
    y: i32,
};

test "compile time array initialization" {
    try expect(fancy_array[4].x == 4);
    try expect(fancy_array[4].y == 8);
}

// call a function to initialize an array
var more_points = [_]Point{makePoint(3)} ** 10;
fn makePoint(x: i32) Point {
    return Point{
        .x = x,
        .y = x * 2,
    };
}
test "array initialization with function calls" {
    try expect(more_points[4].x == 3);
    try expect(more_points[4].y == 6);
    try expect(more_points.len == 10);
}


///zig test ./test_arrays.zig