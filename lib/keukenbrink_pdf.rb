require "json"
require "date"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class KeukenbrinkPdf

  def self.call(env)
    [200, {"Content-Type"=>"text/plain; charset=utf-8", "Access-Control-Allow-Origin"=>"*"}, StringIO.new(self.get_menue)]
  end

  @cache = { menue: "cache empty" }

  def self.get_menue
    # determine if cache needs refresh
    today_cweek = Date.today.cweek.to_s.rjust(2,'0')
    

    if @cache[:menue] == 'cache empty' or @cache[:cweek] != nil and @cache[:cweek] != today_cweek
      # compute current pdf url
      url = "http://keukenbrink.de/images/menueplaene/Menueplan#{today_cweek}-KW-15.pdf"

      # get pdf text
      raw_text = `./pdf2textfromurl.sh #{url}`
      if raw_text.start_with? 'wget error' or raw_text.start_with? 'Syntax Warning: May not be a PDF file (continuing anyway)'
        @cache[:menue] = "#{raw_text.lines.first}\n#{url}"
      else
        @cache[:menue] = transform_plan raw_text
      end
      @cache[:cweek] = today_cweek
    end
    @cache[:menue]
  end

  def self.transform_plan(raw_text)
    raw_text.strip.squeeze(" ")
  end


end
