const std = @import("std");
const expect = std.testing.expect;

// RESULT TYPE PROPAGATION
test "result type propagation with struct initializer" {
    const S = struct {
        x: i32,
    };
    const val: u64 = 123;
    const s: S = .{ .x = @intCast(val) };
    // .{ .x = @intCast(val) }   has result type `S` due to the type annotation
    //         @intCast(val)     has result type `u32` due to the type of the field `S.x`
    //                  val      has no result type, as it is permitted to be any integer type
    try std.testing.expectEqual(@as(u32, 123), s.x);
}

test "attempt to swap array elements with array initializer" {
    var arr: [2]u32 = .{ 1, 2 };
    arr = .{ arr[1], arr[0] };
    // The previous line is equivalent to the following two lines:
    //   arr[0] = arr[1];
    //   arr[1] = arr[0];
    // So this fails!
    try expect(arr[0] == 2); // succeeds
    try expect(arr[1] == 2); // fails
}

test "using std namespace" {
    const S = struct {
        usingnamespace @import("std");
    };
    try S.testing.expect(true);
}
