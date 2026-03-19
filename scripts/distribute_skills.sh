#!/usr/bin/env bash
set -euo pipefail

# Distributes unified skills to vendor-specific directories via symlinks (or copy if symlinks fail)

SKILLS_SRC="unified-skills"
TARGETS=(".codex/skills" ".claude/skills" ".gemini/skills")

# Ensure source exists
if [ ! -d "$SKILLS_SRC" ]; then
  echo "Error: Source directory '$SKILLS_SRC' not found."
  exit 1
fi

for target in "${TARGETS[@]}"; do
  echo "Configuring $target..."
  mkdir -p "$target"
  
  # Iterate through each skill in the source
  for skill in "$SKILLS_SRC"/*; do
    [ -d "$skill" ] || continue
    skill_name=$(basename "$skill")
    dest="$target/$skill_name"
    
    # Check for existing content
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      # If it's a symlink to our unified-skills, it's fine to overwrite (update)
      if [ -L "$dest" ] && readlink "$dest" | grep -q "unified-skills"; then
        rm "$dest"
      else
        # It's a real directory or a different symlink. Back it up.
        echo "    Backing up existing $skill_name to $skill_name.bak"
        mv "$dest" "${dest}.bak"
      fi
    fi
    
    # Create symlink (relative path)
    # Calculate relative path from target to source
    # e.g., .codex/skills -> ../../unified-skills
    rel_path="../../$SKILLS_SRC/$skill_name"
    
    ln -s "$rel_path" "$dest"
    echo "  Linked $skill_name -> $dest"
  done
done

echo "Skill distribution complete."
