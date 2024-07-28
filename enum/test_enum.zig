const std = @import("std");
const expect = std.testing.expect;

const Type = enum {
    A,
    B,
    C,
};
const c = Type.C;

const VAL = enum(u2) {
    zero,
    one,
    tro,
};

test "enum ordinal value" {
    try expect(@intFromEnum(VAL.zero) == 0);
    try expect(@intFromEnum(VAL.one) == 1);
    try expect(@intFromEnum(VAL.tro) == 2);
}

const val2 = enum(u32) {
    a = 100,
    b = 200,
    c = 300,
};

test "enum to int" {
    try expect(@intFromEnum(val2.a) == 100);
    try expect(@intFromEnum(val2.b) == 200);
    try expect(@intFromEnum(val2.c) == 300);
}

const val3 = enum(u32) {
    a = 100,
    b,
    c = 300,
    d,
};
test "enum implicit ordinal values and overridden values" {
    try expect(@intFromEnum(val3.a) == 100);
    try expect(@intFromEnum(val3.b) == 101);
    try expect(@intFromEnum(val3.c) == 300);
    try expect(@intFromEnum(val3.d) == 301);
}

// Enums can have methods, the same as structs and unions.
// Enum methods are not special, they are only namespaced
// functions that you can call with dot syntax.

const Color = enum {
    red,
    green,
    blue,

    pub fn isOk(self: Color) bool {
        return self == Color.red;
    }
};
test "enum method" {
    const cc = Color.blue;
    try expect(!cc.isOk());
}

// An enum can be switched upon.
const food = enum {
    apple,
    banana,
    carrot,
};
test "enum switch" {
    const f = food.banana;
    const how_is = switch (f) {
        food.apple => "apple",
        food.banana => "banana",
        food.carrot => "carrot",
    };
    try expect(std.mem.eql(u8, how_is, "banana"));
}

// @typeInfo can be used to access the integer tag type of an enum.
const Small = enum {
    a,
    b,
    c,
};

test "enum tag type" {
    try expect(@typeInfo(Small).Enum.tag_type == u2);
}
// @typeInfo tells us the field count and the fields names:
test "@typeInfo" {
    try expect(@typeInfo(Small).Enum.fields.len == 3);
    try expect(std.mem.eql(u8, @typeInfo(Small).Enum.fields[1].name, "b"));
    // std.debug.print("{}\n", .{@typeInfo(Small).Enum.fields[1].name});
}

// @tagName gives a [:0]const u8 representation of an enum value:
test "@tagName" {
    try expect(std.mem.eql(u8, @tagName(Small.a), "a"));
}

// extern enum
// const Foo = enum {a,b,c};
// export fn entry(foo: Foo) void {
//     _ = foo;
// }

//enum literals
const Color2 = enum {
    auto,
    off,
    on,
};

test "enum literals" {
    const col1: Color2 = Color2.on;
    const col2 = Color2.on;
    try expect(col1 == col2);
}

test "switch using enum literals" {
    const color = Color2.on;
    const resu = switch (color) {
        Color2.auto => "auto",
        Color2.off => "off",
        Color2.on => "on",
    };
    try expect(std.mem.eql(u8, resu, "on"));
}

// test_switch_non-exhaustive
const Numer = enum(u8) {
    one,
    two,
    thre,
    _,
};

test "swtch on non-exhaustive enum" {
    const num = Numer.one;
    const result = switch (num) {
        .one => true,
        .two, .thre => false,
        _ => false,
    };

    try expect(result);
    const is_one = switch (num) {
        .one => true,
        else => false,
    };
    try expect(is_one);
}
