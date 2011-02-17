# Author:: Simon Symeonidis (mailto:psyomn@xenagoras.net)
# License:: GPL v3
# Class for handling loading and randomization

require_relative 'LonelyExceptions.rb'
 
class RandomEngine < LonelyExceptions
	
	attr_accessor :mNames 
	attr_accessor :mSurnames 
	attr_accessor :mWords 
	attr_accessor :mResult 
	attr_accessor :mCommand
	attr_accessor :mDelim1
	attr_accessor :mDelim2
	attr_accessor :mIterations

	attr_reader :mMaleNameLocation
	attr_reader :mFemaleNameLocation
	attr_reader :mDictionaryLocation

	# Load all the needed files for randomization
	def initialize
		# Load names
		print "Loading Names    ... [BUSY]"
		@mNames = (File.open("dat/name.dat.txt").read.capitalize).split(/\n/)
		print "\b\b\b\b\b\b[DONE]\n"
		# Load surnames
		print "Loading Surnames ... [BUSY]"
		@mSurnames = (File.open("dat/surnames.dat.txt").read.capitalize).split(/\n/)
		print "\b\b\b\b\b\b[DONE]\n"
		# Load words
		print "Loading Words    ... [BUSY]"
		@mWords = (File.open("dat/words.dat.txt").read.capitalize).split(/\r\n/)
		print "\b\b\b\b\b\b[DONE]\n"
		@mDelim1 = " "
		@mDelim2 = "\n"

		# Strictly here in order to have the urls to locate the files
		@mMaleNameLocation   = ""
		@nFemaleNameLocation = ""
		@mDictionaryLocation = ""

		@mResult = ""
		@mCommand = ""

		@mIterations = 1
	end
	
	# This definition generates the needed information
	#  o Some commands that might be worth implementing: 
 	#    o dateo      : oracle date input 
 	#    o Space      : a command to create a blank space
 	#    o null       : for null tokens
 	#    
 	#    !!High Priority!!
 	#    o TIMES      : This will be a command that preparses the given commands automatically
 	#                   The user can say for example 5TIMES list=g,c,t,a and that would make
 	#                 the script preparse the command to list=g,c,t,a list=g,c,t,a list= ...
	#
 	#                     This might take some time, but we'll see when I implement it.
 	#    o id         : must be a unique id (this might be a little silly. We'll see)
  	#  DONE 
 	#    o time       : mysql like time
 	#    o date       : mysql date input
 	#    o alpha      : return random a-z character 
 	#    o ALPHA      : return random A-Z character
 	#    o num        : return random number 0->9
 	#    o man        : return a letter (simple, but needed) (or a whole word)
 	#    o Back       : option to print backspace in order to merge values...
	#
 	#                     use is back (eg: id back back back id)
	#
 	#    o range      : for an int range. This should have possibilities of specifying
 	#                   one number x so it's 0 -> x, and two for x -> y
 	#                  (so this could handle years for example, or salaries)
 	#                  
 	#                   use is  20range20 nodelim 30range50 -100range100
	#
 	#    o list       : for a list of values you might only want (eg F/M etc, eg A,B,C,...)
 	#    o nodelim    : Special rule for when you want to stick two things together
 	#                   for example year generation could be of the form
 	# for special cases as times
	def execute(val)
		@mResult = ""
		commandParser(val)

		addressArr = ["Ave.","St.","Way","Cir","Dr","Rd","Ct","Trl","Blvd"]
		@mIterations.times {		
			@mCommand.split.each{ |option|

				nodelim = false
				
				case option
					when "id" # TODO
						# ...
					when "rid" # TODO 
						# ...
					when "surname" 
						@mResult += @mSurnames.sample
					when "address" 
						@mResult += @mWords.sample.capitalize + " " + @mWords.sample.capitalize + " " + addressArr.sample
					when "name" 
						@mResult += @mNames.sample.capitalize
					when "post"
						@mResult += (65 + rand(26)).chr + rand(9).to_s + (65 + rand(26)).chr + rand(9).to_s + (65 + rand(26)).chr + rand(9).to_s
					when "age"
						@mResult += (rand(40) + 14).to_s
					when "phone"
						@mResult += (100+rand(899)).to_s + "-" + ("%04d" % rand(9999))
					when "alpha"
						@mResult += (97 + rand(26)).chr
					when "ALPHA"
						@mResult += (65 + rand(26)).chr
					when "num"
						@mResult += (rand(10)).to_s # 0 -> 9
					when "date"
						month = rand(12) + 1
						t = Time.utc(1970+rand(500), month, 1+rand(31), 1+rand(23),rand(60),rand(60)) 
						@mResult += t.year.to_s + "-" + "%02d" % t.mon + "-" + "%02d" % t.day
					when "time"
						t = Time.utc(1970+rand(500), month, 1+rand(31), 1+rand(23),rand(60),rand(60)) 
						@mResult += t.hour.to_s + ":" +  t.min.to_s + ":" +  t.sec.to_s
					when "space" # TODO
						@mResult += "  " 
						nodelim = true
					when "null"  # TODO
						#@mResult += $delim2 
					when /word/
						(option.to_i == 0 ? 1 : option_to_i).times{ @mResult += @mWords.sample }
					when /range/ # TODO 
						# expression = rangeHash[ARGV[x]] 
						# exp = expression.split('X')
						# @mResult += (rand(exp[1].to_i + 1) + exp[0].to_i).to_s
					when /list/
						l = option 
						l = l.gsub(/list/, '')
						l = l.gsub(/=/, '')
						la= l.split(',')
						@mResult += la.sample
					when /man/
						l = option
						l = l.gsub(/man/, '')
						l = l.gsub(/=/, '')
						@mResult += l
					when "back"
						2.times { @mResult.chop! }
					when "nodelim"
						nodelim = true
				end # end the big case!
	
				@mResult += @mDelim1 
				
				if nodelim
					# chop the delim1
					(@mDelim1.length + 1).times{ @mResult.chop! }
				end
			} # end per field

			# need to chop the extra delim1
			(@mDelim1.length).times{ @mResult.chop! }
			@mResult += @mDelim2

		} # end per row
	end

	# Make sure to clear the results
	def clearResult
		@mResult.clear
	end

	# Simple definition to write out the results
	def writeOut
		File.open("out", "w").write(@mResult)
	end

private

	# Preprosses the command to see if special tokens such as 'times' exists
	def commandParser(cm)
		@mCommand = ""
		cm = cm.split	
	
		raise Exception, "Command has no options" if cm.size == 0
		cm[0] = cm[0].to_i
		raise Exception, "First number must be positive integer" if cm[0] < 1 and cm[0].is_a? Integer

		@mIterations = cm[0]

		cm.delete_at(0)

		cm.each_index{ |token_index|
			if cm[token_index] =~ /times/
				if cm.size > token_index+1
					(cm[token_index].to_i - 1).times{ 
						@mCommand += cm[token_index+1] + " "
					}
				end
			else
				@mCommand += cm[token_index].to_s + " "
			end
		}
	end

	# Definition to download files
	def downloadFile
	end

end
