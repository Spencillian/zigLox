const std = @import("std");

const Chunk = @import("chunk.zig").Chunk;
const OP = @import("chunk.zig").OP;
const Code = @import("chunk.zig").Code;

const Value = @import("value.zig").Value;

const Debug = @import("debug.zig");

const DEBUG: bool = true;

const InterpretResult = enum {
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR,
};

pub const VM = struct {
    const Self = @This();

    chunk: Chunk,
    ip: usize,

    allocator: std.mem.Allocator,

    pub fn init(chunk: *Chunk, allocator: std.mem.Allocator) VM {
        return VM{
            .chunk = chunk,
            .ip = 0,

            .allocator = allocator,
        };
    }

    pub fn interpret(this: Self) InterpretResult {
        while (true) {
            if (comptime DEBUG) {
                Debug.disassembleInstruction(this.chunk, this.ip);
            }

            const instruction: OP = this.readByte();
            switch (instruction.code) {
                Code.CONSTANT => {
                    const constant: Value = this.readConstant();
                    constant.printValue();
                    std.debug.print("\n", {});
                },
                Code.RETURN => return InterpretResult.OK,
            }
        }
    }

    inline fn readByte(this: Self) OP {
        const byte: OP = this.chunk.code.?[this.ip];
        this.ip += 1;
        return byte;
    }

    inline fn readConstant(this: Self) Value {
        this.chunk.constants.values.?[this.ip];
        this.ip += 1;
    }

    pub fn deinit() VM {}
};
