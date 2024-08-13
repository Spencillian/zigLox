const std = @import("std");
const memory = @import("memory.zig");

pub const Value = union(enum) {
    number: f64,

    pub fn printValue(value: Value) void {
        switch (value) {
            .number => std.debug.print("{d}", .{value.number}),
        }
    }
};

pub const ValueArray = struct {
    const Self = @This();

    capacity: u8,
    count: u8,
    values: ?[]Value,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ValueArray {
        return ValueArray{
            .values = null,
            .capacity = 0,
            .count = 0,
            .allocator = allocator,
        };
    }

    pub fn write(this: *Self, value: Value) void {
        if (this.capacity < this.count + 1) {
            const old_capacity = this.capacity;
            this.capacity = memory.growCapacity(u8, old_capacity);
            this.values = memory.growArray(Value, this.values, old_capacity, this.capacity, this.allocator);
        }

        this.values.?[this.count] = value;
        this.count += 1;
    }

    pub fn deinit(this: *Self) void {
        memory.freeArray(Value, this.values, this.capacity, this.allocator);
        this.count = 0;
        this.capacity = 0;
        this.values = null;
    }
};
