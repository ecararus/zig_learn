const std = @import("std");
const expect = std.testing.expect;

const Payload = union {
    int: i64,
    float: f64,
    boolean: bool,
};

test "simple union" {
    var payload = Payload{ .int = 1234 };
    payload.int = 12;
    // payload.float = 12.23;
    std.debug.print("\n payload = {}\n", .{payload.int});
}

// activation of filed by adding a field
test "simple union2" {
    var payload = Payload{ .int = 1234 };
    try expect(payload.int == 1234);
    payload = Payload{ .float = 12.34 };
    try expect(payload.float == 12.34);
}

const ComplexTypeTag = enum {
    tag_a,
    tag_b,
    tag_c,
};

const ComplexType = union(ComplexTypeTag) {
    tag_a: u32,
    tag_b: f32,
    tag_c: void,
};

test "switch on tagged union" {
    const c = ComplexType{ .tag_a = 1234 };
    try expect(@as(ComplexTypeTag, c) == ComplexTypeTag.tag_a);
    try expect(c.tag_a == 1234);

    switch (c) {
        ComplexTypeTag.tag_a => |val| {
            try expect(val == 1234);
        },
        ComplexTypeTag.tag_b, ComplexTypeTag.tag_c => unreachable,
    }
}

test "get tag type" {
    try expect(std.meta.Tag(ComplexType) == ComplexTypeTag);
}

test "modify tagged union in switch" {
    var c = ComplexType{ .tag_a = 42 };

    switch (c) {
        ComplexTypeTag.tag_a => |*value| value.* += 1,
        ComplexTypeTag.tag_b, ComplexTypeTag.tag_c => unreachable,
    }

    try expect(c.tag_a == 43);
}

// infir enum type
const Varinat = union(enum) {
    int: i32,
    boolean: bool,
    // void can be omitted when inferring enum tag type.
    none,

    fn truthy(self: Varinat) bool {
        return switch (self) {
            Varinat.int => |x_int| x_int != 0,
            Varinat.boolean => |x_bool| x_bool,
            Varinat.none => false,
        };
    }
};

test "union method" {
    var v1: Varinat = .{ .int = 1 };
    try expect(v1.truthy());

    var v2: Varinat = .{ .boolean = false };
    try expect(!v2.truthy());

    var v3: Varinat = .none;
    try expect(!v3.truthy());
}

//@tagName can be used to return a comptime [:0]const u8 value representing the field name:

test "union tag name" {
    try expect(std.mem.eql(u8, @tagName(Varinat.int), "int"));
}

//anonym union literal
test "unanymouse union  union" {
    const i: Payload = .{ .int = 1234 };
    const f: Payload = makePayload();
    try expect(i.int == 1234);
    try expect(f.float == 12.34);
}

fn makePayload() Payload {
    return .{ .float = 12.34 };
}
