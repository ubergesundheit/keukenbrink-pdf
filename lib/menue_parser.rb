require "date"

class MenueParser

  DAYNAMES_METHODS = {
    montag: :monday?,
    dienstag: :tuesday?,
    mittwoch: :wednesday?,
    donnerstag: :thursday?,
    freitag: :friday?
  }

  def self.parse(raw_text)
    str = raw_text.gsub!("\n", " ").squeeze!(" ")

    days = {}
    words = str.split " "
    # I think first and second items will always be "Menüplan" and "vom"
    # leaving the dates in the indexes 2 and 4
    end_date_str = words[4]
    start_date_str = "#{words[2]}#{end_date_str.split(".").last}"
    start_date = Date.parse(start_date_str)
    end_date = Date.parse(end_date_str)
    date_range = (start_date..end_date)

    # helper vars
    curr_day = ""
    curr_menu_start_index = nil
    curr_price = nil

    words.each_with_index do |word, index|
      case word
      when /(\w{2,7}tag|Mittwoch|Vegetarisch):/, "Snack" # start the day, veg and snack of the week
        if word != "Snack"
          curr_day = word.downcase.chop.to_sym
          curr_menu_start_index = index + 1
        elsif word == "Snack" and words[index + 2] == "Woche:"
          curr_day = "snack_der_woche".to_sym
          curr_menu_start_index = index + 3
        end
      when "€" # end a day
        curr_price = words[index - 1]
        curr_menu_end_index = index - 2
        curr_menu_end_index = index - 3 if (words[index - 2] =~ /\d/) != nil # remove the additives

        curr_day_hash = {
          dish: words[curr_menu_start_index..curr_menu_end_index].join(" "),
          price: curr_price
        }

        # add the date only for regular dishes
        if curr_day != :snack_der_woche
          if curr_day == :vegetarisch
            date = days[days.keys.last][:date]
          else
            # find the day in the date range by calling the daynames? method on them
            date = date_range.find { |d| d.send(DAYNAMES_METHODS[curr_day])}
          end
          curr_day_hash[:date] = date
        end
        days[curr_day] = curr_day_hash
      end
    end
    days
  end

end
