# Main interface for the database poppulator
# Author:: Simon Symeonidis (mailto:psyomn@xenagoras.net)
# License:: GPL v3

# TODO add  times  [ ]  capability

require_relative 'RandomEngine.rb'

$VERSION = 1;

finished = false

ren = RandomEngine.new
cmd  = ""

while !finished do
	print "sol::"
	cmd = $stdin.gets
	cmd.chomp!

	case cmd 
		when /end|quit|exit/ then finished = true
		when "random"
			ren.commandInterface # access the interface
		when "mingle"
			# ...
		else
			puts "default"
	end
end

puts "Bye!"
