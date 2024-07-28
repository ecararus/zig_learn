const std = @import("std");
const expect = std.testing.expect;

// comptime duck typing / generics
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}
fn biggestFloat(a: f32, b: f32) f32 {
    return max(f32, a, b);
}
fn biggestInt(a: i32, b: i32) i32 {
    return max(i32, a, b);
}
test "comptime duck typing" {
    try expect(biggestFloat(1.0, 2.0) == 2.0);
    try expect(biggestInt(1, 2) == 2);
    try expect(max(i32, 1, 2) == 2);
}

// compttime evaluation
const CmdFn = struct {
    name: []const u8,
    func: fn (i32) i32,
};

const cmd_fns = [_]CmdFn{
    CmdFn{ .name = "one", .func = one },
    CmdFn{ .name = "two", .func = two },
    CmdFn{ .name = "three", .func = three },
};
fn one(x: i32) i32 {
    return x + 1;
}
fn two(x: i32) i32 {
    return x + 2;
}
fn three(x: i32) i32 {
    return x + 3;
}

fn performFn(comptime prefix_char: u8, start_val: i32) i32 {
    var result = start_val;
    comptime var i = 0;
    inline while (i < cmd_fns.len) : (i += 1) {
        if (cmd_fns[i].name[0] == prefix_char) {
            result = cmd_fns[i].func(result);
        }
    }
    return result;
}

test "perform comp eval" {
    try expect(performFn('o', 0) == 1);
    try expect(performFn('t', 1) == 6);
    try expect(performFn('w', 99) == 99);
}

// comptime expression
fn fibonacci(index: u32) u32 {
    if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

test "fibonacci" {
    // test fibonacci at run-time
    try expect(fibonacci(7) == 13);

    // test fibonacci at compile-time
    try comptime expect(fibonacci(7) == 13);
}

// constainer level comptime
const first_25_primes = firstNPrimes(25);
const sum_of_first_25_primes = sum(&first_25_primes);

fn firstNPrimes(comptime n: usize) [n]i32 {
    var prime_list: [n]i32 = undefined;
    var next_index: usize = 0;
    var test_number: i32 = 2;
    while (next_index < prime_list.len) : (test_number += 1) {
        var test_prime_index: usize = 0;
        var is_prime = true;
        while (test_prime_index < next_index) : (test_prime_index += 1) {
            if (test_number % prime_list[test_prime_index] == 0) {
                is_prime = false;
                break;
            }
        }
        if (is_prime) {
            prime_list[next_index] = test_number;
            next_index += 1;
        }
    }
    return prime_list;
}

fn sum(numbers: []const i32) i32 {
    var result: i32 = 0;
    for (numbers) |x| {
        result += x;
    }
    return result;
}

test "variable values" {
    try expect(sum_of_first_25_primes == 1060);
}

// Generics
fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}

// The generic List data structure can be instantiated by passing in a type:
var buffer: [10]i32 = undefined;
var list = List(i32){
    .items = &buffer,
    .len = 0,
};

test "Generics" {
    try expect(list.len == 0);
    try expect(list.items.len == 10);
}
