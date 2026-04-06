const std = @import("std");
const types = @import("../types.zig");

pub fn write(writer: *std.Io.Writer, results: []const types.ModuleResult, color: bool) !void {
    var max_name_len: usize = 0;
    for (results) |item| {
        if (item.name.len > max_name_len) max_name_len = item.name.len;
    }

    for (results) |item| {
        if (color) {
            try writer.print("\x1b[36m{s}\x1b[0m", .{item.name});
        } else {
            try writer.print("{s}", .{item.name});
        }

        const pad_len = max_name_len - item.name.len;
        var i: usize = 0;
        while (i < pad_len) : (i += 1) {
            try writer.writeByte(' ');
        }
        try writer.print(" : {s}\n", .{item.value});
    }
}
