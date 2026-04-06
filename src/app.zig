const std = @import("std");
const types = @import("types.zig");
const modules = @import("modules/mod.zig");
const render_text = @import("render/text.zig");
const render_json = @import("render/json.zig");

const CliError = error{
    InvalidArguments,
    HelpDisplayed,
};

pub fn run() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_state.deinit();
    const gpa = gpa_state.allocator();

    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const cfg = parseArgs(arena) catch |err| switch (err) {
        error.HelpDisplayed => return,
        else => return err,
    };

    const results = try modules.collectSelected(arena, cfg);

    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    switch (cfg.output_mode) {
        .text => try render_text.write(stdout, results, cfg.color),
        .json => try render_json.write(stdout, results),
    }
    try stdout.flush();
}

fn parseArgs(allocator: std.mem.Allocator) !types.Config {
    var cfg = types.Config{};
    const args = try std.process.argsAlloc(allocator);

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (std.mem.eql(u8, arg, "--json")) {
            cfg.output_mode = .json;
            continue;
        }
        if (std.mem.eql(u8, arg, "--no-color")) {
            cfg.color = false;
            continue;
        }
        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            try writeUsage();
            return CliError.HelpDisplayed;
        }
        if (std.mem.startsWith(u8, arg, "--modules=")) {
            const value = arg["--modules=".len..];
            cfg.selected_modules = try parseModuleList(allocator, value);
            continue;
        }
        if (std.mem.eql(u8, arg, "--modules") or std.mem.eql(u8, arg, "-m")) {
            if (i + 1 >= args.len) {
                try writeError("missing value after --modules");
                return CliError.InvalidArguments;
            }
            i += 1;
            cfg.selected_modules = try parseModuleList(allocator, args[i]);
            continue;
        }

        try writeErrorFmt("unknown argument: {s}", .{arg});
        return CliError.InvalidArguments;
    }

    return cfg;
}

fn parseModuleList(allocator: std.mem.Allocator, raw: []const u8) ![][]const u8 {
    var list: std.ArrayList([]const u8) = .empty;
    defer list.deinit(allocator);

    var iter = std.mem.splitScalar(u8, raw, ',');
    while (iter.next()) |entry| {
        const trimmed = std.mem.trim(u8, entry, " \t\r\n");
        if (trimmed.len == 0) continue;
        try list.append(allocator, try allocator.dupe(u8, trimmed));
    }
    return try list.toOwnedSlice(allocator);
}

fn writeUsage() !void {
    var stderr_buffer: [2048]u8 = undefined;
    var stderr_writer = std.fs.File.stderr().writer(&stderr_buffer);
    const stderr = &stderr_writer.interface;

    try stderr.print(
        \\mgrep - a minimal fastfetch-like system summary
        \\Usage: mgrep [--json] [--no-color] [--modules a,b,c]
        \\
        \\Options:
        \\  --json          print machine-friendly JSON output
        \\  --no-color      disable ANSI colors in text mode
        \\  --modules,-m    comma-separated module list
        \\  --help,-h       show this help
        \\
        \\Modules:
        \\  os,kernel,cpu,memory,shell,uptime
        \\
    , .{});
    try stderr.flush();
}

fn writeError(message: []const u8) !void {
    try writeErrorFmt("{s}", .{message});
}

fn writeErrorFmt(comptime fmt: []const u8, args: anytype) !void {
    var stderr_buffer: [2048]u8 = undefined;
    var stderr_writer = std.fs.File.stderr().writer(&stderr_buffer);
    const stderr = &stderr_writer.interface;
    try stderr.print("error: ", .{});
    try stderr.print(fmt, args);
    try stderr.print("\nrun `mgrep --help` for usage\n", .{});
    try stderr.flush();
}

test "parse module list" {
    const allocator = std.testing.allocator;
    const modules_list = try parseModuleList(allocator, "os, cpu, uptime");
    defer {
        for (modules_list) |item| allocator.free(item);
        allocator.free(modules_list);
    }

    try std.testing.expectEqual(@as(usize, 3), modules_list.len);
    try std.testing.expect(std.mem.eql(u8, modules_list[0], "os"));
    try std.testing.expect(std.mem.eql(u8, modules_list[1], "cpu"));
    try std.testing.expect(std.mem.eql(u8, modules_list[2], "uptime"));
}

