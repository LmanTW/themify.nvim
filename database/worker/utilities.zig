const std = @import("std");

// Read A File
pub fn readFile(cwd: std.fs.Dir, sub_path:[]const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try cwd.openFile(sub_path, .{});
    defer file.close();

    const buffer_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, buffer_size);

    _ = try file.readAll(buffer);

    return buffer;
}
