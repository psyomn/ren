#!/usr/bin/ruby

=begin
  author:  Simon Symeonidis
  contact: lethaljellybean@gmail.com
  contact: psyomn@xenagoras.net

  This is a simple script to generate information to populate our database.
 
  This script aims to be flexible, versatile and reusable. We'll see how
  that goes :)

  You call the script with these arguments:

  ruberate 200 <delim1> <delim2>  n s id 

  <delim1> is the delimiter between fields (Name#Surname#...)
  <delim2> is the delimiter between each row of data

  **
   note delimiter for cells is #
   delimiter for rows is \n

   TODO
   Some commands that might be worth implementing:
     o Shell   : in the future, see how much time it would take in order to turn
                 this program into something which acts more like a shell...
   DONE 
     o Back    : option to print backspace in order to merge values...
     o range   : for an int range. This should have possibilities of specifying
                 one number x so it's 0 -> x, and two for x -> y
	         (so this could handle years for example, or salaries)
     o list    : for a list of values you might only want (eg F/M etc, eg A,B,C,...)
     o nodelim : Special rule for when you want to stick two things together
                 for example year generation could be of the form
		     
		     20range20 nodelim 30range50
=end

# Pre-script execution check
# If nothing specified, stab user in the face, multiple times.
if ARGV.empty? then exit end

##
## Start important variables
##

# This hash is used in order to handle "RANGE" requests.
rangeHash      = Hash.new # initiate hash
rangeHashID    = 0        # the hashid to look for later

# These are local files
prefix = "dat/"
$file_names     = "name.dat.txt"
$file_surnames  = "surnames.dat.txt"
$file_words     = "words.dat.txt"

# These are obtainable foreign files
$http_names_m  = "http://www.census.gov/genealogy/names/dist.male.first"
$http_names_f  = "http://www.census.gov/genealogy/names/dist.female.first"
$http_surnames = "http://www.census.gov/genealogy/names/dist.all.last"
$http_words    = "http://www.mieliestronk.com/corncob_lowercase.zip"

# Where the final result will be stored
$final_result = ""

##
## End Important Variables
##

def fetch(num)
  case num
    when 0 
      print "Fetching names: [BUSY]"
      `wget --quiet -O ./dat/males #{$http_names_m}`
      `wget --quiet -O ./dat/femal #{$http_names_f}`
      `cd dat && ( cat males && cat femal ) | awk '{print $1}' > #{$file_names}`
      `cd dat && rm males femal`
      print "\b\b\b\b\b\b[DONE]\n"
    when 1
      print "FetchingLnames: [BUSY]"
      `wget --quiet -O ./dat/last #{$http_surnames}`
      `cd dat && cat last | awk '{print $1}' > #{$file_surnames}`
      `rm ./dat/last`
      print "\b\b\b\b\b\b[DONE]\n"
    when 2 #download corncob
      print "Fetching words: [BUSY]"
      `wget --quiet -O ./dat/cc.zip #{$http_words}`
      `cd dat && unzip cc.zip`
      `cd dat && iconv -f utf8 -t ascii corncob_lowercase.txt > words.dat.txt`
      `rm ./dat/cc.zip`
      `rm ./dat/corncob_lowercase.txt`
      print "\b\b\b\b\b\b[DONE]\n"
  end
end

# If the user needs help...
if ARGV[0].downcase == "help"
  puts "Command format: "
  puts "  ruberate NUM delim1 delim2 [name|surname|id|address|age|post]*"
  exit
end

if !File.exists?(prefix + $file_names)
  print "The #{$file_names} could not be found. Should I fetch it? [Y/n] : "
  c=$stdin.gets.chomp
  if c=='y'
    fetch(0) 
  end 
end

if !File.exists?(prefix + $file_surnames) 
  print "The #{$file_surnames} could not be found. Should I fetch it? [Y/n] : " 
  c=$stdin.gets.chomp
  if c=='y'
    fetch(1) 
  end 
end

if !File.exists?(prefix + $file_words) 
  print "The #{$file_words} could not be found. Should I fetch it? [Y/n] : "
  c=$stdin.gets.chomp 
  if c=='y'
    fetch(2) 
  end 
end

##
## Most initialization has been done, and from this point onwards, we
## start executing the real stuff. (read files, generate stuff etc)
##

fnames    = File.open("#{prefix}#{$file_names}", "r") 
fsurnames = File.open("#{prefix}#{$file_surnames}", "r")
fwords    = File.open("#{prefix}#{$file_words}", "r") # lol, fwords
id = Array.new # TODO might have to go

# We just put these here because we don't want to load the files if the arguments are entered wrong
# TODO Should I ever choose to optimize this, then it would be a wise idea to read the file in chunks
#      rather than in lines...
names    =    fnames.readlines if ARGV.include?("name")    # Here for optimization
surnames = fsurnames.readlines if ARGV.include?("surname") # Here for optimization
words    =    fwords.readlines if ARGV.include?("address") or ARGV.grep /word/

# Normalization of data here. We remove the newlines, and make sure that each
# name is capitalized properly.

names.each_index    { |x| names[x]    = names[x].gsub("\n", "").capitalize  }   if ARGV.include?("name")
surnames.each_index { |x| surnames[x] = surnames[x].gsub("\n", "").capitalize } if ARGV.include?("surname")
words.each_index    { |x| words[x]    = words[x].gsub("\r\n", "")} if ARGV.grep /word/ or ARGV.include?("address")

# Now just an extra rule for the delimiters...

if ARGV[1] == "NEWLINE" then ARGV[1] = "\n" end
if ARGV[2] == "NEWLINE" then ARGV[2] = "\n" end

# We do one last check for 'range' in order to optimize generation
# later on. We extract the info from the ARGV, and then assign a
# unique ID to the actual values for the range, to the rangeHash.
# Less operations are required this way.

ARGV.each_index { |d|
  if ARGV[d] =~ /range/ 
    r = ARGV[d]
    r = r.split('range')
    
    ARGV[d] = "range" + rangeHashID.to_s
    rangeHashID += 1

    tx = r[0].to_i
    ty = r[1].to_i

    x = [tx, ty].max
    y = [tx, ty].min
    
    rangeHash[ARGV[d]] = y.to_s + "X" + x.to_s # We choose X as a delimiter
  end
}

# all the options here

ARGV[0].to_i.times {

  ARGV.each_index { |x| 
  
  if x > 2 then 
    if ARGV[x] == "id"
      tmpid = (rand(8000000) + 1000000).to_s
      $final_result += tmpid
      print tmpid
    elsif ARGV[x] == "surname"
      print surnames[rand(surnames.size)]
    elsif ARGV[x] == "address"
      print words[rand(words.size)].capitalize, " ", words[rand(words.size)].capitalize, " "
      case rand(9)
        when 0 then print "Ave."
        when 1 then print "St."
        when 2 then print "Way"
	when 3 then print "Cir"
	when 4 then print "Dr"
	when 5 then print "Rd"
	when 6 then print "Ct"
	when 7 then print "Trl"
	when 8 then print "Blvd"
      end
    elsif ARGV[x] == "name"
      print names[rand(names.size)]
    elsif ARGV[x] == "post"
      print (65 + rand(25)).chr , rand(9) , (65 + rand(25)).chr , rand(9) , (65 + rand(25)).chr , rand(9)
    elsif ARGV[x] == "age"
      print rand(40) + 14
    elsif ARGV[x] == "phone"
      print (100+rand(899)), "-", "%04d" % rand(9999)
    elsif ARGV[x] =~ /word/
      w = ARGV[x]
      n = w.to_i
      (n == 0 ? 1 : n).times{ print words[rand(words.length)], " " }
    elsif ARGV[x] =~ /range/
      expression = rangeHash[ARGV[x]] 
      exp = expression.split('X')
      print (exp[0].to_i..exp[1].to_i).to_a.sample
    elsif ARGV[x] =~ /list/
      l = ARGV[x]
      l = l.gsub(/list/, '')
      l = l.gsub(/=/, '')
      la= l.split(',')
      print (la[rand(la.length)])
    elsif ARGV[x] == "back"
      print "\b\b"
    elsif ARGV[x] == "nodelim"
      nodelim = true
    end 
   
    if x < ARGV.length - 1
        print ARGV[1]
	$final_result += ARGV[1]
    end # Print the delimiter to separate the fields
    if nodelim == true
      print "\b\b"
      # There's something wrong with this
      ARGV[1].length.times { $final_result.chop! } 
      nodelim = false
    end
  end # end checking if these are not delimiters or amount to generate...
  }
  
  print ARGV[2] # Print the delimiter to separate the rows
  $final_result += ARGV[2]
}

print "\n\n---- CONTENTS of FINALRESULT ----\n\n", $final_result if ARGV.grep /debug/
print "ARGV[1] size is : #{ARGV[1].length}"if ARGV.grep /debug/
