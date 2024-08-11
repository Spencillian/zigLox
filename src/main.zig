const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const dbg = @import("debug.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args) |arg| {
        try stdout.print("{s}\n", .{arg});
    }

    var chunk = Chunk.init(allocator);
    defer chunk.deinit();

    const constant: usize = chunk.addConstand(1.2);
    chunk.write(OpCode.CONSTANT);
    chunk.write(constant);

    chunk.write(OpCode.RETURN);

    dbg.disassembleChunk(&chunk, "test chunk");
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
