#!/usr/bin/env bash
# Usage: bash publish.sh <GITHUB_TOKEN> [USERNAME] [REPO]
# Creates a public GitHub repo (if missing) and pushes the current repo's master branch.
# The token is used only for this run and is stripped from git config afterwards.
set -euo pipefail

TOKEN="${1:-}"
USER="${2:-woliejia}"
REPO="${3:-wecom-chat-export}"

if [[ -z "$TOKEN" ]]; then
  echo "ERROR: missing token. Usage: bash publish.sh <GITHUB_TOKEN>" >&2
  exit 1
fi

# Auto-detect the working local egress proxy. In this sandbox git's auto-detected
# proxy returns 502 for github.com, but curl reaches external hosts via a local
# proxy (e.g. http://127.0.0.1:PORT). Export it so git uses the same working path.
PROXY=$(curl -v -s -o /dev/null https://api.github.com/user 2>&1 | grep -oE 'http://127\.0\.0\.1:[0-9]+' | head -1)
if [[ -n "$PROXY" ]]; then
  export http_proxy="$PROXY" https_proxy="$PROXY"
  echo "==> using egress proxy $PROXY"
else
  echo "==> no local egress proxy detected; using default network path"
fi

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

echo "==> Repo dir: $REPO_DIR"
echo "==> Target: github.com/$USER/$REPO"

# 1) Create repo via API (ignore if it already exists -> 422)
echo "==> Creating repo via GitHub API (public)..."
HTTP=$(curl -s -o /tmp/gh_create_resp.json -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "{\"name\":\"$REPO\",\"public\":true,\"description\":\"Decrypt & export WeCom (企业微信) local chat history — a WorkBuddy skill\",\"homepage\":\"https://github.com/$USER/$REPO\"}" \
  https://api.github.com/user/repos || true)
echo "    API HTTP status: $HTTP"
if [[ "$HTTP" == "201" ]]; then
  echo "    Repo created."
elif [[ "$HTTP" == "422" ]]; then
  echo "    Repo already exists (422) — continuing to push."
else
  echo "    Unexpected API response (HTTP $HTTP):"
  cat /tmp/gh_create_resp.json 2>/dev/null | head -20
fi

# 2) Push using token embedded only for this single push
echo "==> Pushing master..."
git remote set-url origin "https://$TOKEN@github.com/$USER/$REPO.git"
git push -u origin master
PUSH_RC=$?

# 3) Strip token from config so it is never persisted
git remote set-url origin "https://github.com/$USER/$REPO.git"

if [[ $PUSH_RC -eq 0 ]]; then
  echo "==> SUCCESS: https://github.com/$USER/$REPO"
else
  echo "==> PUSH FAILED (rc=$PUSH_RC). Token may lack 'repo' scope or repo name differs."
fi
exit $PUSH_RC
