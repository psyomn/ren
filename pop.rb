#!/usr/bin/ruby

=begin

author : Simon (psyomn) Symeonidis

This script deals with insertions...
          ...all sorts of insertions

ALSO

  This script aims not to provide user friendlyness
  If this is why you are here,
  Go away.

=end

require 'mysql'

dbname = ""
user   = ""
pass   = ""
host   = ""
table  = ""
inputf = ""
delim1 = "" # delimiter for each field
delim2 = "" # delimiter for each row/tuple

if ARGV[0] == 'd'
  puts "*************************************************" 
  puts "* DEBUGGING MODE!" 
  puts "* All the sql queries will be written to log.sql" 
  puts "*************************************************"
  fw = File.new("log.sql", 'w')
end

print "Database Populating tool\n"

puts "You will be prompted to enter certain information "

print "  - username : "
user   = $stdin.gets.chomp
print "  - password : "
pass   = $stdin.gets.chomp
print "  - host     : "
host   = $stdin.gets.chomp

print "  - dbname   : " 
dbname = $stdin.gets.chomp 
print "  - table    : "
table  = $stdin.gets.chomp
print "  - inputfile: "
inputf = $stdin.gets.chomp

puts  "Insert the delimiters in the order you provided them in the previous script"
print "  - delim 1  : "
delim1 = $stdin.gets.chomp
print "  - delim 2  : "
delim2 = $stdin.gets.chomp
print "Enter all the attribute names, separated with hash '#' symbol"
attri  = $stdin.gets.chomp

atArr = attri.split('#')
attri = atArr.join(',') 

##
## This part fetches the info from the file
##

f = File.open(inputf)
contents = f.read
f.close

##
## Split for TUPLES
##

tupArr = contents.split(delim2)

##
## This part handles the actual insertions to the Relations
##

con = Mysql.new(host, user, pass)

con.select_db(dbname)
  tupArr.each { |tup|
    u = ""
    t = tup.split(delim1)
    t.each { |y| u += "'#{y.strip}'," }
    u = u.chop # because we'll have an extra coma
    
    # This line is only printed if user specifies the D_ebugging ARGV
    puts "INSERT INTO #{table} (#{attri}) VALUES (#{u})" if ARGV[0] == 'd'
    
    if ARGV[0] == 'd'
      fw.puts "INSERT INTO #{table} (#{attri}) VALUES (#{u})"
    end
    con.query("INSERT INTO #{table} (#{attri}) VALUES (#{u})")  
  }
con.close
