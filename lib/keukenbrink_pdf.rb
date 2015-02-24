require "./lib/menue_parser.rb"
require "json"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class KeukenbrinkPdf

  def self.call(env)
    [200, {"Content-Type"=>"text/plain; charset=utf-8", "Access-Control-Allow-Origin"=>"*"}, self.route(env)] #StringIO.new(self.get_menue.to_s)
  end

  @cache = { this_week: "cache empty", next_week: "cache empty" }

  def self.route(env)
    request_path = env["REQUEST_PATH"]
    menue = self.get_menue

    case request_path
    when /diese_woche/
      StringIO.new(menue[:this_week].to_json)
    when /naechste_woche/
      StringIO.new(menue[:next_week].to_json)
    when /snack_der_woche/
      StringIO.new(menue[:this_week][:snack_der_woche].to_json)
    when /heute/
      StringIO.new(menue[:this_week].select { |d,day| day.has_key?(:date) and day[:date] == Date.today}.to_json)
    when /((m|d|f)(o|r|i)(n|e)(n)?(e|s|i)?(rs)?(tag)|mittwoch|vegetarisch)/
      StringIO.new(menue[:this_week][$1.to_sym].to_json)
    else
      StringIO.new(menue[:this_week].select { |d,day| day.has_key?(:date) and day[:date] == Date.today}.to_json)
    end
    #  #get_menue.to_s
  end

  def self.fetch_and_parse_pdf_url(url)
    raw_text = `./pdf2textfromurl.sh #{url}`
    if raw_text.start_with? 'wget error' or raw_text.start_with? 'Syntax Warning: May not be a PDF file (continuing anyway)'
      "#{raw_text.lines.first}\n#{url}"
    else
      MenueParser::parse raw_text
    end
  end


  def self.get_menue
    # determine if cache needs refresh
    today = Date.today
    today_cweek = today.strftime('%0V-KW-%g')

    if @cache[:this_week] == 'cache empty' or @cache[:cweek] != nil and @cache[:cweek] != today_cweek
      # compute current pdf url
      url = "http://keukenbrink.de/images/menueplaene/Menueplan#{today_cweek}.pdf"
      # get pdf text
      @cache[:this_week] = self.fetch_and_parse_pdf_url(url)
      @cache[:cweek] = today_cweek

      # Also try next week..
      next_week_cweek = today.next_day(7).strftime('%0V-KW-%g')
      url = "http://keukenbrink.de/images/menueplaene/Menueplan#{next_week_cweek}.pdf"
      @cache[:next_week] = self.fetch_and_parse_pdf_url(url)
    end
    @cache
  end

end
