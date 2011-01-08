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
require 'open-uri'

# These are local files
prefix = "dat/"
file_names    = "name.dat.txt"
$file_names   = "name.dat.txt"
file_surnames = "surnames.dat.txt"
$file_surnames= "surnames.dat.txt"
file_roads    = "roads.dat.txt"
file_words    = "words.dat.txt"

# These are obtainable foreign files
$http_names_m  = "http://www.census.gov/genealogy/names/dist.male.first"
$http_names_f  = "http://www.census.gov/genealogy/names/dist.female.first"
$http_surnames = "http://www.census.gov/genealogy/names/dist.all.last"
$http_roads    = ""
$http_words    = "http://www.mieliestronk.com/corncob_lowercase.zip"

# XXX XXX XXX XXX NEED TO CHANGE ALL GLOBARL VARST TO GLOBAL!

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
      print "\b\b\b\b\b\b[DONE]\n"
  end
end

# If the user needs help...
if ARGV[0].downcase == "help"
  puts "Command format: "
  puts "  ruberate NUM delim1 delim2 [name|surname|id|address|age|post]*"
  exit
end

if !File.exists?(prefix + file_names)
  print "The #{file_names} could not be found. Should I fetch it? [Y/n] : "
  c=$stdin.gets.chomp
  if c=='y'
    fetch(0) 
  end 
end

if !File.exists?(prefix + file_surnames) 
  print "The #{file_surnames} could not be found. Should I fetch it? [Y/n] : " 
  c=$stdin.gets.chomp
  if c=='y'
    fetch(1) 
  end 
end

if !File.exists?(prefix + file_words) 
  print "The #{file_words} could not be found. Should I fetch it? [Y/n] : "
  c=$stdin.gets.chomp 
  if c=='y'
    fetch(2) 
  end 
end

fnames    = File.open("#{prefix}name.dat.txt", "r") 
fsurnames = File.open("#{prefix}surnames.dat.txt", "r")
fwords    = File.open("#{prefix}words.dat.txt", "r") # lol, fwords
id = Array.new # TODO might have to go

# We just put these here because we don't want to load the files if the arguments are entered wrong

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

# all the options here

ARGV[0].to_i.times {

  ARGV.each_index { |x| 
  
  if x > 2 then 
    if ARGV[x] == "id"
      print rand(8000000) + 1000000
    elsif ARGV[x] == "surname"
      print surnames[rand(surnames.size)]
    elsif ARGV[x] == "address"
      print words[rand(words.size)].capitalize, " ", words[rand(words.size)].capitalize, " "
      if rand(2) == 0
        print "Ave."
      else
        print "St."
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
    end 
    
    if x < ARGV.length - 1 then print ARGV[1] end # Print the delimiter to separate the fields
  
  end # end checking if these are not delimiters or amount to generate...
  }
  
  print ARGV[2] # Print the delimiter to separate the rows

}
