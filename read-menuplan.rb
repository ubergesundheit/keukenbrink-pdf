#!/usr/bin/env ruby

require "pry"
require "date"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# extract current pdf url
url = "http://keukenbrink.de/images/menueplaene/Menueplan#{Date.today.cweek.to_s.rjust(2,'0')}-KW-15.pdf"

# get pdf text
raw_text = `./pdf2textfromurl.sh #{url}`


binding.pry
if raw_text.start_with? 'wget error'
  # error with dl
else if raw_text.start_with? 'Syntax Warning: May not be a PDF file (continuing anyway)'
  # error with pdftotext
else
  # from here, everything seems ok
end
