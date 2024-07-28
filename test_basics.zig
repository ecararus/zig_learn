const std = @import("std");
const expect = std.testing.expect;

test "basic math" {
    const x = 1;
    const y = 2;
    if (x + y != 3) {
        unreachable;
    }
}

// test failure
fn assert(ok: bool) void {
    if (!ok) unreachable; // assertion failure
}

// This test will fail because we hit unreachable.
test "this will fail" {
    //assert(false);
}

// comptime unreacheable

test "type of unreachable" {
    comptime {
        // The type of unreachable is noreturn.

        // However this assertion will still fail to compile because
        // unreachable expressions are compile errors.

        //assert(@TypeOf(unreachable) == noreturn);
    }
}

//noreturn
fn foo(condition: bool, b: u32) void {
    const a = if (condition) b else return;
    _ = a;
    std.debug.print("b = {}", .{b});
    std.debug.print("c = {}", .{condition});
    @panic("foo");
}
test "noreturn" {
    foo(false, 1);
}
// another non exit
const builtin = @import("builtin");
const native_arch = builtin.cpu.arch;

const WINAPI: std.builtin.CallingConvention = if (native_arch == .x86) .Stdcall else .C;
extern "kernel32" fn ExitProcess(exit_code: c_uint) callconv(WINAPI) noreturn;

test "foo" {
    const value = bar() catch ExitProcess(1);
    try expect(value == 1234);
}

fn bar() anyerror!u32 {
    return 1234;
}
