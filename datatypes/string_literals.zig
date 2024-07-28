const print = @import("std").debug.print;
const mem = @import("std").mem;

pub fn main() void {
    const bytes = "Hello, World!";
    print("{}\n", .{@TypeOf(bytes)});
    print("{d}\n", .{bytes.len});
    print("{c}\n", .{bytes[1]});
    print("{d}\n", .{bytes[1]});
    print("{}\n", .{'f' == '\x66'});
    print("{d}\n", .{'\u{1f4a9}'});
    print("{d}\n", .{'💯'}); // 128175
    print("{u}\n", .{'⚡'});
    print("{}\n", .{mem.eql(u8, bytes, "H\x65llo, World!")});
    const invalid_utf8 = "\xff\xfe";
    print("0x{x}\n", .{invalid_utf8[1]});
    print("0x{x}\n", .{"💯"[1]});
}
