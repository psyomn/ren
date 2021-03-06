# Author:: Simon Symeonidis (mailto:psyomn@xenagoras.net)
# License:: GPL v3
# The strict purpose of this class is to read different output files with delimited information
# and generate other such files. 
# The user is expected to handle much of this on his or her own.
#
# Format should be something like filename1:1,2 filename2:9,3,2 
# so the mingler simply needs to visit the files and get the required columns
# and finally generate an output file as well.

class Mingler
public

	# A command line interface to the class
	def commandInterface
		isfinished = false
		cmd = "" 

		while !isfinished do
			print "min::"
			cmd = $stdin.gets.chomp!
			case cmd
				when /end|exit|quit/i then isfinished = true 
			end
		end
	end
private
	
protected
end
