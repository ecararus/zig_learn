const decimal_int = 98222;
const hex_int = 0Xff;
const octal_int = 0o755;
const binary_int = 0b11110000;

// underscores may be placed between two digits as a visual separator
const one_billion = 1_000_000_000;
const binary_mask = 0b1_1111_1111;
const permissions = 0o7_5_5;
const big_address = 0xFF80_0000_0000_0000;

// Primitive Types
// Type	C Equivalent	Description
// i8	int8_t	signed 8-bit integer
// u8	uint8_t	unsigned 8-bit integer
// i16	int16_t	signed 16-bit integer
// u16	uint16_t	unsigned 16-bit integer
// i32	int32_t	signed 32-bit integer
// u32	uint32_t	unsigned 32-bit integer
// i64	int64_t	signed 64-bit integer
// u64	uint64_t	unsigned 64-bit integer
// i128	__int128	signed 128-bit integer
// u128	unsigned __int128	unsigned 128-bit integer
// isize	intptr_t	signed pointer sized integer
// usize	uintptr_t, size_t	unsigned pointer sized integer. Also see #5185

// c_char	char	for ABI compatibility with C
// c_short	short	for ABI compatibility with C
// c_ushort	unsigned short	for ABI compatibility with C
// c_int	int	for ABI compatibility with C
// c_uint	unsigned int	for ABI compatibility with C
// c_long	long	for ABI compatibility with C
// c_ulong	unsigned long	for ABI compatibility with C
// c_longlong	long long	for ABI compatibility with C
// c_ulonglong	unsigned long long	for ABI compatibility with C
// c_longdouble	long double	for ABI compatibility with C

// bool	bool	true or false
// anyopaque	void	Used for type-erased pointers.
// void	(none)	Always the value void{}
// noreturn	(none)	the type of break, continue, return, unreachable, and while (true) {}
// type	(none)	the type of types
// anyerror	(none)	an error code
// comptime_int	(none)	Only allowed for comptime-known values. The type of integer literals.
// comptime_float	(none)	Only allowed for comptime-known values. The type of float literals.
