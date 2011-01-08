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

=end

# Pre-script execution checks
if ARGV.empty? then exit end

require 'net/http'
require 'zlib'
require 'open-uri'

# These are local files
prefix = "dat/"
file_names    = "name.dat.txt"
file_surnames = "surnames.dat.txt"
file_roads    = "roads.dat.txt"
file_words    = "words.dat.txt"

# These are obtainable foreign files
http_names    = ""
http_surnames = ""
http_roads    = ""
http_words    = "http://www.mieliestronk.com/corncob_lowercase.zip"

def fetch(num)
  case num
    when 0 

    when 1
    when 2
    when 3
      @uri = http_words
      @src = open(uri)
      @gzp = ZLib::GzipReader.new(@src)
      @res = @gzp.read
  end
end

# If the user needs help...
if ARGV[0].downcase == "help"
  puts "Command format: "
  puts "  ruberate NUM delim1 delim2 [name|surname|id|address|age|post]*"
  exit
end

if !File.exists?(prefix + file_names)    then 
  puts "The #{file_names} could not be found. Should I fetch it? [Y/n] "
  c=gets 
  if c=='y'
    fetch(0) 
  end 
end
if !File.exists?(prefix + file_surnames) then puts "The #{file_surnames} could not be found. Should I fetch it? [Y/n]"; c=gets if c=='y' then fetch(1) end end
if !File.exists?(prefix + file_roads)    then puts "The #{file_roads} could not be found. Should I fetch it? [Y/n]";    c=gets if c=='y' then fetch(2) end end
if !File.exists?(prefix + file_words)    then puts "The #{file_words} could not be found. Should I fetch it? [Y/n]";    c=gets if c=='y' then fetch(3) end end

fnames    = File.open("#{prefix}name.dat.txt", "r") 
fsurnames = File.open("#{prefix}surnames.dat.txt", "r")
froads    = File.open("#{prefix}roads.dat.txt", "r")   
words     = File.open("#{prefix}words.dat.txt", "r")
id = Array.new


# We just put these here because we don't want to load the files if the arguments are entered wrong

names    =    fnames.readlines if ARGV.include?("name")    # Here for optimization
surnames = fsurnames.readlines if ARGV.include?("surname") # Here for optimization
roads    =    froads.readlines if ARGV.include?("address") # Here for optimization

# Normalization of data here. We remove the newlines, and make sure that each
# name is capitalized properly.

names.each_index    { |x| names[x]    = names[x].gsub("\n", "").capitalize  }   if ARGV.include?("name")
surnames.each_index { |x| surnames[x] = surnames[x].gsub("\n", "").capitalize } if ARGV.include?("surname")
roads.each_index    { |x| roads[x]    = roads[x].gsub("\n", "") }               if ARGV.include?("address")

# Now just an extra rule for the delimiters...

if ARGV[1] == "NEWLINE" then ARGV[1] = "\n" end
if ARGV[2] == "NEWLINE" then ARGV[2] = "\n" end

# all the options here

ARGV[0].to_i.times {

  ARGV.each_index { |x| 
  
  if x > 2 then 
    if ARGV[x] == "id"
      print rand(8000000) + 1000000
    elsif ARGV[x] == "surname"
      print surnames[rand(surnames.size)]
    elsif ARGV[x] == "address"
      print roads[rand(roads.size)]
    elsif ARGV[x] == "name"
      print names[rand(names.size)]
    elsif ARGV[x] == "post"
      print (65 + rand(25)).chr , rand(9) , (65 + rand(25)).chr , rand(9) , (65 + rand(25)).chr , rand(9)
    elsif ARGV[x] == "age"
      print rand(40) + 14
    elsif ARGV[x] == "phone"
      print (100+rand(899)), "-", "%04d" % rand(9999)
    end # end the token/argv checking
    
    if x < ARGV.length - 1 then print ARGV[1] end # Print the delimiter to separate the fields
  
  end # end checking if these are not delimiters or amount to generate...
  }
  
  print ARGV[2] # Print the delimiter to separate the rows

}
