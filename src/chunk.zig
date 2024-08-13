const std = @import("std");
const memory = @import("memory.zig");
const ValueArray = @import("value.zig").ValueArray;
const Value = @import("value.zig").Value;

pub const OP = union {
    value: u8,
    code: Code,
};

pub const Code = enum(u8) {
    CONSTANT,
    RETURN,
};

// This all needs to be rewritten to use std.Arraylist(OpCode)
// :(
pub const Chunk = struct {
    const Self = @This();

    count: usize,
    capacity: usize,
    code: ?[]OP,
    constants: ValueArray,
    lines: ?[]usize,

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Chunk {
        return Chunk{
            .count = 0,
            .capacity = 0,
            .code = null,
            .constants = ValueArray.init(allocator),
            .lines = null,

            .allocator = allocator,
        };
    }

    pub fn write(this: *Self, byte: OP, line: usize) void {
        if (this.capacity < this.count + 1) {
            const old_capacity = this.capacity;
            this.capacity = memory.growCapacity(usize, this.capacity);
            this.code = memory.growArray(OP, this.code, old_capacity, this.capacity, this.allocator);
            this.lines = memory.growArray(usize, this.lines, old_capacity, this.capacity, this.allocator);
        }

        this.code.?[this.count] = byte;
        this.lines.?[this.count] = line;
        this.count += 1;
    }

    pub fn deinit(this: *Self) void {
        this.constants.deinit();
        memory.freeArray(OP, this.code, this.capacity, this.allocator);
        memory.freeArray(usize, this.lines, this.capacity, this.allocator);
        this.count = 0;
        this.capacity = 0;
        this.code = null;
    }

    pub fn addConstant(this: *Self, value: Value) OP {
        this.constants.write(value);
        return OP{ .value = this.constants.count - 1 };
    }
};
