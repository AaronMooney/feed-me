#!/bin/sh

base=$1
target=$2

convert "$base" -resize 33.3333% -gravity SouthWest "$target".png
convert "$base" -resize 66.6666% -gravity SouthWest "$target"@2x.png
cp "$base" "$target"@3x.png