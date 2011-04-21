Solonely!
===============================
This is a script that is supposed to spout out need information in order 
to populate a database en mass.
Currently it does not handle uniqueness in certain fields (for example you 
might have a case where someone has the same phone number).

It is intended to work with MySql, but in the future the script
might take care of a number of databases.

How to begin generation
-------------------------------
Make sure that you have a dat/ fodler in the main directory solonely/ 
That is: solonely/dat/
The script should take care of directory creation if no dat/ is found.

Currently the script needs to use wget in order to grab some files from
the internet. In the future though this will be replaced by something
from the Ruby platform which will make execution from different OSs
more cross platform. Bear with me for the momment!

To insert loads of data to your database, you will need to do two
things:

	1) Random Data Generation
	-------------------------------
	./nm.rb 100 ' ' NEWLINE name surname word
	
	That will make sure to download all three files in order to generate
	the random data.
	
	For a full list of values you can specify, type
	
	./nm.rb help
	
	When you are satisfied with your output, store it somewhere
	
	./nm.rb [ ... ... ] > out
	
	(This will be fixed in the future, so it's more platform independant)
	
	2) Quick DB population
	-------------------------------
	./pop.rb
	
	Enter all the credentials and follow the steps. You should be good to go.
	
	Also, if you wish, you can run the following:
	
	./pop.rb d
	
	Which triggers the debug mode and stores the sql queries in a separate
	file called log.sql.
	
