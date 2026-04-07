const std = @import("std");

// 输出模式：终端文本或机器可读 JSON。
pub const OutputMode = enum {
    text,
    json,
};

// 模块执行状态：成功、临时不可用、平台不支持。
pub const ModuleStatus = enum {
    ok,
    unavailable,
    unsupported,
};

// 单个模块的标准输出结构。
pub const ModuleResult = struct {
    name: []const u8,
    value: []const u8,
    status: ModuleStatus,
};

// 全局配置，来自 CLI 参数（后续可扩展配置文件）。
pub const Config = struct {
    output_mode: OutputMode = .text,
    color: bool = true,
    selected_modules: ?[][]const u8 = null,

    // 当 selected_modules 为空时默认启用全部模块。
    pub fn wantsModule(self: Config, name: []const u8) bool {
        if (self.selected_modules) |selected| {
            for (selected) |item| {
                if (std.mem.eql(u8, item, name)) return true;
            }
            return false;
        }
        return true;
    }
};
