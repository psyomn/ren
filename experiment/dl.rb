
require 'open-uri'

uri = URI.parse("http://xenagoras.net/iv/imminent_violence-imminent_violence.ogg")

File.open("test", "w").write(open(uri).read)
  
