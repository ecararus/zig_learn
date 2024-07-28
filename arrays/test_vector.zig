const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "Basic vector usage" {
    // Vectors have a compile-time known length and base type.
    const a = @Vector(4, i32){ 1, 2, 3, 4 };
    const b = @Vector(4, i32){ 5, 6, 7, 8 };

    // Math operations take place element-wise.
    const c = a + b;

    try expectEqual(6, c[0]);
    try expectEqual(8, c[1]);
    try expectEqual(10, c[2]);
    try expectEqual(12, c[3]);
}

test "Conversion between vectors, arrays, and slices" {
    // Vectors and fixed-length arrays can be automatically assigned back and forth
    const arr1: [4]f32 = [_]f32{ 1.1, 3.2, 4.5, 5.6 };
    const vec1: @Vector(4, f32) = arr1;
    const arr2: [4]f32 = vec1;

    try expectEqual(arr1, arr2);

    // You can also assign from a slice with comptime-known length to a vector using .*
    const vec2: @Vector(2, f32) = arr1[1..3].*;
    const slice: []const f32 = &arr1;

    var offset: u32 = 1; // var to make it runtime-known
    _ = &offset; // suppress 'var is never mutated' error
    // To extract a comptime-known length from a runtime-known offset,
    // first extract a new slice from the starting offset, then an array of
    // comptime-known length
    const vec3: @Vector(2, f32) = slice[offset..][0..2].*;
    try expectEqual(slice[offset], vec2[0]);
    try expectEqual(slice[offset + 1], vec2[1]);
    try expectEqual(vec2, vec3);

    std.debug.print("{}\n", .{offset});
    for (slice) |item| {
        std.debug.print("{}\n", .{item});
    }

    // std.debug.print("{}\n", .{vec2[]});
    // std.debug.print("{}\n", .{vec3});
    // std.debug.print("{}\n", .{slice});
    // std.debug.print("{}\n", .{offset});
}

//Produces a vector where each element is the value scalar. The return type and thus the length of the vector is inferred.
test "vector @splat" {
    const scalar: u32 = 5;
    const result: @Vector(4, u32) = @splat(scalar);
    try std.testing.expect(std.mem.eql(u32, &@as([4]u32, result), &[_]u32{ 5, 5, 5, 5 }));
}

//Transforms a vector into a scalar value (of type E) by performing a sequential horizontal reduction of its elements using the specified operator op.
// Every operator is available for integer vectors.
// .And, .Or, .Xor are additionally available for bool vectors,
// .Min, .Max, .Add, .Mul are additionally available for floating point vectors,
test "vector @reduce" {
    const V = @Vector(4, i32);
    const value = V{ 1, -1, 1, -1 };
    const result = value > @as(V, @splat(0));
    // result is { true, false, true, false };
    try comptime std.testing.expect(@TypeOf(result) == @Vector(4, bool));
    const is_all_true = @reduce(.And, result);
    try comptime std.testing.expect(@TypeOf(is_all_true) == bool);
    try std.testing.expect(is_all_true == false);

    std.debug.print("{}\n", .{is_all_true});
    std.debug.print("{}\n", .{result});
}
