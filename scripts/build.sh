#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
version=${LAZYCAT_VERSION:-$(awk '/^version:/ { print $2; exit }' "$project_root/package.yml")}

if ! printf '%s\n' "$version" | grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'; then
  printf 'Invalid application version: %s\n' "$version" >&2
  exit 1
fi

archive_name="v${version}.tar.gz"
expected_sha=$(awk -v name="$archive_name" '$2 == name { print $1; exit }' "$project_root/upstream-checksums.txt")
if [ -z "$expected_sha" ]; then
  printf 'Missing trusted checksum for upstream tag archive %s\n' "$archive_name" >&2
  exit 1
fi

build_root=$(mktemp -d)
trap 'find "$build_root" -mindepth 1 -delete; rmdir "$build_root"' EXIT HUP INT TERM
archive_path="$build_root/$archive_name"
source_dir="$build_root/source"
mkdir -p "$source_dir"

curl --fail --location --silent --show-error \
  --retry 3 --connect-timeout 15 --max-time 180 \
  "https://github.com/xr843/insect-world/archive/refs/tags/v${version}.tar.gz" \
  --output "$archive_path"
printf '%s  %s\n' "$expected_sha" "$archive_path" | sha256sum --check --status

tar -xzf "$archive_path" -C "$source_dir" --strip-components=1
cd "$source_dir"
npm ci
npm test
npm run build

content_dir="$project_root/content/dist"
mkdir -p "$content_dir"
find "$content_dir" -mindepth 1 -delete
cp -R "$source_dir/dist/." "$content_dir/"
