#!/usr/bin/env ruby
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
require 'optimist'

opts = Optimist::options do
  opt :from_temp, "From temperature", default: 195
  opt :to_temp, "To temperature", default: 230
  opt :iteration, "Degrees step between each increment (e.g if 5, then 195,200,205,...)", default: 5
  opt :cube_height, "The height in mm for each temperature iteration", default: 5
  opt :slic3r_profile, "Path to your slic3r config.", default: 'profiles/mk3/Pretty_PLA_V3.ini'
  opt :openscad_exec, "Path to openscad executable.", default: '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'
  opt :slic3r_exec, "Path to slic3r executable. (add --no-gui parameter on linux)", default: '/Applications/Slic3r.app/Contents/MacOS/Slic3r'
end

OPENSCAD_EXEC = ENV['OPENSCAD_EXEC'] || opts[:openscad_exec]
SLIC3R_EXEC = ENV['SLIC3R_EXEC'] || opts[:slic3r_exec]


min_temp = opts[:from_temp]
max_temp = opts[:to_temp]
iteration = opts[:iteration]
cube_height = opts[:cube_height]

max_steps = (max_temp - min_temp) / iteration
max_height = max_steps * cube_height

openscad_file = %Q(
  max_temp = #{max_temp};
  min_temp = #{min_temp};
  iteration = #{iteration};

  for (i = [0:1:#{max_steps}])
      translate([0,0, i * #{cube_height}]) {
        difference() {
          cube([20, 20, #{cube_height}]);
          translate([0, .2, .1])
          rotate([90, 0, 0])
          linear_extrude(height=1) text(str(min_temp + (i * iteration)), size=2);
        }
      }
)

output_dir = './temp_tower_output'
FileUtils.mkdir_p output_dir

open("#{output_dir}/temp_tower.scad", 'w') {|f| f.puts(openscad_file) }
puts "Generation STL file"
%x{#{OPENSCAD_EXEC}  #{output_dir}/temp_tower.scad -o #{output_dir}/temp_tower.stl}


Tempfile.open('temp_tower', ENV['TMPDIR']) do |f|
  step = 0
  before_layer_gcode = (0..max_height).step(max_steps).map do |layer_height|
    step += 1
    "{if layer_z==#{layer_height + 1}.00}M109 R#{min_temp + (step - 1) * iteration} {endif}"
  end
  puts before_layer_gcode
  new_config = File.read(opts[:slic3r_profile])
                   .gsub(/before_layer_gcode =.*$/, "before_layer_gcode=#{before_layer_gcode.join('\n')}")
                   .gsub(/^temperature =.*$/, "temperature = #{min_temp}\n")
  f.puts(new_config)
  f.flush
  puts "Slicing file with Slic3r"
  %x{#{SLIC3R_EXEC} #{output_dir}/temp_tower.stl --load #{f.path} --output #{output_dir}/temp_tower.gcode}
end

