#!/bin/sh

base=$1

# 20pt
convert "$base" -resize '40x40'     -unsharp 1x4 "Icon-iPhoneNotification@2x.png"
convert "$base" -resize '60x60'     -unsharp 1x4 "Icon-iPhoneNotification@3x.png"

# 29pt
convert "$base" -resize '58x58'     -unsharp 1x4 "Icon-iPhoneSettings@2x.png"
convert "$base" -resize '87x87'     -unsharp 1x4 "Icon-iPhoneSettings@3x.png"

# 49pt
convert "$base" -resize '80x80'     -unsharp 1x4 "Icon-iPhoneSpotlight@2x.png"
convert "$base" -resize '120x120'   -unsharp 1x4 "Icon-iPhoneSpotlight@3x.png"

# 60pt
convert "$base" -resize '120x120'   -unsharp 1x4 "Icon-iPhoneApp@2x.png"
convert "$base" -resize '180x180'   -unsharp 1x4 "Icon-iPhoneApp@3x.png"

# 20pt
convert "$base" -resize '20x20'     -unsharp 1x4 "Icon-iPadNotification.png"
convert "$base" -resize '40x40'     -unsharp 1x4 "Icon-iPadNotification@2x.png"

# 29pt
convert "$base" -resize '29x29'     -unsharp 1x4 "Icon-iPadSettings.png"
convert "$base" -resize '58x58'     -unsharp 1x4 "Icon-iPadSettings@2x.png"

# 49pt
convert "$base" -resize '40x40'     -unsharp 1x4 "Icon-iPadSpotlight.png"
convert "$base" -resize '80x80'     -unsharp 1x4 "Icon-iPadSpotlight@2x.png"

# 76pt
convert "$base" -resize '76x76'     -unsharp 1x4 "Icon-iPadApp.png"
convert "$base" -resize '152x152'   -unsharp 1x4 "Icon-iPadApp@2x.png"

# 83.5pt
convert "$base" -resize '167x167'   -unsharp 1x4 "Icon-iPadProApp@2x.png"

# 1024pt
convert "$base" -resize '1024x1024' -unsharp 1x4 "Icon-AppStore.png"
