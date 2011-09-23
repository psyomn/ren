Ren 
===============================
This is a script that is supposed to spout out need information in order 
to populate a database en mass.
Currently it does not handle uniqueness in certain fields (for example you 
might have a case where someone has the same phone number).

It is intended to work with MySql, but in the future the script
might take care of a number of databases.

How to begin generation
-------------------------------
run slrw.rb 

Once you have donwloaded and loaded the files, type

sol::random 

Then enter the parameters. 

If you want to save the last generated output,
write 

ren::writeout

and enter the filename you want. 
