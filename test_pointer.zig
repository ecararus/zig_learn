const std = @import("std");
const expect = std.testing.expect;

test "address of syntax" {
    // Get the address of a variable:
    const x: i32 = 1234;
    const x_ptr = &x;

    std.debug.print("x_ptr = {*}\n", .{x_ptr});
    std.debug.print("x_ptr = {*}\n", .{&x});
    // std.debug.print("x_ptr.* = {*}\n", .{x_ptr.*});

    // Dereference a pointer:
    try expect(x_ptr.* == 1234);

    // When you get the address of a const variable, you get a const single-item pointer.
    try expect(@TypeOf(x_ptr) == *const i32);

    // If you want to mutate the value, you'd need an address of a mutable variable:
    var y: i32 = 5432;
    const y_ptr = &y;
    try expect(@TypeOf(y_ptr) == *i32);
    y_ptr.* = 100;
    std.debug.print("y = {}\n", .{y});
    // try expect(y == 100);
    try expect(y_ptr.* == 100);
}

test "pointer array access" {
    // Taking an address of an individual element gives a
    // single-item pointer. This kind of pointer
    // does not support pointer arithmetic.
    var array: [3]u8 = [3]u8{ 1, 2, 3 };
    const array_ptr = &array[2];
    try expect(@TypeOf(array_ptr) == *u8);
    try expect(array_ptr.* == 3);

    array_ptr.* = 100;
    array[1] = 200;
    try expect(array[2] == 100);

    for (array) |item| {
        std.debug.print("item = {}\n", .{item});
    }
}

test "pointer arithmetic with many-item pointer" {
    const array = [_]i32{ 1, 2, 3, 4 };
    var ptr: [*]const i32 = &array;

    try expect(ptr[0] == 1);
    ptr += 1; //evry item is incremented by one
    try expect(ptr[0] == 2);
    try expect(ptr[1] == 3);

    std.debug.print("ptr = {*}\n", .{ptr});
    // slicing a many-item pointer without an end is equivalent to
    // pointer arithmetic: `ptr[start..] == ptr + start`
    try (expect(ptr[1..] == ptr + 1));
}

test "pointer arithmetic with slices" {
    var array = [_]i32{ 1, 2, 3, 4 };
    var len: usize = 0; // var to make it runtime-known
    _ = &len; // suppress 'var is never mutated' error
    var slice = array[len + 1 .. array.len];

    try expect(slice[0] == 2);
    try expect(slice.len == 3);

    slice.ptr += 1;
    // now the slice is in an bad state since len has not been updated

    try expect(slice[0] == 3);
    try expect(slice.len == 3);
}

test "pointer slicing" {
    var array = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var start: usize = 2; // var to make it runtime-known
    _ = &start; // suppress 'var is never mutated' error

    const slice = array[start..4];
    try expect(slice.len == 2);
    try expect(array[3] == 4);
    slice[1] += 1;
    try expect(array[3] == 5);
}

test "comptime pointers" {
    comptime {
        var x: i32 = 1;
        const ptr = &x;
        ptr.* += 1;
        x += 1;
        try expect(ptr.* == 3);
        try expect(x == 3);
    }
}

test "@intFreomPtr and @prtFromInt" {
    const ptr: *i32 = @ptrFromInt(0xdeadbee0);
    const addr = @intFromPtr(ptr);
    try expect(@TypeOf(addr) == usize);
    try expect(addr == 0xdeadbee0);
}

test "comptime @ptrFromInt" {
    comptime {
        const ptr: *i32 = @ptrFromInt(0xdeadbee0);
        const addr = @intFromPtr(ptr);
        try expect(@TypeOf(addr) == usize);
        try expect(addr == 0xdeadbee0);
    }
}

test "volatile" {
    const mmio_ptr: *volatile u8 = @ptrFromInt(0x12345678);
    try expect(@TypeOf(mmio_ptr) == *volatile u8);
}

test "pointer casting" {
    const bytes align(@alignOf(u32)) = [_]u8{ 0x12, 0x12, 0x12, 0x12 };
    const u32_ptr: *const u32 = @ptrCast(&bytes);
    try expect(u32_ptr.* == 0x12121212);

    //using slice narow casting
    const u32_value = std.mem.bytesAsSlice(u32, bytes[0..])[0];
    try expect(u32_value == 0x12121212);

    //using slice bitcast
    try expect(@as(u32, @bitCast(bytes)) == 0x12121212);
}

test "pointer child type" {
    try expect(@typeInfo(*u32).Pointer.child == u32);
}

var foo: u8 align(4) = 100;
fn derp() align(@sizeOf(usize) * 2) i32 {
    return 1234;
}
fn noop1() align(1) void {}
fn noop2() align(4) void {}

test "function alignement" {
    try expect(derp() == 1234);
    try expect(@TypeOf(derp) == fn () i32);
    try expect(@TypeOf(&derp) == *align(@sizeOf(usize) * 2) const fn () i32);

    noop1();
    try expect(@TypeOf(noop1) == fn () void);
    try expect(@TypeOf(&noop1) == *align(1) const fn () void);

    noop2();
    try expect(@TypeOf(noop2) == fn () void);
    try expect(@TypeOf(&noop2) == *align(4) const fn () void);
}

test "pointer alignment safety" {
    // var array align(4) = [_]u32{ 0x11111111, 0x11111111 };
    // const bytes = std.mem.sliceAsBytes(array[0..]);
    //try std.testing.expect(foo2(bytes) != 0x11111111);
}

fn foo2(bytes: []u8) u32 {
    const slice4 = bytes[1..5];
    const int_slice = std.mem.bytesAsSlice(u32, @as([]align(4) u8, @alignCast(slice4)));
    return int_slice[0];
}

test "allowzero" {
    var zero: usize = 0; // var to make to runtime-known
    _ = &zero; // suppress 'var is never mutated' error
    const ptr: *allowzero i32 = @ptrFromInt(zero);
    try expect(@intFromPtr(ptr) == 0);
}
// sentinel terminated pointer

pub extern "c" fn printf(format: [*:0]const u8, ...) c_int;

test "sentinel terminated pointer" {
    _ = printf("Hello from c\n");
    // const msg = "Hello mfg\n";
    // const non_null_terminated_msg: [msg.len]u8 = msg.*;
    // _ = printf(&non_null_terminated_msg);
}
