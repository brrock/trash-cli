#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Building CLI for all platforms...${NC}\n"
bun i 
mkdir -p dist

# Bun's supported targets
TARGETS=(
  "bun-darwin-x64"
  "bun-darwin-arm64"
  "bun-linux-x64"
  "bun-windows-x64"
)

for TARGET in "${TARGETS[@]}"; do
  echo -e "${BLUE}Compiling for ${TARGET}...${NC}"
  
  bun build ./cli.ts \
    --compile \
    --target="${TARGET}" \
    --outfile="dist/cli-${TARGET}"
  
  echo -e "${GREEN}✓ Built: dist/cli-${TARGET}${NC}\n"
done

echo -e "${BLUE}Updating package.json...${NC}"

# Create wrapper script
cat > dist/cli-wrapper.js << 'EOF'
#!/usr/bin/env node
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const platform = os.platform();
const arch = os.arch();

let binary;
if (platform === 'darwin' && arch === 'arm64') {
  binary = 'cli-bun-darwin-arm64';
} else if (platform === 'darwin') {
  binary = 'cli-bun-darwin-x64';
} else if (platform === 'linux') {
  binary = 'cli-bun-linux-x64';
} else if (platform === 'win32') {
  binary = 'cli-bun-windows-x64.exe';
} else {
  console.error(`Unsupported platform: ${platform} ${arch}`);
  process.exit(1);
}

const binaryPath = path.join(__dirname, binary);
execSync(binaryPath, { stdio: 'inherit' });
EOF

chmod +x dist/cli-wrapper.js

bunx jq '.bin.cli = "./dist/cli-wrapper.js"' package.json > package.json.tmp && \
  mv package.json.tmp package.json

echo -e "${GREEN}✓ Build complete!${NC}"