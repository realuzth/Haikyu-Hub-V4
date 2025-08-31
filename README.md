# Haikyu Hub V4 - Modular Roblox Script

A comprehensive, modular, and performant Roblox script for character tracking in "Steal a Haikyu" with a futuristic HoHo Hub V4-inspired UI.

## Features

- **Modular Architecture**: Clean separation of concerns across 6 modules
- **Character Tracking**: Real-time monitoring of all Haikyu characters including mutations
- **Futuristic UI**: Modern sci-fi interface with animations and smooth transitions
- **Memory Management**: Proper resource cleanup to prevent memory leaks
- **Performance Optimized**: Efficient polling and update systems
- **Customizable**: Enable/disable individual character tracking

## Module Structure

```
HaikyuHub-Modular/
├── MainLoader.lua      # Entry point and module loader
├── HaikyuLogic.lua     # Character tracking and game logic
├── UIComponents.lua    # UI element factories with styling
├── UIFX.lua           # Animation and visual effects
├── ResourceUtil.lua    # Memory management utilities
└── UIController.lua    # UI orchestration and event handling
```

## Installation

1. Copy all `.lua` files to your executor's workspace
2. Execute `MainLoader.lua` as a LocalScript in Roblox
3. The UI will appear automatically with F4 toggle support

## Usage

### Keyboard Shortcuts
- **F4**: Toggle UI visibility
- **F5**: Minimize/restore UI
- **ESC**: Hide UI

### UI Controls
- **Character Toggles**: Click checkboxes in sidebar to enable/disable tracking
- **Enable All**: Button to enable tracking for all characters
- **Disable All**: Button to disable tracking for all characters
- **Drag Support**: Click and drag the header to move the UI

### Character Status Indicators
- **Green Dot**: Character currently present
- **Orange Dot**: Character was present but now absent
- **Gray Dot**: Character never seen this session

## Character Database

The script tracks all Haikyu characters including:
- **Base Characters**: 30 original characters from Common to Secret rarity
- **Golden Variants**: 1.25x income multiplier
- **Diamond Variants**: 1.75x income multiplier  
- **Emerald Variants**: 2.4x income multiplier

Total: **120 trackable characters**

## Technical Details

### Memory Management
- Automatic cleanup of event connections
- Tween and timer tracking with safe disposal
- Resource groups for organized cleanup
- Emergency cleanup function available

### Performance Features
- Configurable update intervals (default: 0.15s)
- Efficient workspace scanning
- Throttled UI updates
- Memory usage monitoring

### UI Animations
- Smooth fade in/out transitions
- Button press feedback
- Glow pulse effects
- Loading spinners and progress bars
- Notification popups

## Configuration

Edit the CONFIG tables in each module to customize:
- Update intervals
- Animation speeds
- Color schemes
- Sound effects
- UI dimensions

## Troubleshooting

### Common Issues
1. **Script not loading**: Ensure all modules are in the same directory
2. **UI not appearing**: Check if F4 was pressed or UI is minimized
3. **Characters not tracking**: Verify character names match exactly
4. **Performance issues**: Increase update intervals in CONFIG

### Debug Information
- Check console output for module loading status
- Use F5 to access performance stats
- Resource usage displayed in info label

## Development

### Adding New Characters
1. Update `CHARACTER_DATABASE` in `HaikyuLogic.lua`
2. Add to the ordered character list
3. Restart the script

### Customizing UI
1. Modify color palette in `UIComponents.lua`
2. Adjust animations in `UIFX.lua`
3. Update layout in `UIController.lua`

### Module Dependencies
```
MainLoader → All Modules
UIController → HaikyuLogic, UIComponents, UIFX, ResourceUtil
UIComponents → (standalone)
UIFX → (standalone)
HaikyuLogic → (standalone)
ResourceUtil → (standalone)
```

## License

This script is provided as-is for educational and personal use in Roblox.

## Support

For issues or feature requests, ensure all modules are properly loaded and check the console for error messages.
