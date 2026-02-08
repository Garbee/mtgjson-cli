#!/usr/bin/env bash
# Test script to verify gopls MCP server configuration
# This script validates that gopls MCP server is properly configured and can start

set -euo pipefail

echo "=== Testing gopls MCP Server Configuration ==="
echo ""

# Test 1: Check if gopls is installed
echo "Test 1: Checking gopls installation..."
if command -v gopls &> /dev/null; then
    GOPLS_VERSION=$(gopls version 2>&1)
    echo "✓ gopls is installed: $GOPLS_VERSION"
else
    echo "✗ gopls is not installed"
    exit 1
fi
echo ""

# Test 2: Check if gopls supports mcp command
echo "Test 2: Checking gopls mcp command support..."
if gopls help mcp &> /dev/null; then
    echo "✓ gopls mcp command is available"
else
    echo "✗ gopls mcp command is not available"
    exit 1
fi
echo ""

# Test 3: Check if gopls mcp can print instructions
echo "Test 3: Testing gopls mcp -instructions..."
if gopls mcp -instructions > /tmp/gopls-instructions.txt 2>&1; then
    LINES=$(wc -l < /tmp/gopls-instructions.txt)
    echo "✓ gopls mcp -instructions works (output: $LINES lines)"
    # Show first few lines
    echo "  First 3 lines of instructions:"
    head -3 /tmp/gopls-instructions.txt | sed 's/^/  > /'
    rm /tmp/gopls-instructions.txt
else
    echo "✗ gopls mcp -instructions failed"
    exit 1
fi
echo ""

# Test 4: Check if goplsmcp wrapper script exists
echo "Test 4: Checking goplsmcp wrapper script..."
SCRIPT_PATH="${GITHUB_WORKSPACE:-.}/.github/agent/bin/goplsmcp"
if [ -f "$SCRIPT_PATH" ]; then
    echo "✓ goplsmcp script exists at $SCRIPT_PATH"
else
    echo "✗ goplsmcp script not found at $SCRIPT_PATH"
    exit 1
fi
echo ""

# Test 5: Check if goplsmcp is executable
echo "Test 5: Checking goplsmcp permissions..."
if [ -x "$SCRIPT_PATH" ]; then
    echo "✓ goplsmcp script is executable"
else
    echo "✗ goplsmcp script is not executable"
    exit 1
fi
echo ""

# Test 6: Verify goplsmcp script content
echo "Test 6: Verifying goplsmcp script content..."
if grep -q "exec gopls mcp" "$SCRIPT_PATH"; then
    echo "✓ goplsmcp script contains correct command"
else
    echo "✗ goplsmcp script does not contain expected command"
    exit 1
fi
echo ""

# Test 7: Test that goplsmcp can be executed with -instructions
echo "Test 7: Testing goplsmcp wrapper with -instructions..."
if timeout 5 "$SCRIPT_PATH" -instructions > /tmp/goplsmcp-test.txt 2>&1; then
    LINES=$(wc -l < /tmp/goplsmcp-test.txt)
    echo "✓ goplsmcp wrapper works (output: $LINES lines)"
    rm /tmp/goplsmcp-test.txt
else
    echo "✗ goplsmcp wrapper test failed"
    exit 1
fi
echo ""

# Test 8: Check if gopls can be found in PATH from the workflow
echo "Test 8: Checking gopls in PATH..."
GOPLS_PATH=$(which gopls)
echo "✓ gopls found at: $GOPLS_PATH"
echo ""

# Test 9: Verify agent bin directory setup
echo "Test 9: Checking agent bin directory..."
AGENT_BIN="${GITHUB_WORKSPACE:-.}/.github/agent/bin"
if [ -d "$AGENT_BIN" ]; then
    echo "✓ Agent bin directory exists at $AGENT_BIN"
    echo "  Contents:"
    ls -la "$AGENT_BIN" | sed 's/^/  /'
else
    echo "✗ Agent bin directory not found"
    exit 1
fi
echo ""

echo "=== All Tests Passed! ==="
echo ""
echo "Summary:"
echo "  - gopls is installed and working"
echo "  - gopls mcp command is functional"
echo "  - goplsmcp wrapper script is properly configured"
echo "  - All required files have correct permissions"
echo ""
echo "The gopls MCP server is correctly configured!"
