# gen_temp_tower

A script to generate temperature towers gcode dynamically.
I included a profile for the Prusa MK3 already but you can use your own slic3r config too.

# Dependencies
You need to install to have OpenSCAD and Slic3rPE installed.

# Installation

Just do:

```
$> make
```

# Usage

```
$> ruby gen_temp_power.rb -h
Options:
  -f, --from-temp=<i>         From temperature (default: 195)
  -t, --to-temp=<i>           To temperature (default: 230)
  -i, --iteration=<i>         Degrees step between each increment (e.g if 5, then 195,200,205,...) (default: 5)
  -c, --cube-height=<i>       The height in mm for each temperature iteration (default: 5)
  -s, --slic3r-profile=<s>    Path to your slic3r config. (Default: profiles/mk3/Pretty_PLA_V3.ini)
  -o, --openscad-exec=<s>     Path to openscad executable. (Default: /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD)
  -l, --slic3r-exec=<s>       Path to slic3r executable. (add --no-gui parameter on linux) (default: /Applications/Slic3r.app/Contents/MacOS/Slic3r)
  -h, --help                  Show this message
```

Example:

```
$> ruby gen_temp_tower.rb --from-temp 200 --to-temp 250 --iteration 10
Generation STL file
{if layer_z==1.00}M109 R200 {endif}
{if layer_z==6.00}M109 R210 {endif}
{if layer_z==11.00}M109 R220 {endif}
{if layer_z==16.00}M109 R230 {endif}
{if layer_z==21.00}M109 R240 {endif}
{if layer_z==26.00}M109 R250 {endif}
Slicing file with Slic3r
$>
```

You should then get a temp\_tower.stl file in the temp_tower_output/ directory, and a temp\_tower.gcode in that same dir with the proper gcode dealing with the temperature change.
This temp tower will test the temperatures from 200C to 250C with an iteration of 10C between each step.

You can also specify the path to openscad and Slic3r if they don't match the default ones. For instance on Linux I use an appImage of Slic3r PE and I have to add --no-gui to use it as a cli tool.
So I have to call gen_temp_tower like this:

```
$> ruby gen_temp_power.rb --slic3r-exec="./Slic3rPE-1.41.1-beta+linux64-full-201809261049.AppImage --no-gui" --openscad-exec="openscad-nightly"
```
