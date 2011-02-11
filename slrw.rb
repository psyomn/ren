require_relative 'RandomEngine.rb'

$VERSION = 1;

finished = false

dobj = RandomEngine.new
dobj.mDelim1 = 'x'
cmd  = ""

while !finished do
	cmd = $stdin.gets
	cmd.chomp!

	if cmd !~ /end|quit|exit/i 
		dobj.execute(cmd)
		puts dobj.mCommand
		puts dobj.mResult
	else
		finished = true
	end
end
