#!/bin/bash
ESA_ACCESS_TOKEN=$(/usr/bin/security find-generic-password -s 'esa-mcp-token' -w 2>/dev/null)
if [ -z "$ESA_ACCESS_TOKEN" ]; then
  echo "ERROR: esa-mcp-token not found in Keychain" >&2
  exit 1
fi
export ESA_ACCESS_TOKEN
cd /Users/bash/dev/src/github.com/bash0C7/permanent-memory
exec /Users/bash/.rbenv/shims/bundle exec ruby scripts/mcp_server.rb
