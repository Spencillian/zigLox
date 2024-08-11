const std = @import("std");
const memory = @import("memory.zig");
const ValueArray = @import("value.zig").ValueArray;
const Value = @import("value.zig").Value;

pub const OpCode = enum(u8) {
    CONSTANT,
    RETURN,
};

// This all needs to be rewritten to use std.Arraylist(OpCode)
// :(
pub const Chunk = struct {
    const Self = @This();

    count: usize,
    capacity: usize,
    code: ?[]OpCode,
    constants: ValueArray,

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Chunk {
        return Chunk{
            .count = 0,
            .capacity = 0,
            .code = null,
            .constants = ValueArray.init(allocator),

            .allocator = allocator,
        };
    }

    pub fn write(this: *Self, byte: OpCode) void {
        if (this.capacity < this.count + 1) {
            const old_capacity = this.capacity;
            this.capacity = memory.growCapacity(this.capacity);
            this.code = memory.growArray(OpCode, this.code, old_capacity, this.capacity, this.allocator);
        }

        this.code.?[this.count] = byte;
        this.count += 1;
    }

    pub fn deinit(this: *Self) void {
        this.constants.deinit();
        memory.freeArray(OpCode, this.code, this.capacity, this.allocator);
        this.count = 0;
        this.capacity = 0;
        this.code = null;
    }

    pub fn addConstand(this: *Self, value: Value) usize {
        this.constants.write(value);
        return this.constants.count - 1;
    }
};
