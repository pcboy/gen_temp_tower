# -*- encoding : utf-8 -*-
#
#          DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                  Version 2, December 2004
#
#  Copyright (C) 2004 Sam Hocevar
#  14 rue de Plaisance, 75014 Paris, France
#  Everyone is permitted to copy and distribute verbatim or modified
#  copies of this license document, and changing it is allowed as long
#  as the name is changed.
#  DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#
#
#  David Hagege <david.hagege@gmail.com>
#

require 'tempfile'

OPENSCAD_EXEC = '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'
SLIC3R_EXEC = '/Applications/Slic3r.app/Contents/MacOS/Slic3r'

max_temp = 250
min_temp = 200
iteration = 10

cube_height = 10
max_steps = (max_temp - min_temp) / iteration
layer_height = 0.2
max_layers = (max_steps * cube_height / layer_height).round

openscad_file = %Q(
  max_temp = #{max_temp};
  min_temp = #{min_temp};
  iteration = #{iteration};

  for (i = [0:1:#{max_steps}])
      translate([0,0, i * #{cube_height}]) {
        difference() {
          cube([10, 10, #{cube_height}]);
          rotate([90, 0, 0])
          linear_extrude(height=1) text(str(min_temp + (i * iteration)), size=2);
        }
      }
)

open('temp_tower.scad', 'w') {|f| f.puts(openscad_file) }
puts "Generation STL file"
%x{#{OPENSCAD_EXEC}  temp_tower.scad -o temp_tower.stl}

Tempfile.open('temp_tower', ENV['TMPDIR']) do |f|
  step = 0
  before_layer_gcode = (0..max_layers).step(max_layers / max_steps).map do |layer|
    step += 1
    "{if layer_z=#{layer}} M104 #{min_temp + (step - 1) * iteration} {endif}"
  end
  puts before_layer_gcode
  f.puts(File.read('Pretty_PLA_V3.ini').gsub(/before_layer_gcode =(.*)$/, "before_layer_gcode=#{}"))
  puts "Slicing file with Slic3r"
  %x{#{SLIC3R_EXEC} temp_tower.stl --load #{f.path} --output temp_tower.gcode}
end

