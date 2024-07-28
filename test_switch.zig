const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;

test "simple swithc" {
    const a: u64 = 105;
    const zz: u64 = 103;

    const b = switch (a) {
        1, 2, 3, 4 => 0,
        5...100 => 1,

        101 => blk: {
            const c: u32 = 5;
            break :blk c * 2 + 1;
        },

        zz => zz,
        blk: {
            const d: u32 = 5;
            const e: u32 = 100;
            break :blk d + e;
        } => 107,
        else => 9,
    };
    try expect(b == 107);
}

// Switch expressions can be used outside a function:
const os_msg = switch (builtin.target.os.tag) {
    .linux => "we found a linux user",
    else => "not a linux user",
};

// Inside a function, switch statements implicitly are compile-time
// evaluated if the target expression is compile-time known.
test "switch inside function" {
    switch (builtin.target.os.tag) {
        .fuchsia => {
            // On an OS other than fuchsia, block is not even analyzed,
            // so this compile error is not triggered.
            // On fuchsia this compile error would be triggered.
            @compileError("fuchsia not supported");
        },
        else => {},
    }
}

//capture the value of a variable in a switch
test "capture the value of a variable in a switch" {
    const Point = struct {
        x: i32,
        y: i32,
    };
    const Item = union(enum) {
        a: u32,
        c: Point,
        d,
        e: u32,
    };

    var a = Item{ .c = Point{ .x = 1, .y = 2 } };

    const b = switch (a) {
        Item.a, Item.e => |item| item,
        Item.c => |*item| blk: {
            item.*.x += 1;
            break :blk 6;
        },
        Item.d => 8,
    };

    try expect(b == 6);
    try expect(a.c.x == 2); // as it is incremented in line 67
}

// literal enum switching
const Color = enum {
    auto,
    off,
    on,
};

test "enum literals with switch" {
    const color = Color.off;
    const result = switch (color) {
        .auto => false,
        .on => false,
        .off => true,
    };
    try expect(result);
}
// inline with runtime values

fn isFieldOptional(comptime T: type, field_index: usize) !bool {
    const fields = @typeInfo(T).Struct.fields;
    return switch (field_index) {
        // This prong is analyzed twice with `idx` being a
        // comptime-known value each time.
        inline 0, 1 => |idx| @typeInfo(fields[idx].type) == .Optional,
        else => return error.IndexOutOfBounds,
    };
}

const Struct1 = struct { a: u32, b: ?u32 };

test "using @typeInfo with runtime values" {
    var index: usize = 0;
    try expect(!try isFieldOptional2(Struct1, index));
    index += 1;
    try expect(try isFieldOptional2(Struct1, index));
    index += 1;
    try std.testing.expectError(error.IndexOutOfBounds, isFieldOptional2(Struct1, index));
}

// Calls to `isFieldOptional` on `Struct1` get unrolled to an equivalent
// of this function:
fn isFieldOptional2(comptime T: type, field_index: usize) !bool {
    const fields = @typeInfo(T).Struct.fields;
    return switch (field_index) {
        inline 0...fields.len - 1 => |idx| @typeInfo(fields[idx].type) == .Optional,
        else => return error.IndexOutOfBounds,
    };
}

// inline else prong
const SliceTypeA = extern struct {
    len: usize,
    ptr: [*]u32,
};
const SliceTypeB = extern struct {
    ptr: [*]SliceTypeA,
    len: usize,
};
const AnySlice = union(enum) {
    a: SliceTypeA,
    b: SliceTypeB,
    c: []const u8,
    d: []AnySlice,
};

fn withFor(any: AnySlice) usize {
    const Tag = @typeInfo(AnySlice).Union.tag_type.?;
    inline for (@typeInfo(Tag).Enum.fields) |field| {
        // With `inline for` the function gets generated as
        // a series of `if` statements relying on the optimizer
        // to convert it to a switch.
        if (field.value == @intFromEnum(any)) {
            return @field(any, field.name).len;
        }
    }
    // When using `inline for` the compiler doesn't know that every
    // possible case has been handled requiring an explicit `unreachable`.
    unreachable;
}

fn withSwitch(any: AnySlice) usize {
    return switch (any) {
        // With `inline else` the function is explicitly generated
        // as the desired switch and the compiler can check that
        // every possible case is handled.
        inline else => |slice| slice.len,
    };
}

test "inline for and inline else similarity" {
    const any = AnySlice{ .c = "hello" };
    try expect(withFor(any) == 5);
    try expect(withSwitch(any) == 5);
}

//When using an inline prong switching on an union an additional capture can be used to obtain the union's enum tag value.
const U = union(enum) {
    a: u32,
    b: f32,
};

fn getNum(u: U) u32 {
    switch (u) {
        // Here `num` is a runtime-known value that is either
        // `u.a` or `u.b` and `tag` is `u`'s comptime-known tag value.
        inline else => |num, tag| {
            if (tag == .b) {
                return @intFromFloat(num);
            }
            return num;
        },
    }
}

test "inline else with union enum tag capture" {
    const u = U{ .b = 3.14 };
    try expect(getNum(u) == 3);
}
