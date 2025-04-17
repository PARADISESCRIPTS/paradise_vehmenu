# Paradise Vehicle Control Menu

A modern and intuitive vehicle control menu for FiveM servers, allowing players to control various aspects of their vehicle through a beautiful React-based interface.

## Features

- 🚗 Vehicle Controls:
  - Door controls (front/rear left/right)
  - Window controls (front/rear left/right)
  - Seat switching with cooldown
  - Trunk and hood controls
  - Engine start/stop
  - Radio toggle
  - Key sharing system

- 🎨 Modern UI:
  - Hexagonal button layout
  - Smooth animations
  - Responsive design
  - Intuitive controls
  - Visual feedback for active states

## Preview

[Add preview images/videos here]

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib) - Required for core functionality

## Installation

1. Download the resource
2. Place it in your server's resources directory
3. Add the following to your server.cfg:
```cfg
ensure ox_lib
ensure paradise_vehmenu
```

## Commands

- `/vehmenu` - Open the vehicle control menu

## Development

The resource uses a modern tech stack:
- Frontend: React + TypeScript
- Backend: Lua
- Styling: CSS with modern features

### Building

1. Navigate to the `web` directory
2. Install dependencies:
```bash
npm install
```
3. Build the frontend:
```bash
npm run build
```

## Support

For support, please join our Discord server: [Paradise Scripts](https://discord.gg/cU4te7RQxp)

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Credits

- Developed by Paradise
- UI/UX Design by Paradise Team
- Special thanks to the FiveM community
