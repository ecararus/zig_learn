const std = @import("std");
const expect = std.testing.expect;

// Declare a struct.
// Zig gives no guarantees about the order of fields and the size of
// the struct but the fields are guaranteed to be ABI-aligned.
const Point = struct {
    x: f32,
    y: f32,
};

// Maybe we want to pass it to OpenGL so we want to be particular about
// how the bytes are arranged.
const TdPoint = packed struct {
    x: f32,
    y: f32,
    z: f32,
};

//Initialize instance onf struct
const p = Point{ .x = 1.0, .y = 2.0 };
// Maybe we're not ready to fill out some of the fields.
const tdP = TdPoint{ .x = 1.0, .y = 2.0 };
const tdP2 = TdPoint{ .X = 1.0, .y = 2.0, .z = undefined };

// Structs can have methods
// Struct methods are not special, they are only namespaced
// functions that you can call with dot syntax.
const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }
    pub fn point(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

test "test dot product" {
    const v1 = Vec3.init(1.0, 2.0, 3.0);
    const v2 = Vec3.init(4.0, 5.0, 6.0);
    try expect(v1.point(v2) == 32.0);
}

// Structs can have declarations.
// Structs can have 0 fields.
const Empty = struct {
    pub const Pi = 3.14;
};
test "struct namespaced variable" {
    try expect(Empty.Pi == 3.14);
    try expect(@sizeOf(Empty) == 0);

    // you can still instantiate an empty struct
    const empty = Empty{};
    _ = empty;
}

// struct field order is determined by the compiler for optimal performance.
// however, you can still calculate a struct base pointer given a field pointer:
fn setYBasedOnX(x: *f32, y: f32) void {
    const point: *Point = @fieldParentPtr("x", x);
    point.y = y;
}

test "field parent point " {
    var point = Point{ .x = 1.0, .y = 2.0 };
    setYBasedOnX(&point.x, 3.0);
    try expect(point.y == 3.0);
    std.debug.print("point = {}\n", .{point});
}

// You can return a struct from a function. This is how we do generics
// in Zig:
fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,
        };
        first: ?*Node,
        last: ?*Node,
        len: usize,
    };
}

test "linked list" {
    try expect(LinkedList(i32) == LinkedList(i32));
    const list = LinkedList(i32){
        .first = null,
        .last = null,
        .len = 0,
    };
    try expect(list.len == 0);

    // Since types are first class values you can instantiate the type
    // by assigning it to a variable:
    const ListOfInts = LinkedList(i32);
    try expect(ListOfInts == LinkedList(i32));

    var nd = ListOfInts.Node{
        .prev = null,
        .next = null,
        .data = 42,
    };
    const list2 = LinkedList(i32){
        .first = &nd,
        .last = &nd,
        .len = 1,
    };
    std.debug.print("list2 = {}\n", .{list2});
    try expect(list2.len == 1);
    try expect(list2.first.?.data == 42);
    try expect(list2.last.?.data == 42);
}

// bad default value
const Threshold = struct {
    minimum: f32,
    maximum: f32,

    const default: Threshold = .{
        .minimum = 0.25,
        .maximum = 0.75,
    };

    const Category = enum { low, medium, high };

    fn categorize(t: Threshold, value: f32) Category {
        std.debug.assert(t.maximum >= t.minimum);
        if (value < t.minimum) return .low;
        if (value > t.maximum) return .high;
        return .medium;
    }
};

test "with default value" {
    var threshold: Threshold = .{
        .minimum = 0.10,
        .maximum = 0.20,
    };
    const category = threshold.categorize(0.90);
    try std.io.getStdOut().writeAll(@tagName(category));
}

// packed struct
const Full = packed struct {
    number: u16,
};
const Division = packed struct {
    hafl1: u8,
    quarter3: u4,
    quarter4: u4,
};

test "@bitCast between packed struct" {
    try doTest();
    try comptime doTest();
}

const native_endian = @import("builtin").target.cpu.arch.endian();

fn doTest() !void {
    try expect(@sizeOf(Full) == 2);
    try expect(@sizeOf(Division) == 2);

    const full = Full{ .number = 0x1234 };
    const divided: Division = @bitCast(full);
    try expect(divided.hafl1 == 0x34);
    try expect(divided.quarter3 == 0x2);
    try expect(divided.quarter4 == 0x1);

    const ordered: [2]u8 = @bitCast(full);
    switch (native_endian) {
        .big => {
            try expect(ordered[0] == 0x12);
            try expect(ordered[1] == 0x34);
        },
        .little => {
            try expect(ordered[0] == 0x34);
            try expect(ordered[1] == 0x12);
        },
    }
}

test "missized packed struct" {
    // const S = packed struct(u32) { a: u16, b: u8 };
    // _ = S{ .a = 4, .b = 2 };
}

const packedStruct = packed struct {
    a: u3,
    b: u32,
    c: u2,
};

const simpleStruct = packed struct {
    a: u3,
    b: u32,
    c: u2,
};

var foo = packedStruct{
    .a = 1,
    .b = 2,
    .c = 3,
};
var barr = simpleStruct{
    .a = 1,
    .b = 2,
    .c = 3,
};

test "test to non-byte-alligned field" {
    const ptr = &foo.b;
    try expect(ptr.* == 2);
    std.debug.print("\n ptr = {}\n", .{ptr.*});
    std.debug.print("\n val = {}\n", .{foo});
    std.debug.print("\n val2 = {}\n", .{barr});
}

//test_misaligned_pointer
test "pointer to non-byte-aligned field" {
    //try expect(bar(&foo.b) == 2);
    try expect(@intFromPtr(&foo.a) == @intFromPtr(&foo.b));
    try expect(@intFromPtr(&foo.a) == @intFromPtr(&foo.c));
    std.debug.print("\n ptr2 = {}\n", .{@intFromPtr(&foo.b)});
    std.debug.print("\n ptr3 = {}\n", .{@intFromPtr(&barr.b)});
}

fn bar(x: *const u3) u3 {
    return x.*;
}

test "aligned struct fields" {
    const S = struct {
        a: u32 align(2), //memory allocation will be alligned with 2 bytes memory address
        b: u32 align(64),
    };
    var foos = S{ .a = 1, .b = 2 };

    try std.testing.expectEqual(64, @alignOf(S));
    try std.testing.expectEqual(*align(2) u32, @TypeOf(&foos.a));
    try std.testing.expectEqual(*align(64) u32, @TypeOf(&foos.b));
    std.debug.print("\n ptr allignement = {}\n", .{@TypeOf(&foos.a)});
    std.debug.print("\n ptr allignement = {}\n", .{&foos.a});
}

// struct naming
fn List(comptime T: type) type {
    return struct {
        x: T,
    };
}

test "struct naming" {
    const Fooo = List(u32);
    std.debug.print("variable: {s}\n", .{@typeName(Fooo)});
    std.debug.print("anonimous: {s}\n", .{@typeName(struct {})});
    std.debug.print("function: {s}\n", .{@typeName(List(i32))});
}

// Anonymous struct literals
const Point2 = struct { x: i32, y: i32 };
test "Anonymous struct literal" {
    const pt: Point2 = .{ .x = 3, .y = 4 };
    try expect(pt.x == 3);
    try expect(pt.y == 4);
}

//full anonymous struct

fn check(args: anytype) !void {
    try expect(args.int == 1234);
    try expect(args.float == 12.34);
    try expect(args.b);
    try expect(args.s[0] == 'h');
    try expect(args.s[1] == 'i');
}

test "fully anonymous struct" {
    try check(.{
        .int = @as(u32, 1234),
        .float = @as(f32, 12.34),
        .b = true,
        .s = "hi",
    });
}
