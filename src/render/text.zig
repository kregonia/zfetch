const std = @import("std");
const types = @import("../types.zig");

// 终端文本渲染：按最长模块名对齐，支持可选颜色。
pub fn write(writer: *std.Io.Writer, results: []const types.ModuleResult, color: bool) !void {
    var max_name_len: usize = 0;
    for (results) |item| {
        if (item.name.len > max_name_len) max_name_len = item.name.len;
    }

    for (results) |item| {
        if (color) {
            try writer.print("\x1b[32m{s:^5} {s}\x1b[0m", .{ item.icon, item.value });
        } else {
            try writer.print("{s}", .{item.name});
        }

        // 手工补空格，避免不同 Zig 版本格式化占位符差异。
        const pad_len = max_name_len - item.name.len;
        var i: usize = 0;
        while (i < pad_len) : (i += 1) {
            try writer.writeByte(' ');
        }
        try writer.print(" : {s}\n", .{item.value});
    }
}
