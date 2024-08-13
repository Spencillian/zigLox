const std = @import("std");

pub fn reallocate(
    comptime T: type,
    pointer: ?[]T,
    old_size: usize,
    new_size: usize,
    allocator: std.mem.Allocator,
) ?[]T {
    if (old_size == 0) {
        return allocator.alloc(T, new_size) catch {
            @panic("Failed to allocate more memory");
        };
    }

    if (new_size == 0) {
        if (pointer) |somepointer| allocator.free(somepointer);
        return null;
    }

    // The error that happens when a optional pointer is attempted
    // to be freed is terrible.
    // error: access of union field 'Pointer' while field 'Optional' is active
    // While technically correct, for the case of allocating
    // memory, this error could use a note
    const result: []T = if (pointer) |somepointer| {
        return allocator.realloc(somepointer, new_size) catch @panic("Failed to allocate more memory");
    } else @panic("Non-zero length UBA pointer was null");

    return result;
}

pub inline fn growCapacity(comptime T: type, capacity: T) T {
    return if (capacity < 8) 8 else capacity * 2;
}

// What on earth can you actually use comptime with?
// can you just do anything like `comptime thingy: comptime_int`
// or do you need some discipline
// Why can't you do `comptime code: ?[]T` here? I'd assume that
// comptime would be needed for the `T` part but I guess not.
pub inline fn growArray(
    comptime T: type,
    code: ?[]T,
    old_size: usize,
    new_size: usize,
    allocator: std.mem.Allocator,
) ?[]T {
    return reallocate(T, code, old_size, new_size, allocator);
}

pub inline fn freeArray(
    comptime T: type,
    pointer: ?[]T,
    old_size: usize,
    allocator: std.mem.Allocator,
) void {
    _ = reallocate(T, pointer, old_size, 0, allocator);
}
