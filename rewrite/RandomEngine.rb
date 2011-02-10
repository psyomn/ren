class RandomEngine 
	attr_accessor :mNames, :mSurnames, :mWords

	# Load all the needed files for randomization
	def initialize
		# Load names
		print "Loading Names ... [BUSY]"
		@mNames = (File.open("dat/name.dat.txt").read.capitalize).split(/\n/)
		print "\b\b\b\b\b\b[DONE]\n"
		# Load surnames
		print "Loading Surnames ... [BUSY]"
		@mSurnames = (File.open("dat/surnames.dat.txt").read.capitalize).split(/\n/)
		print "\b\b\b\b\b\b[DONE]\n"
		# Load words
		print "Loading Names ... [BUSY]"
		@mSurnames = (File.open("dat/words.dat.txt").read.capitalize).split(/\n/)
		print "\b\b\b\b\b\b[DONE]\n"

	end

	def todo
	end
end
