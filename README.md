# LoFiVi

LoFiVi uses a force-directed graph to visualise folder structures. It was written from scratch using [Lua](http://www.lua.org/) and the [LÖVE](https://love2d.org/) framework.

Like its big sister [LoGiVi](https://github.com/rm-code/logivi), LoFiVi was inspired by other visualisation software like [Gource](https://code.google.com/p/gource/) or [Cytoscape](http://www.cytoscape.org/). I always was quite intrigued by the beautiful graphs they created and therefore wanted to learn how to make use of the [force-directed layout](http://en.wikipedia.org/wiki/Force-directed_graph_drawing) myself.

![Example](https://github.com/rm-code/lofivi/wiki/media/pz_lofivi.png)

[__Changelog__](https://github.com/rm-code/lofivi/blob/develop/CHANGELOG.md) | [__Source__](https://github.com/rm-code/lofivi) | [__Bug Tracker__](https://github.com/rm-code/lofivi/issues) | [__Latest Release__](https://github.com/rm-code/lofivi/releases/latest)

## Instructions

Run LoFiVi and simply drag a folder on the window to visualise it.

## Configuration File
When you first run LoFiVi it will create a config.lua file in the save directory of LoFiVi. You can use it to change certain aspects of LoFiVi and how the graph is created.

### Custom File Colours
You can specify custom file colours in the config file, by associating a RGBA value with the file extension.

```
#!lua
[...]
fileColors = {
    ['.md']  = { 255, 0, 0, 255 },
    ['.lua'] = { 0, 255, 0, 255 },
},
[...]
```

### Ignore certain files and folders
Certain files, or folders can be ignored by adding them to the ignore list in the config file. You can use string matching (e.g.: '.git') or pattern matching to ignore them. By default, all files and folders starting with a '.' will be ignored. If you want to show them in the graph, remove the pattern (shown below) from the list.

```
#!lua
[...]
-- You can use lua patterns or simple string matching to ignore
-- certain files and folders when creating a graph.
ignore = {
    '^.*%/%.',          -- Ignore files and folders that start with a fullstop.
},
[...]
```

### Other Options
```
#!lua
[...]
options = {
    bgColor = { 0, 0, 0 },
    showLabels = false,
    showFileList = true,

    -- See https://love2d.org/wiki/KeyConstant for a list of possible keycodes.
    keyBindings = {
        camera_n =        'w', -- Move camera up
        camera_w =        'a', -- Move camera left
        camera_s =        's', -- Move camera down
        camera_e =        'd', -- Move camera right
        camera_rotateL =  'q', -- Rotate camera left
        camera_rotateR =  'e', -- Rotate camera right
        camera_zoomIn =   '+', -- Zoom in
        camera_zoomOut =  '-', -- Zoom out
        graph_reset =     'r', -- Reloads the whole graph
        take_screenshot = ' ', -- Take a screenshot
        toggleLabels =    '1', -- Hide / Show labels
        toggleFileList =  '2', -- Hide / Show file list
    },
},
[...]
```
- bgColor - Determines the background color of LoFiVi (RGB)
- showLabels - Determines wether folder labels initially should be hidden or shown
- showFileList - Determines wether the file extension list should be hidden or shown
- keyBindings - Allows you to reassign LoFiVi's controls

### Controls
Note: Controls can be changed in the config file

- w Key - Move camera north
- a Key - Move camera west
- s Key - Move camera south
- d Key - Move camera east
- \+ Key - Zoom in
- \- Key - Zoom out
- r Key - Redraw the graph
- Spacebar - Create a screenshot
- 1 Key - Toggle folder labels
- 2 Key - Toggle file List
