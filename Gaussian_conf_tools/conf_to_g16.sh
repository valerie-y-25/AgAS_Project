#!/bin/bash

# Inputs: <original xxx.com file> <conformers xxx.xyz file>

origFile=$1
confFile=$2

# Extract header from original file
header=$(awk '1;/[0-9] 1/{exit}' "$origFile")
echo "__________"
echo "$header"
echo "__________"

# Extract connectivity block
bondList=$(awk '/^ 1 /,0' "$origFile")
echo "__________"
echo "$bondList"
echo "__________"

# -------------------------------------------------------------
# AUTO-DETECT XYZ BLOCKS:
# Start a new conformer when a line contains ONLY an integer (the atom count)
# -------------------------------------------------------------
i=0
out=""

while IFS= read -r line || [[ -n "$line" ]]; do

  # If the line is ONLY an integer (optionally with spaces)
  if [[ "$line" =~ ^[[:space:]]*[0-9]+[[:space:]]*$ ]]; then
    out="conf${i}.com"
    : > "$out"              # create/overwrite output file
    echo "$line" >> "$out"  # write atom count line

    # read comment line (second line of xyz block)
    if IFS= read -r comment || [[ -n "$comment" ]]; then
      echo "$comment" >> "$out"
    fi

    ((i++))
    continue
  fi

  # Append geometry lines after atom count + comment
  if [[ -n "$out" ]]; then
    echo "$line" >> "$out"
  fi

done < "$confFile"

# Remove empty conf0.com if it exists (happens if file begins before first count)
if [[ -f conf0.com && ! -s conf0.com ]]; then
  rm conf0.com
fi

# -------------------------------------------------------------
# Rebuild each conf*.com using the template header
# -------------------------------------------------------------
for file in conf*.com; do
  [[ -e "$file" ]] || continue

  tmp=$(mktemp)

  echo "$header" > "$tmp"
  tail -n +3 "$file" >> "$tmp"   # skip the atom count + comment lines
  echo >> "$tmp"
  echo "$bondList" >> "$tmp"

  mv "$tmp" "$file"
  echo "Wrote $file"
done
