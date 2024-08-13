const std = @import("std");
const dbg = std.debug;

const Chunk = @import("chunk.zig").Chunk;
const OP = @import("chunk.zig").OP;
const Code = @import("chunk.zig").Code;
const Value = @import("value.zig").Value;

pub fn disassembleChunk(chunk: *Chunk, name: []const u8) void {
    dbg.print("== {s} ==\n", .{name});

    var offset: usize = 0;
    while (offset < chunk.count) {
        offset = disassembleInstruction(chunk, offset);
    }
}

pub fn disassembleInstruction(chunk: *Chunk, offset: usize) usize {
    dbg.print("{d:0>4} ", .{offset});

    if (offset > 0 and chunk.lines.?[offset] == chunk.lines.?[offset - 1]) {
        dbg.print("   | ", .{});
    } else {
        dbg.print("{d: >4} ", .{chunk.lines.?[offset]});
    }

    const instruction: OP = chunk.code.?[offset];
    switch (instruction.code) {
        Code.CONSTANT => return constantInstruction("Code.CONSTANT", chunk, offset),
        Code.RETURN => return simpleInstruction("Code.RETURN", offset),
    }
}

pub fn constantInstruction(name: []const u8, chunk: *Chunk, offset: usize) usize {
    const constant: OP = chunk.code.?[offset + 1];
    dbg.print("{s: <16} {d: >4} '", .{ name, constant.value });
    chunk.constants.values.?[constant.value].printValue();
    dbg.print("'\n", .{});
    return offset + 2;
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
