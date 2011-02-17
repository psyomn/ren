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
	cmd = $stdin.gets
	cmd.chomp!

	case cmd 
		when /end|quit|exit/ then finished = true
		when "setdelim1"
			print "Set delim 1: " # TODO Handle Newline 
			d1 = $stdin.gets.chomp!
			ren.mDelim1 = d1
		when "setdelim2"
			print "Set delim 2: " # TODO Handle Newline
			d2 = $stdin.gets.chomp!
			ren.mDelim2 = d2
		when "license"
			puts "GPL v3 license"
			puts "author: Simon Symeonidis "
		when "writeout"
			ren.writeOut
		else
			ren.execute(cmd)
			puts ren.mResult
	end
end

puts "Bye!"
