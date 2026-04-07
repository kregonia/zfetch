const std = @import("std");
const types = @import("../types.zig");
const os = @import("os.zig");
const kernel = @import("kernel.zig");
const cpu = @import("cpu.zig");
const memory = @import("memory.zig");
const shell = @import("shell.zig");
const uptime = @import("uptime.zig");

// 模块采集函数统一签名。
const Collector = fn (allocator: std.mem.Allocator) anyerror![]const u8;

// 模块定义：名字 + 采集函数。
const ModuleDef = struct {
    name: []const u8,
    collect: *const Collector,
};

// 模块注册表：决定默认顺序和可用模块集合。
const module_defs = [_]ModuleDef{
    .{ .name = "os", .collect = os.collect },
    .{ .name = "kernel", .collect = kernel.collect },
    .{ .name = "cpu", .collect = cpu.collect },
    .{ .name = "memory", .collect = memory.collect },
    .{ .name = "shell", .collect = shell.collect },
    .{ .name = "uptime", .collect = uptime.collect },
};

// 按配置筛选并收集模块结果。
pub fn collectSelected(allocator: std.mem.Allocator, cfg: types.Config) ![]types.ModuleResult {
    var list: std.ArrayList(types.ModuleResult) = .empty;
    defer list.deinit(allocator);

    for (module_defs) |def| {
        if (!cfg.wantsModule(def.name)) continue;
        const item = try collectOne(allocator, def);
        try list.append(allocator, item);
    }

    return try list.toOwnedSlice(allocator);
}

// 将模块内部错误映射为统一的对外状态。
fn collectOne(allocator: std.mem.Allocator, def: ModuleDef) !types.ModuleResult {
    const value = def.collect(allocator) catch |err| switch (err) {
        error.Unsupported => return .{
            .name = def.name,
            .value = "unsupported",
            .status = .unsupported,
        },
        else => return .{
            .name = def.name,
            .value = "unavailable",
            .status = .unavailable,
        },
    };

    return .{
        .name = def.name,
        .value = value,
        .status = .ok,
    };
}
