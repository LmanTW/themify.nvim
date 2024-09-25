const std = @import("std");

const utilities = @import("utilities.zig");

// Colorscheme
const Colorscheme = struct {
    repository: []const u8,
    themes: []struct {
        name: []const u8,
        brightness: []const u8,
        temperature: []const u8,
    }
};

// The Main Function :3
pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const cwd = std.fs.cwd();

    const file_buffer = try utilities.readFile(cwd, "../colorschemes.json", allocator);
    defer allocator.free(file_buffer);

    std.debug.print("Loading the colorschemes\n", .{});

    const json = try std.json.parseFromSlice([]Colorscheme, allocator, file_buffer, .{});
    defer json.deinit();

    var ok = true;

    for (json.value) |colorscheme| {
        for (colorscheme.themes) |theme| {
            if (!std.mem.eql(u8, theme.brightness, "dark") and !std.mem.eql(u8, theme.brightness, "light"))  {
                ok = false;

                std.debug.print("| Invalid value \"{s}\" for property \"brightness\" in \"{s}\" (\"{s}\")\n", .{theme.brightness, theme.name, colorscheme.repository});
            }
            if (!std.mem.eql(u8, theme.temperature, "cold") and !std.mem.eql(u8, theme.temperature, "warm"))  {
                ok = false;

                std.debug.print("| Invalid value \"{s}\" for property \"temperature\" in \"{s}\" (\"{s}\")\n", .{theme.temperature, theme.name, colorscheme.repository});
            }
        }
    }

    if (!ok) {
        std.process.exit(1);
    }

    cwd.makeDir("cache") catch {};
    cwd.makeDir("cache/colorschemes") catch {};

    const colorschemes_path = try cwd.realpathAlloc(allocator, "cache/colorschemes");
    defer allocator.free(colorschemes_path);

    for (json.value) |colorscheme| {
        const repository_name = try std.mem.replaceOwned(u8, allocator, colorscheme.repository, "/", "-");
        defer allocator.free(repository_name);

        const colorscheme_path = try std.fs.path.join(allocator, &[_][]const u8{colorschemes_path, repository_name});
        defer allocator.free(colorscheme_path);

        _ = cwd.statFile(colorscheme_path) catch {
            std.debug.print("| Cloning \"{s}\"\n", .{colorscheme.repository});

            const url = try std.mem.concat(allocator, u8, &.{"https://github.com/", colorscheme.repository});
            defer allocator.free(url);

            var process = std.process.Child.init(&[_][]const u8{"git", "clone", url, repository_name}, allocator);

            process.cwd = colorschemes_path;
            process.stdout_behavior = std.process.Child.StdIo.Close;
            process.stderr_behavior = std.process.Child.StdIo.Pipe;

            try process.spawn();

            var stderr_buffer: [1024]u8 = undefined;
            var stderr_size: usize = 0;

            while (true) {
                const read_bytes = try process.stderr.?.read(&stderr_buffer);

                if (read_bytes > 0) {
                    stderr_size = read_bytes;
                } else {
                    break;
                }
            }
            
            switch (try process.wait()) {
                .Exited => |code| {
                    if (code > 0) {
                        const message_buffer = try std.mem.replaceOwned(u8, allocator, stderr_buffer[0..stderr_size], "\n", "\\n");
                        defer allocator.free(message_buffer);

                        std.debug.print("| Error: \"{s}\" ({})\n", .{message_buffer, code});

                        std.process.exit(1);
                    }
                },
                else => {}
            }
        }; 
    }

    std.debug.print("Getting the preview highlights\n", .{});

    const config_path = try std.fs.cwd().realpathAlloc(allocator, "config/main.lua");
    defer allocator.free(config_path);

    var neovim = std.process.Child.init(&[_][]const u8{"nvim", "-u", config_path, "--headless"}, allocator);

//    neovim.stdout_behavior = std.process.Child.StdIo.Close;
//    neovim.stderr_behavior = std.process.Child.StdIo.Close;

    try neovim.spawn();
    _ = try neovim.wait();
}
