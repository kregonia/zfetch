// 对外导出统一入口，便于测试和外部引用。
pub const app = @import("app.zig");
pub const types = @import("types.zig");
pub const modules = @import("modules/mod.zig");
pub const render_text = @import("render/text.zig");
pub const render_json = @import("render/json.zig");
