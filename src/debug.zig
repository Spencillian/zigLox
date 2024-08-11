const std = @import("std");
const dbg = std.debug;

const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const Value = @import("value.zig");

pub fn disassembleChunk(chunk: *Chunk, name: []const u8) void {
    dbg.print("== {s} ==\n", .{name});

    var offset: usize = 0;
    while (offset < chunk.count) {
        offset = disassembleInstruction(chunk, offset);
    }
}

pub fn disassembleInstruction(chunk: *Chunk, offset: usize) usize {
    dbg.print("{d:0>4} ", .{offset});

    const instruction: OpCode = chunk.code.?[offset];
    switch (instruction) {
        OpCode.CONSTANT => return constantInstruction("OpCode.CONSTANT", offset),
        OpCode.RETURN => return simpleInstruction("OpCode.RETURN", offset),
        // else => {
        //     dbg.print("Unknown opcode {d}", .{instruction});
        //     return offset + 1;
        // },
    }
}

pub fn constantInstruction(name: []const u8, chunk: *Chunk, offset: usize) usize {
    const constant: Value.Value = chunk.code.?[offset + 1];
    dbg.print("{s: <16} {d: >4}", name, constant);
    Value.printValue(chunk.constants.values.?[constant]);
    dbg.print("\n");
}

pub fn simpleInstruction(name: []const u8, offset: usize) usize {
    // The error for when you put
    // `print("{s}\n", string)` instead of
    // `print("{s}\n", .{string})`
    // is really bad.
    // error: expected tuple or struct argument, found []const u8
    // this could really use a note in the specific case of print
    dbg.print("{s}\n", .{name});
    return offset + 1;
}
