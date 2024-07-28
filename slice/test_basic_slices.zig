const std = @import("std");
const expect = std.testing.expect;
test "basic slice" {
    var arr = [_]i32{ 1, 2, 3, 4 };
    var known_at_runtime_zero: usize = 0;
    _ = &known_at_runtime_zero;
    const slice = arr[known_at_runtime_zero..arr.len];

    // alternative initialization using result location
    const alt_slice: []const i32 = &.{ 1, 2, 3, 4 };
    try std.testing.expectEqualSlices(i32, slice, alt_slice);
    try expect(@TypeOf(slice) == []i32);
    try expect(&slice[0] == &arr[0]);
    try expect(slice.len == arr.len);

    //known length
    const arr_ptr = arr[0..arr.len];
    try expect(@TypeOf(arr_ptr) == *[arr.len]i32);

    //slice by len
    var runtime_start: usize = 1;
    _ = &runtime_start;
    const leng = 2;
    const arr_ptr_len = arr[runtime_start..][0..leng];
    try expect(@TypeOf(arr_ptr_len) == *[leng]i32);

    // Using the address-of operator on a slice gives a single-item pointer.
    try expect(@TypeOf(&slice[0]) == *i32);

    // Using the `ptr` field gives a many-item pointer.
    try expect(@TypeOf(slice.ptr) == [*]i32);
    try expect(@intFromPtr(slice.ptr) == @intFromPtr(&slice[0]));

    // Slices have array bounds checking. If you try to access something out
    // of bounds, you'll get a safety check failure:
    //slice[10] += 1;
}

test "using slice for strings" {
    // Zig has no concept of strings. String literals are const pointers
    // to null-terminated arrays of u8, and by convention parameters
    // that are "strings" are expected to be UTF-8 encoded slices of u8.
    // Here we coerce *const [5:0]u8 and *const [6:0]u8 to []const u8
    const hello: []const u8 = "hello";
    const world: []const u8 = "世界";

    var all_toghers: [100]u8 = undefined;
    // You can use slice syntax with at least one runtime-known index on an
    // array to convert an array into a slice.
    var start: usize = 0;
    _ = &start;

    const all_togher_slice = all_toghers[start..];
    const hello_world = try std.fmt.bufPrint(all_togher_slice, "{s} {s}", .{ hello, world });

    try expect(std.mem.eql(u8, hello_world, "hello 世界"));
}

test "slice pointer" {
    var array: [10]u8 = undefined;
    const ptr = &array;
    try expect(@TypeOf(ptr) == *[10]u8);

    // A pointer to an array can be sliced just like an array:
    var start: usize = 0;
    var end: usize = 5;
    _ = .{ &start, &end };
    const slice = ptr[start..end];

    // The slice is mutable because we sliced a mutable pointer.
    try expect(@TypeOf(slice) == []u8);
    slice[2] = 3;
    try expect(slice[2] == 3);

    // Again, slicing with comptime-known indexes will produce another pointer
    // to an array:
    const ptr2 = slice[2..3];
    try expect(@TypeOf(ptr2) == *[1]u8);
    try expect(ptr2[0] == 3);
    try expect(ptr2.len == 1);
}

// sentinel terminated slices or aka as zero terminated slices
test "sentinel terminated slices" {
    const slice: [:0]const u8 = "hello";
    try expect(slice.len == 5);
    try expect(slice[5] == 0);
}

//null terminated slices
test "null terminated slices" {
    var array = [_]u8{ 3, 2, 1, 0, 3, 2, 1, 0 };
    var runtime_length: usize = 3;
    _ = &runtime_length;
    const slice = array[0..runtime_length :0];

    try expect(@TypeOf(slice) == [:0]u8);
    try expect(slice.len == 3);
    std.debug.print("slice = {any}\n", .{slice});
}
