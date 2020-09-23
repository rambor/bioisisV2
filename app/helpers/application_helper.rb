module ApplicationHelper
  include Pagy::Frontend

  def nice_date(date)
    h date.strftime("%d %B %Y")
  end

  def total_downloads(user_id)
    downloads = ScatterDownload.where(user_id: user_id)
    count = downloads.size
  end

  def nice_date_time(date)
    h date.strftime("%A %d %B %Y - %H:%M %p")
  end

  def truncate_words(text, length = 11, end_string = ' ...')
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end

end
