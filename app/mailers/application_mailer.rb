class ApplicationMailer < ActionMailer::Base
  default from: 'robertprambo@gmail.com'
  layout 'mailer'

  def nice_date(date)
    h date.strftime("%d %B %Y")
  end

  def nice_date_time(date)
    h date.strftime("%A %d %B %Y - %H:%M %p")
  end
end
