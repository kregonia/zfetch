const std = @import("std");
const types = @import("../types.zig");

pub fn write(writer: *std.Io.Writer, results: []const types.ModuleResult) !void {
    try writer.writeByte('{');
    for (results, 0..) |item, i| {
        if (i != 0) try writer.writeByte(',');
        try writer.writeByte('"');
        try writeEscaped(writer, item.name);
        try writer.print("\":\"", .{});
        try writeEscaped(writer, item.value);
        try writer.writeByte('"');
    }
    try writer.print("}}\n", .{});
}

fn writeEscaped(writer: *std.Io.Writer, text: []const u8) !void {
    for (text) |c| {
        switch (c) {
            '"' => try writer.print("\\\"", .{}),
            '\\' => try writer.print("\\\\", .{}),
            '\n' => try writer.print("\\n", .{}),
            '\r' => try writer.print("\\r", .{}),
            '\t' => try writer.print("\\t", .{}),
            else => try writer.writeByte(c),
        }
    }
}

