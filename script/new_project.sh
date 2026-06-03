#!/usr/bin/env bash
# Run from the template root: ./script/new_project.sh
# Asks where to create the new project, then copies the template there and runs setup
# (fresh git, flutter upgrade, pub get, test). Prevents accidentally running in the wrong directory.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Template root: $TEMPLATE_ROOT"
echo ""
read -r -p "Where do you want to create the new project? (full path): " DEST
DEST="$(echo "$DEST" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
# Expand ~ to $HOME (shell doesn't expand ~ inside variables)
case "$DEST" in
  ~) DEST="$HOME" ;;
  ~/*) DEST="$HOME/${DEST#\~/}" ;;
  ~*) DEST="$HOME/${DEST#\~}" ;;
esac

if [ -z "$DEST" ]; then
  echo "No path given. Exiting."
  exit 1
fi

if [ -e "$DEST" ]; then
  if [ -f "$DEST" ]; then
    echo "Error: Path exists and is a file. Choose a different path."
    exit 1
  fi
  if [ -d "$DEST" ]; then
    if [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
      echo "Error: Path already exists and is not empty. Choose a different path or remove it first."
      exit 1
    fi
    echo "Path exists but is empty. Copying template into it."
    COPY_INTO_EXISTING=1
  fi
else
  read -r -p "Path does not exist. Create it? [y/N]: " CREATE
  case "$CREATE" in
    [yY]|[yY][eE][sS])
      ;;
    *)
      echo "Exiting."
      exit 0
      ;;
  esac
fi

echo "Copying template to $DEST ..."
if [ -n "$COPY_INTO_EXISTING" ]; then
  (cd "$TEMPLATE_ROOT" && tar cf - .) | (cd "$DEST" && tar xf -)
else
  # DEST doesn't exist: cp -R creates DEST with template's contents
  cp -R "$TEMPLATE_ROOT" "$DEST"
fi

NEW_PROJECT_ROOT="$DEST"

echo "Removing .git and initializing fresh repo..."
rm -rf "$NEW_PROJECT_ROOT/.git"
(cd "$NEW_PROJECT_ROOT" && git init)

echo "Running flutter upgrade..."
(cd "$NEW_PROJECT_ROOT" && flutter upgrade)

echo "Running flutter pub get..."
(cd "$NEW_PROJECT_ROOT" && flutter pub get)

echo "Running flutter test..."
(cd "$NEW_PROJECT_ROOT" && flutter test)

echo ""
echo "Done. New project is at: $NEW_PROJECT_ROOT"
echo "Open this folder in Cursor and start coding."
echo "  cd $NEW_PROJECT_ROOT"
