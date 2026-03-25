#!/bin/bash
# Quick Start Script für Roblox Clicker

echo "🎮 Roblox UI RNG Clicker - Quick Start"
echo "======================================"
echo ""

# Check if Rojo is installed
if command -v rojo &> /dev/null; then
    echo "✅ Rojo found!"
    echo ""
    echo "Starting Rojo server..."
    echo "After this starts, you need to:"
    echo "1. Open Roblox Studio"
    echo "2. Open: roblox-ui-rng-clicker.rbxlx"
    echo "3. Click 'Rojo' button (top right)"
    echo "4. Click 'Connect'"
    echo "5. Run the game (F5 or Play button)"
    echo ""
    rojo serve
else
    echo "❌ Rojo not found!"
    echo "Install Rojo from: https://github.com/rojo-rbx/rojo"
    echo "Then run this script again"
fi
