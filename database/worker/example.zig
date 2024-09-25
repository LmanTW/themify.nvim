const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("message.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;

    const buffer_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    std.debug.print("{s}", .{buffer});
}
