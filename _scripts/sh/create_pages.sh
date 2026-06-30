#!/usr/bin/env bash

set -euo pipefail

TYPE_CATEGORY=0
TYPE_TAG=1

category_count=0
tag_count=0

echo "[INFO] Start generating category/tag pages..."

# ------------------------------------------------
# Safely read YAML front matter
# ------------------------------------------------
_read_yaml() {
  if [[ ! -f "$1" ]]; then
    echo "[WARN] File not found: $1"
    return
  fi
  cat "$1"
}

# ------------------------------------------------
# Read categories
# ------------------------------------------------
read_categories() {
  local result
  result="$(yq e '.categories[]?' "$1" 2>/dev/null || true)"
  if [[ -n "$result" ]]; then
    echo "$result"
    return
  fi

  yq e '.category' "$1" 2>/dev/null || true
}

# ------------------------------------------------
# Read tags
# ------------------------------------------------
read_tags() {
  local result
  result="$(yq e '.tags[]?' "$1" 2>/dev/null || true)"
  if [[ -n "$result" ]]; then
    echo "$result"
    return
  fi

  yq e '.tag' "$1" 2>/dev/null || true
}

# ------------------------------------------------
# Init
# ------------------------------------------------
init() {
  echo "[INFO] Cleaning old categories/ and tags/"
  rm -rf categories tags

  if [[ ! -d _posts ]]; then
    echo "[ERROR] '_posts' directory not found"
    exit 1
  fi

  mkdir -p categories tags
}

# ------------------------------------------------
# Create category page
# ------------------------------------------------
create_category() {
  [[ -z "$1" ]] && return

  local name="$1"
  local slug
  slug="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]/-/g')"
  local file="categories/${slug}.html"

  if [[ ! -f "$file" ]]; then
    echo "[INFO] Creating category: $name"
    cat > "$file" <<EOF
---
layout: category
title: $name
category: $name
---
EOF
    ((category_count++))
  fi
}

# ------------------------------------------------
# Create tag page
# ------------------------------------------------
create_tag() {
  [[ -z "$1" ]] && return

  local name="$1"
  local slug
  slug="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed "s/[[:space:]]/-/g;s/'//g")"
  local file="tags/${slug}.html"

  if [[ ! -f "$file" ]]; then
    echo "[INFO] Creating tag: $name"
    cat > "$file" <<EOF
---
layout: tag
title: $name
tag: $name
---
EOF
    ((tag_count++))
  fi
}

# ------------------------------------------------
# Create pages
# ------------------------------------------------
create_pages() {
  [[ -z "$1" ]] && return

  local IFS=$'\n'

  case "$2" in
    "$TYPE_CATEGORY")
      for i in $1; do
        create_category "$i"
      done
      ;;
    "$TYPE_TAG")
      for i in $1; do
        create_tag "$i"
      done
      ;;
  esac
}

# ------------------------------------------------
# Main
# ------------------------------------------------
main() {
  init

  local _categories _tags

  for file in $(find _posts -type f \( -iname "*.md" -o -iname "*.markdown" \)); do
    echo "[DEBUG] Processing $file"

    _categories="$(read_categories "$file")"
    _tags="$(read_tags "$file")"

    if [[ -z "$_categories" ]]; then
      echo "[WARN] No categories found in $file"
    else
      create_pages "$_categories" "$TYPE_CATEGORY"
    fi

    if [[ -z "$_tags" ]]; then
      echo "[WARN] No tags found in $file"
    else
      create_pages "$_tags" "$TYPE_TAG"
    fi
  done

  echo "[RESULT] Category pages created: $category_count"
  echo "[RESULT] Tag pages created: $tag_count"
}

main