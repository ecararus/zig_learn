const std = @import("std");
const expect = std.testing.expect;
const builtin = @import("builtin");
const native_arch = builtin.cpu.arch;
const math = std.math;

fn add(a: i8, b: i8) i8 {
    if (a == 0) {
        return b;
    }

    return a + b;
}

// The export specifier makes a function externally visible in the generated
// object file, and makes it use the C ABI.
export fn sub(a: i8, b: i8) i8 {
    return a - b;
}

// The extern specifier is used to declare a function that will be resolved
// at link time, when linking statically, or at runtime, when linking
// dynamically. The quoted identifier after the extern keyword specifies
// the library that has the function. (e.g. "c" -> libc.so)
// The callconv specifier changes the calling convention of the function.
const WINAPI: std.builtin.CallingConvention = if (native_arch == .x86) .Stdcall else .C;
extern "kernel32" fn ExitProcess(exit_code: u32) callconv(WINAPI) noreturn;
extern "c" fn atan2(a: f64, b: f64) f64;

// The @setCold builtin tells the optimizer that a function is rarely called.
fn abort() noreturn {
    @setCold(true);
    while (true) {}
}

// The naked calling convention makes a function not have any function prologue or epilogue.
// This can be useful when integrating with assembly.
fn _start() callconv(.Naked) noreturn {
    abort();
}

// The inline calling convention forces a function to be inlined at all call sites.
// If the function cannot be inlined, it is a compile-time error.
inline fn shiftLeftOne(a: u32) u32 {
    return a << 1;
}

// The pub specifier allows the function to be visible when importing.
// Another file can use @import and call sub2
pub fn sub2(a: i8, b: i8) i8 {
    return a - b;
}

// Function pointers are prefixed with `*const `.
const Call20p = *const fn (a: i8, b: i8) i8;
fn doOp(fnCall: Call20p, a: i8, b: i8) i8 {
    return fnCall(a, b);
}

test "func" {
    try expect(doOp(add, 5, 6) == 11);
    try expect(doOp(sub2, 5, 6) == -1);
}

//Pass-by-value Parameters
const Point = struct {
    x: i32,
    y: i32,
};

fn foo(point: Point) i32 {
    // Here, `point` could be a reference, or a copy. The function body
    // can ignore the difference and treat it as a value. Be very careful
    // taking the address of the parameter - it should be treated as if
    // the address will become invalid when the function returns.
    return point.x + point.y;
}

test "pass by value" {
    try expect(foo(Point{ .x = 1, .y = 2 }) == 3);
}

//Function Parameter Type Inference
fn addFortyTwo(x: anytype) @TypeOf(x) {
    return x + 42;
}
test "fn type inference" {
    try expect(addFortyTwo(1) == 43);
    try expect(@TypeOf(addFortyTwo(1)) == comptime_int);
    const y: i64 = 2;
    try expect(addFortyTwo(y) == 44);
    try expect(@TypeOf(addFortyTwo(y)) == i64);
}

//inline fn
test "inline function call" {
    if (fooz(1200, 34) != 1234) {
        @compileError("inline function call failed");
    }
}

inline fn fooz(x: i32, y: i32) i32 {
    return x + y;
}

const testing = std.testing;
// function reflection
test "function reflection" {
    try testing.expect(@typeInfo(@TypeOf(std.testing.expect)).Fn.params[0].type.? == bool);
    try testing.expect(@typeInfo(@TypeOf(std.testing.tmpDir)).Fn.return_type.? == testing.TmpDir);

    try testing.expect(@typeInfo(@TypeOf(std.math.Log2Int)).Fn.is_generic);
}

//errors
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{
    OutOfMemory,
};

fn foozz(err: AllocationError) FileOpenError {
    return err;
}

test "coerce subset to superset" {
    const err = foozz(AllocationError.OutOfMemory);
    try std.testing.expect(err == FileOpenError.OutOfMemory);
}

//coerce

// test "coerce superset to subset" {
//     foob(FileOpenError.OutOfMemory) catch {};
// }

// fn foob(err: FileOpenError) AllocationError {
//     return err;
// }

//catch
const parseU64 = @import("error_union_parsing_u64.zig").parseU64;
fn doAThing(str: []u8) void {
    const number = parseU64(str, 10) catch 13;
    _ = number; // ...
}

fn doAThings(str: []u8) void {
    const number = parseU64(str, 10) catch blk: {
        // do things
        break :blk 13;
    };
    _ = number; // number is now initialized
}

//try

/// Attempts to parse the given string `str` as a 64-bit unsigned integer in base 10.
/// If the parsing is successful, the parsed value is returned. Otherwise, an error is returned.
fn doAThingss(str: []u8) !void {
    const number = parseU64(str, 10) catch |err| return err;
    _ = number; // ...
}

/// Attempts to parse the given string `str` as a 64-bit unsigned integer in base 10.
/// If the parsing is successful, the parsed value is returned. Otherwise, an error is returned.
fn doAThingsss(str: []u8) !void {
    const number = try parseU64(str, 10);
    _ = number; // ...
}

test "invoke o thingzzzzzz" {
    doAThing("");
    doAThings("");
    doAThingss("") catch |err| {
        std.debug.print("error: {}\n", .{err});
    };
    doAThingsss("") catch |err| {
        std.debug.print("error: {}\n", .{err});
    };

    const number = parseU64("1234", 10) catch unreachable;
    std.debug.print("number: {}\n", .{number});
}

// handle all secnarios
fn doAthingssss(str: []u8) void {
    if (parseU64(str, 10)) |number| {
        std.debug.print("number: {}\n", .{number});
    } else |err| {
        switch (err) {
            error.InvalidChar => {
                std.debug.print("InvalidChar\n", .{});
            },
            error.OverFlow => {
                std.debug.print("OverFlow\n", .{});
            },
            else => {
                std.debug.print("Unknown error\n", .{});
            },
        }
    }
}

//handle only one scenarion
fn doAnotherThing(str: []u8) error{InvalidChar}!void {
    if (parseU64(str, 10)) |number| {
        std.debug.print("number: {}\n", .{number});
    } else |err| switch (err) {
        error.Overflow => {
            // handle overflow...
        },
        else => |leftover_err| return leftover_err,
    }
}

// handle all errors whitout scenario
fn doADifferentThing(str: []u8) void {
    if (parseU64(str, 10)) |number| {
        std.debug.print("number: {}\n", .{number});
    } else |_| {
        // do as you'd like
    }
}

// errdefer
const Foodz = struct {
    a: i32,
    b: i32,
};

fn tryToAllocateFoo() !Foodz {
    std.debug.print("tryToAllocateFoo\n", .{});
    return Foodz{ .a = 1, .b = 2 };
}
fn deallocateFoo(foodz: Foodz) void {
    std.debug.print("deallocateFoo\n", .{});
    // deallocate foo
    _ = foodz;
}
fn allocateTmpBuffer() ![]u8 {
    std.debug.print("allocateTmpBuffer\n", .{});
    return try std.heap.page_allocator.alloc(u8, 1024);
}
fn deallocateTmpBuffer(buf: []u8) void {
    std.debug.print("deallocateTmpBuffer\n", .{});
    // deallocate tmp_buf
    std.heap.page_allocator.free(buf);
}

fn createFoooooo(param: i32) !Foodz {
    const foodz = try tryToAllocateFoo();

    // now we have allocated foo. we need to free it if the function fails.
    // but we want to return it if the function succeeds.
    errdefer deallocateFoo(foodz);

    const tmp_buf = allocateTmpBuffer() orelse return error.OutOfMemory;
    // tmp_buf is truly a temporary resource, and we for sure want to clean it up
    // before this block leaves scope
    defer deallocateTmpBuffer(tmp_buf);

    if (param > 1337) return error.InvalidParam;
    // here the errdefer will not run since we're returning success from the function.
    // but the defer will run!
    return foo;
}
test "invoke createFoooooo" {
    // const foodzzz = createFoooooo(1337) catch |err| {
    //     std.debug.print("error: {}\n", .{err});
    // };
    // std.debug.print("foodzzz: {}\n", .{foodzzz.*});
}

//common errdefer slip-ups
const Allocator = std.mem.Allocator;
const Ftd = struct {
    data: u32,
};

fn tryAlocFtd(allocator: Allocator) !*Ftd {
    return allocator.create(Ftd);
}
fn deallocFtd(allocator: Allocator, ftd: *Ftd) void {
    allocator.destroy(ftd);
}
fn getFtd() !u32 {
    return 666;
}

fn createFtd(allocator: Allocator, param: i32) !*Ftd {
    const ftd = getFtd: {
        var ftd = try tryAlocFtd(allocator);
        errdefer deallocFtd(allocator, ftd); // Only lasts until the end of getFoo

        // Calls deallocateFoo on error
        ftd.data = try getFtd();

        break :getFtd ftd;
    };

    // This lasts for the rest of the function
    errdefer deallocFtd(allocator, ftd);

    // Outside of the scope of the errdefer, so
    // deallocateFoo will not be called here
    if (param > 1337) return error.InvalidParam;

    return ftd;
}

test "invoke createFtd" {
    const all = std.testing.allocator;
    try std.testing.expectError(error.InvalidParam, createFtd(all, 2468));
}

//errdefer loop leaks
const FG = struct { data: *u32 };

fn getData() !u32 {
    return 666;
}

fn getFG(allocator: Allocator, num: usize) ![]FG {
    const fgs = try allocator.alloc(FG, num);
    errdefer allocator.free(fgs);

    // Used to track how many foos have been initialized
    // (including their data being allocated)
    var num_allocated: usize = 0;
    errdefer for (fgs[0..num_allocated]) |fg| {
        allocator.destroy(fg.data);
    };

    for (fgs, 0..) |*fg, i| {
        fg.data = try allocator.create(u32);
        num_allocated += 1;

        // This errdefer does not last between iterations
        //it has been moved above >>>> errdefer allocator.destroy(fg.data);

        // The data for the first 3 foos will be leaked
        if (i >= 3) return error.TooManyFoos;

        fg.data.* = try getData();
    }
    return fgs;
}

test "invoke getFG" {
    try std.testing.expectError(error.TooManyFoos, getFG(std.testing.allocator, 5));
}

// error unions

test "error union" {
    var fooErr: anyerror!u32 = undefined;
    fooErr = 1234;

    // Use compile-time reflection to access the payload type of an error union:
    try comptime expect(@typeInfo(@TypeOf(fooErr)).ErrorUnion.payload == u32);

    // Use compile-time reflection to access the error set type of an error union:
    try comptime expect(@typeInfo(@TypeOf(fooErr)).ErrorUnion.error_set == anyerror);
}

// merging error sets
const Z = error{ NotDir, PathNotFound };
const W = error{ OutOfMemory, PathNotFound };
const X = Z || W;

fn dosth() X!void {
    return error.NotDir;
}

test "call dosth" {
    if (dosth()) {
        @panic("unexpected success");
    } else |err| switch (err) {
        error.OutOfMemory => @panic("unexpected OutOfMemory"),
        error.PathNotFound => @panic("unexpected PathNotFound"),
        error.NotDir => {},
    }
}

// Inferred Error Sets
pub fn add_inferred_error_sets(comptime T: type, a: T, b: T) !T {
    const overflow = @addWithOverflow(a, b);
    if (overflow[1] != 0) return error.Overflow;
    return overflow[0];
}
pub fn add_explicit_error_sets(comptime T: type, a: T, b: T) Error!T {
    const overflow = @addWithOverflow(a, b);
    if (overflow[1] != 0) return error.Overflow;
    return overflow[0];
}

const Error = error{Overflow};

test "inferred error set" {
    if (add_inferred_error_sets(u8, 255, 1)) |_| unreachable else |err| switch (err) {
        error.Overflow => {}, // ok
    }
}




