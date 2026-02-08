# gopls MCP Server Configuration

This directory contains the configuration and wrapper scripts for the gopls MCP (Model Context Protocol) server used by GitHub Copilot agents.

## Overview

The gopls MCP server enables GitHub Copilot to work efficiently with Go code by providing language intelligence features such as:

- Code navigation and symbol search
- Package API information
- Cross-file dependency analysis
- Build diagnostics and error checking
- Quick fixes and refactoring suggestions
- Vulnerability scanning with govulncheck

## Files

- **`goplsmcp`**: Wrapper script that starts the gopls MCP server
  - Sets the working directory to `GITHUB_WORKSPACE` (or current directory)
  - Passes all command-line arguments to `gopls mcp`
  - Executable script that must be in PATH for Copilot to use it

## Configuration

The gopls MCP server is configured through the GitHub Actions workflow at `.github/workflows/copilot-setup-steps.yml`:

1. **Go Installation**: Sets up Go 1.25
2. **gopls Installation**: Installs gopls v0.21.0 using `go install`
3. **PATH Setup**: Adds `.github/agent/bin` to PATH
4. **Verification**: Runs automated tests to verify the configuration

## Usage

The `goplsmcp` wrapper can be invoked with any gopls mcp command-line flags:

```bash
# Start the MCP server over stdio (default)
goplsmcp

# Print the gopls MCP instructions
goplsmcp -instructions

# Start the MCP server on HTTP
goplsmcp -listen=localhost:3000

# Enable RPC tracing
goplsmcp -rpc.trace
```

## Testing

The configuration is automatically tested by `.github/workflows/test-gopls-mcp.sh`, which verifies:

1. ✓ gopls is installed and accessible
2. ✓ gopls mcp command is available
3. ✓ gopls mcp -instructions works
4. ✓ goplsmcp wrapper script exists
5. ✓ goplsmcp script is executable
6. ✓ goplsmcp script contains correct command
7. ✓ goplsmcp wrapper passes arguments correctly
8. ✓ gopls is in PATH
9. ✓ Agent bin directory is properly configured

Run the tests manually:

```bash
.github/workflows/test-gopls-mcp.sh
```

## Requirements

- Go 1.25 or later
- gopls v0.21.0 or later
- Bash shell

## Troubleshooting

If the gopls MCP server is not working:

1. **Check gopls installation**: Run `gopls version`
2. **Verify MCP support**: Run `gopls help mcp`
3. **Test the wrapper**: Run `goplsmcp -instructions`
4. **Run the test suite**: Run `.github/workflows/test-gopls-mcp.sh`
5. **Check permissions**: Ensure `goplsmcp` is executable (`chmod +x`)

## References

- [gopls Documentation](https://github.com/golang/tools/tree/master/gopls)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
- [GitHub Copilot Agent Setup](https://docs.github.com/copilot)
