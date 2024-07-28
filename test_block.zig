const std = @import("std");
const expect = std.testing.expect;

test "labeled break from labeled block expression" {
    var y: i32 = 123;

    const x = blk: {
        y += 1;
        break :blk y;
    };
    try expect(x == 124);
    try expect(y == 124);
}

//sahdowing
const pi = 3.14;
test "inside test block" {
    // Let's even go inside another block
    {
        //expected to fail
        //var pi: i32 = 1234;
    }
}

// sope separation
test "separate scopes" {
    {
        const pi2 = 3.14;
        _ = pi2;
    }
    {
        var pi2: bool = true;
        _ = &pi2;
    }
}

//empty block is equivalent to void

test {
    const a = {};
    const b = void{};
    try expect(@TypeOf(a) == void);
    try expect(@TypeOf(b) == void);
    try expect(a == b);
}
