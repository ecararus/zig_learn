const std = @import("std");
const expect = std.testing.expect;

const Derp = opaque {};
const Wat = opaque {};

extern fn foo(d: *Derp) void;

fn bar(w: *Wat) callconv(.C) void {
    foo(w);
}

test "call opaque foo " {
    //exopected to fail
    //bar(undefined);
}
