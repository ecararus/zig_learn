const print = @import("std").debug.print;

/// this is doc comment for main function.
pub fn main() void {
    // Some comment here.
    // another commetn here.

    print("Hello, World!\n", .{}); //another comment here.
}
//zig test -femit-docs ./src/comment.zig
