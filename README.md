# zfetch

`zfetch` is a minimal fastfetch-like system summary tool written in Zig.

## Features

- Collects core system information modules: `os`, `kernel`, `cpu`, `memory`, `shell`, `uptime`
- Supports human-readable text output (default)
- Supports machine-friendly JSON output (`--json`)
- Supports selecting only specific modules (`--modules` / `-m`)
- Works on Linux and macOS

## Requirements

- Zig `0.15.2` or newer

## Build

```bash
zig build
```

Binary output:

```bash
./zig-out/bin/zfetch
```

## Run

Run directly from the build system:

```bash
zig build run
```

Show JSON output:

```bash
zig build run -- --json
```

Select modules:

```bash
zig build run -- --modules os,cpu,memory
```

Disable color:

```bash
zig build run -- --no-color
```

## CLI

```text
Usage: zfetch [--json] [--no-color] [--modules a,b,c]

Options:
  --json          print machine-friendly JSON output
  --no-color      disable ANSI colors in text mode
  --modules,-m    comma-separated module list
  --help,-h       show this help
```

## Test

```bash
zig build test
```

## License

Apache License 2.0. See [LICENSE](./LICENSE).
