const std = @import("std");
const expect = std.testing.expect;

const mtx4x4 = [4][4]f32{
    [_]f32{ 1.0, 0.0, 0.0, 0.0 },
    [_]f32{ 0.0, 1.0, 0.0, 0.0 },
    [_]f32{ 0.0, 0.0, 1.0, 0.0 },
    [_]f32{ 0.0, 0.0, 0.0, 1.0 },
};

test "multidimentional arrays" {
    // Access the 2D array by indexing the outer array, and then the inner array
    try expect(mtx4x4[1][1] == 1.0);

    // Here we iterate with for loops.
    for (mtx4x4, 0..) |row, row_index| {
        for (row, 0..) |cell, conumn_index| {
            if (row_index == conumn_index) {
                try expect(cell == 1.0);
            } else {
                try expect(cell == 0.0);
            }
        }
    }
    // initialize a multidimensional array to zeros
    const all_zero: [4][4]f32 = .{.{0} ** 4} ** 4;
    try expect(all_zero[0][0] == 0);
}
