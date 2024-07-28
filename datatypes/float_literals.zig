const floating_point = 123.0E+77;
const another_loat = 123.0;
const yet_antoehr = 123.0e+77;

const hex_floating_point = 0x103.70p-5;
const another_hex_float = 0x103.70;
const yet_another_hex_float = 0x103.70P-5;

// underscores may be placed between two digits as a visual separator
const lightspeed = 299_792_458.000_000;
const nanosecond = 0.000_000_001;
const more_hex = 0x1234_5678.9ABC_CDEFp-10;

// f16	_Float16	16-bit floating point (10-bit mantissa) IEEE-754-2008 binary16
// f32	float	32-bit floating point (23-bit mantissa) IEEE-754-2008 binary32
// f64	double	64-bit floating point (52-bit mantissa) IEEE-754-2008 binary64
// f80	double	80-bit floating point (64-bit mantissa) IEEE-754-2008 80-bit extended precision
// f128	_Float128	128-bit floating point (112-bit mantissa) IEEE-754-2008 binary128

//special values
const std = @import("std");
const inf = std.math.inf(f32);
const negative_inf = -std.math.inf(f64);
const nan = std.math.nan(f128);
