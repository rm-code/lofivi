# Changelog

--------

## Version xxxx - unreleased

### Additions
- Folders can be dropped directly on LoFiVi to be visualised
- Added new file sprites

### Fixes
- Fixed [#8](https://github.com/rm-code/lofivi/issues/8) - Replace outdated love.graphics.setBlendMode variant
- Fixed [#4](https://github.com/rm-code/lofivi/issues/4) - Small nodes no longer get swallowed by bigger nodes
- Fixed [#3](https://github.com/rm-code/lofivi/issues/3) - Panel isn't hidden by default when the graph is recreated
- Fixed [#1](https://github.com/rm-code/lofivi/issues/1) - Labels no longer rotate with the camera

### Other Changes
- Improved physics calculations

--------

## Version 0121 - 29/03/2015

### Additions
- Added option to de-/activate fullscreen mode in the config file
- Added keybinding to toggle fullscreen mode
- Added option to display a logo on screen (position and size can be changed in the config file)
- Added mouse dragging, which allows the user to move nodes around freely
- Added option to change the movement speed of folder nodes in the config file

### Fixes
- Fixed #B10 - Clamp camera's zoom values
- Fixed sections of the panel getting highlighted while the panel was dragged around, resized or scrolled

### Other Changes
- Files are sorted based on their extension before being placed around the folder nodes
- File nodes now use an image instead of a circle rendered to a canvas to display themselves
- Improved the controls for dragging and resizing the panel

--------

## Version 0085 - 02/03/2015

### Additions
- Added spritebatch and use it to draw files of the graph
- Added option for hiding / showing folder labels to the config file
- Added key binding (L-Key) to allow manual toggling of folder labels
- Added option for hiding / showing the file list
- Added key binding (E-Key) to allow manual toggling of file list
- Added camera controls for rotation
- Added keybindings to the config file
- Added a panel which now contains the file extension list

### Fixes
- Fixed #B6 - Correctly log files without extension
- Fixed #B9 - Correctly exlude files and folders when graph is reset

### Other Changes
- Improved folder label style and position
- File list is now sorted by the amount of files with the same extension
- File list is drawn on top of the graph

--------

## Version 0060 - 23/02/2015

### Additions
- Added a config file
- Added option to ignore certain files and folders by specifying an ignore list in the config file (Closes #B4)
- Added option for a custom background color
- Added option to assign a custom color to a file extension
- Added more statistics to the debug overlay
- Added manual camera controls for zooming (using + and - keys)
- Added manual camera controls for moving (using the arrow keys)
- Added screenshot functionality (using the s-key)

### Other Changes
- Folder nodes are spawned close to their parent
- Files nodes are no longer affected by physical forces, but instead are using a precalculated layout around their parent folder node
- Use delta time to make movement frame independent
- Increase speed at which nodes move (should make the graph settle quicker)
- Root is now the _topmost_ folder of the graph (Closes #B3)

--------

## Version 0039 - 20/02/2015

### Additions
- Added repulsion force between all (and not just connected) nodes
- Added a warning message, when the save directory hasn't been created or no content is found
- Added function to recreate the graph by pressing the R-Key

### Fixes
- Fixed #B1 - File counter is reset when the graph is regenerated
- Fixed #B2 - Forces are limited to prevent excessive movement

--------

## Version 0025 - 18/02/2015

- Recursively read files and folders from the save directory and create a graph
- Added attraction and repulsion forces between connected folders to form a basic graph layout
- Added attraction and repulsion forces to attract files to their parent folder nodes
- Added edges between folder nodes
- Files with the same extension are assigned the same color
- Added a camera which tracks the center of the graph
