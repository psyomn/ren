# Author:: Simon Symeonidis (mailto:psyomn@xenagoras.net)
# License:: GPL v3
# Class for handling loading and randomization

require 'open-uri'
 
class RandomEngine  
  
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

public
  # Load all the needed files for randomization
  def initialize
    check
    
    # Load names
    print "Loading Names    ... [BUSY]"
    @mNames = (File.open("dat/name.dat.txt").read).split(/\n/)
    print "\b\b\b\b\b\b[DONE]\n"
    # Load surnames
    print "Loading Surnames ... [BUSY]"
    @mSurnames = (File.open("dat/surnames.dat.txt").read).split(/\n/)
    print "\b\b\b\b\b\b[DONE]\n"
    # Load words
    print "Loading Words    ... [BUSY]"
    @mWords = (File.open("dat/words.dat.txt").read).split(/\r\n/)
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
    id = 0
    rid = Hash.new
    commandParser(val)

    addressArr = ["Ave.","St.","Way","Cir","Dr","Rd","Ct","Trl","Blvd"]
    @mIterations.times {    
      @mCommand.split.each{ |option|

        nodelim = false
        
        case option
          when "id" # TODO
            @mResult += id.to_s
          when "rid" # This method might be a bit slow. Recheck in the future. 
            tmp = 0
            while rid[tmp] != true do
              tmp = rand(4000000000) # Assuming that rid is a standard int
              rid[tmp] = true
            end
            @mResult += tmp.to_s
          when "surname" 
            @mResult += @mSurnames.sample
          when "address" 
            @mResult += @mWords.sample.capitalize + " " + @mWords.sample.capitalize + " " + addressArr.sample
          when "name" 
            @mResult += @mNames.sample
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
            @mResult += @mDelim2 
          when /word/
            (option.to_i == 0 ? 1 : option_to_i).times{ @mResult += @mWords.sample }
          when /range/ # TODO 
            # We calculate the offset
            exp = option.split(/range/i)
            exp[0] = exp[0].to_i
            exp[1] = exp[1].to_i
            x = [exp[0], exp[1]].max + 1
            y = [exp[0], exp[1]].min - 1
            @mResult += (rand(x-y)+y).to_s
          when /list/
            @mResult += option.gsub(/list/, '').gsub(/=/, '').split(',').sample
          when /man/
            @mResult += option.gsub(/man/, '').gsub(/=/, '')
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
      @mDelim1.length.times{ @mResult.chop! }
      @mResult += @mDelim2

    } # end per row
  end

  # Make sure to clear the results
  def clearResult
    @mResult.clear
  end

  # Simple definition to write out the results
  def writeOut(fname="out")
    File.open(fname, "w").write(@mResult)
  end

  # This method provides a command-line interface to the class
  def commandInterface
    isfinished = false
    cmd = "" # command placeholder

    while !isfinished do
      print "ren::"
      cmd = $stdin.gets.chomp!
      case cmd 
        when /end|quit|exit/ then isfinished = true
        when "setdelim1"
          print "Set delim 1: " # TODO Handle Newline 
          @mDelim1 = $stdin.gets.chomp!
        when "setdelim2"
          print "Set delim 2: " # TODO Handle Newline
          @mDelim2 = $stdin.gets.chomp!
        when "writeout"
          print "Filename : "
          filename = $stdin.gets.chomp!
          writeOut(filename)
        else
          execute(cmd)
          puts @mResult
      end
    end
  end

private

  # Preprosses the command to see if special tokens such as 'times' exists
  # IF 'helps' is found, displays message and exits (which is handled by 
  # the private method helps).
  # It also takes care of square brackets [ ] when used with 'times' 
  #   Example : 10times [ name surname address ] 2times [ word ]
  #   Example : 10times [ 10 times [ token ] token token ] 
  def commandParser(cm)
    @mCommand = ""
    cm = cm.split
    continue_def = true

    if cm.include? "help"
      helps
      continue_def = false
    end
  
    if !parCheck(cm.join) then continue_def = false end

    if continue_def
      raise Exception, "Command has no options" if cm.size == 0
      cm[0] = cm[0].to_i
      raise Exception, "First number must be positive integer" if cm[0] < 1 or !cm[0].is_a? Integer
  
      @mIterations = cm[0]
  
      cm.delete_at(0)

      # This needs a rewrite . . . 
  
      cm.each_index{ |token_index|
        if cm[token_index] =~ /times/
          if cm.size > token_index+1
            ( cm[token_index].to_i - 1 ).times { 
              @mCommand += cm[token_index+1] + " "
            }
          end
        else
          @mCommand += cm[token_index].to_s + " "
        end
      }
    else
      puts "You misinserted the number of brackets"
    end
  end

  # Returns true or false whether there are the right amount of parenthesis
  # in the command.
  def parCheck(cm)
    counts = 0
    countr = 0
    countc = 0

    cm.chars{ |x|
      case x
        when '[' then counts += 1 
        when ']' then counts -= 1
        when ')' then countr += 1
        when '(' then countr -= 1
        when '{' then countc += 1
        when '}' then countc -= 1
      end
    }
    return counts == 0 && countr == 0 && countc == 0
  end

  # Simple definition to print out possible arguments. This separates 
  # the 'dull' code :P.
  def helps
    puts "id - unique incrementing number"
    puts "rid - unique random interger"
    puts "surname - surname from the list"
    puts "name - name from the list"
    puts "post - montreal like post code"
    puts "age - age from 14 to 54"
    puts "phone - random phone XXX-XXXX"
    puts "alpha - random lowercase character"
    puts "ALPHA - random uppercase character"
    puts "num - random numner 0->9"
    puts "date - random date"
    puts "time - random time"
    puts "space - [unstable] adds a space"
    puts "null - [unstable] adds null token"
    puts "word - random word from list"
    puts "range - random range from x to y. Use like this: 12range40"
    puts "list - random selection from a list. Use like this: list=a,v,word,1,4"
    puts "man - manual entry. Use like this: man=1234"
    puts "back - a backspace. Use with words"
    puts "nodelim - no delimiter to join two options"
    puts "times - an option x times eg: 10times man=1234"
    puts "  Command Format: "
    puts "    10 10times man=1234 name surname"
  end

  # Check if files exist.
  # 1) check if folder dat exists
  # 2) check if the other files exist
  #     - name.dat.txt
  #    - surname.dat.txt
  #    - words.dat.txt
  def check
    if !File.directory? "dat" then FileUtils.mkdir 'dat' end
    if !File.exists? "dat/name.dat.txt"     then download('names') end
    if !File.exists? "dat/surnames.dat.txt" then download('surnames') end
    if !File.exists? "dat/words.dat.txt"    then download('words') end
  end

  # Definition to download files. This handles fetching of the data files
  # if they are missing. 
  # - Names are two files, one for males, one for females. They are downloaded
  #   separately and merged
  # - The rest is normal. 
  #
  # In the future it would be best to create a class with configurations where
  # all the filenames are stored and altered from there.
  def download(f)
    result = ""
    prefix = "dat/"
    file_names    = "name.dat.txt"
    file_surna    = "surnames.dat.txt" 
    file_words    = "words.dat.txt"
    http_names_m  = "http://www.census.gov/genealogy/names/dist.male.first"
    http_names_f  = "http://www.census.gov/genealogy/names/dist.female.first"
    http_surnames = "http://www.census.gov/genealogy/names/dist.all.last"
    http_words    = "http://www.mieliestronk.com/corncob_lowercase.zip"

    case f
      when 'names'
        print "Downloading names    ... [BUSY]"
        nm_uri = URI.parse(http_names_m)
        nf_uri = URI.parse(http_names_f)
        (open(nm_uri).read + open(nf_uri).read).each_line {|m|
          result += m.split(/\s+/)[0].capitalize + "\n"
        }
        File.open(prefix + file_names, "w").write( result )
        print "\b\b\b\b\b\b[DONE]\n"
      when 'surnames'
        print "Downloading surnames ... [BUSY]"
        sr_uri = URI.parse(http_surnames)
        (open(sr_uri).read).each_line {|m|
          result += m.split(/\s+/)[0].capitalize + "\n"
        }
        File.open(prefix + file_surna, "w").write ( result )
        print "\b\b\b\b\b\b[DONE]\n"
      when 'words'
        print "Downloading words    ... [BUSY]"
        wr_uri = URI.parse(http_words)
        # Store the zipfile
        File.open(prefix + file_words, "w").write(wr_uri.read)
        unzip(prefix + file_words)
        print "\b\b\b\b\b\b[DONE]\n"
    end
  end

  # Definition to unzip zippped files. This might be needed
  # with files which are downloaded but zipped.
  # This might not be the best way to go about things since
  # this is basically passing the problem to the shell. 
  # I would implement this with some gem or something, but I 
  # read around and found out that the ones available are not
  # good at handling zip files.
  def unzip(filelocation)
    `unzip #{filelocation}`
    `mv corncob_lowercase.txt dat/`
    `rm #{filelocation}`
    `mv dat/corncob_lowercase.txt #{filelocation}`
  end

end
