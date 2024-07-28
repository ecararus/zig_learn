const std = @import("std");
const expect = std.testing.expect;

// normal integer
const normal_int: i32 = 1234;

// optional integer
const optional_int: ?i32 = 5678;
const optional_int_null: ?i32 = null;
const optional_int_null_2: ?i32 = undefined;

test "print optionals" {
    std.debug.print("normal - {}\n", .{normal_int});
    std.debug.print("optional - {any}\n", .{optional_int});
    std.debug.print("optional - {any}\n", .{optional_int_null});
    std.debug.print("optional - {any}\n", .{optional_int_null_2});
}

// optial pointer
// malloc prototype included for reference
const Foo = struct {
    a: i32,
};
extern fn malloc(size: usize) ?[*]u8;

fn doAThing() ?*Foo {
    const ptr = malloc(1234) orelse return null;
    _ = ptr; // ...
}

// optional struct
const Foo2 = struct {
    a: i32,
};
const optional_foo: ?Foo2 = .{ .a = 1234 };
const optional_foo_null: ?Foo2 = null;
const optional_foo_null_2: ?Foo2 = undefined;
test "print optionals foo" {
    std.debug.print("optional - {any}\n", .{optional_foo});
    std.debug.print("optional - {any}\n", .{optional_foo_null});
    std.debug.print("optional - {any}\n", .{optional_foo_null_2});
}

// optionbal type
test "optional type" {
    // Declare an optional and coerce from null:
    var foo: ?i32 = null;

    // Coerce from child type of an optional
    foo = 1234;

    // Use compile-time reflection to access the child type of the optional:
    try comptime expect(@typeInfo(@TypeOf(foo)).Optional.child == i32);
}

// optioanl pointes
test "optional pointer" {
    // Pointers cannot be null. If you want a null pointer, use the optional
    // prefix `?` to make the pointer type optional.
    var ptr: ?*i32 = null;
    var x: i32 = 1;
    ptr = &x;

    try expect(ptr.?.* == 1);

    // Optional pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    try expect(@sizeOf(?*i32) == @sizeOf(*i32));
}

//while with optionals
test "while with optionals" {
    var x: ?i32 = 0;
    while (x) |value| {
        std.debug.print("value = {}\n", .{value});
        x = null;
    }
}

// if with optionals
test "if with optionals" {
    const x: ?i32 = 0;
    if (x) |value| {
        std.debug.print("value = {}\n", .{value});
    } else {
        std.debug.print("value is null\n", .{});
    }
}

//casting
//type coercion
test "type coercion - var declaration" {
    const a: u8 = 1;
    const b: u14 = a;
    _ = b;
}

test "type coercion - function call" {
    const a: u8 = 1;
    fooz(a);
}

fn fooz(b: u16) void {
    _ = b;
}

test "type coertion  - @as  builtin" {
    const a: u8 = 1;
    const b: u14 = @as(u16, a);
    _ = b;
}

// no op  cast
test "type coerciton -const qualificatin" {
    var a: i32 = 1;
    const b: *i32 = &a;
    fgz(b);
}

fn fgz(b: *const i32) void {
    std.debug.print("b = {}\n", .{b.*});
}

// pointer coerce const optional
const mem = std.mem;

test "cast *[1][*]const u8 to [*]const ?[*]const u8" {
    const window_name = [1][*]const u8{"window name"};
    const x: [*]const ?[*]const u8 = &window_name;
    try expect(mem.eql(u8, std.mem.sliceTo(@as([*:0]const u8, @ptrCast(x[0].?)), 0), "window name"));
}

// optional coertions
test "coerce to optional" {
    const x: ?i32 = 1234;
    const y: ?i32 = null;
    try expect(x.? == 1234);
    try expect(y == null);
}

test "coerce to optionals wrapped in error union" {
    const x: anyerror!?i32 = 1234;
    const y: anyerror!?i32 = null;

    try expect((try x).? == 1234);
    try expect((try y) == null);
}

test "turn HashMap into a set with void" {
    var map = std.AutoHashMap(i32, void).init(std.testing.allocator);
    defer map.deinit();

    try map.put(1, {});
    try map.put(2, {});

    try expect(map.contains(2));
    try expect(!map.contains(3));

    _ = map.remove(2);
    try expect(!map.contains(2));
}
