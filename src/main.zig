const std = @import("std");
const dbg = @import("debug.zig");
const stdout = std.io.getStdOut().writer();

const Chunk = @import("chunk.zig").Chunk;
const OP = @import("chunk.zig").OP;
const Code = @import("chunk.zig").Code;

const Value = @import("value.zig").Value;

const VM = @import("vm.zig").VM;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args) |arg| {
        try stdout.print("{s}\n", .{arg});
    }

    const vm: VM = VM.init(allocator);
    defer vm.deinit();

    var chunk = Chunk.init(allocator);
    defer chunk.deinit();

    const constant: OP = chunk.addConstant(Value{ .number = 1.2 });
    chunk.write(OP{ .code = Code.CONSTANT }, 123);
    chunk.write(constant, 123);

    chunk.write(OP{ .code = Code.RETURN }, 123);

    dbg.disassembleChunk(&chunk, "test chunk");
    vm.interpret(&chunk);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
