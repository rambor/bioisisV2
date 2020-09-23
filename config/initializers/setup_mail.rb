ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    #  :address => "smtp.live.com",
    #  :port    => 587,
    :port => 465,
    :authentication => :login,
    :user_name => ENV["MAILER_EMAIL"],
    :password => ENV["MAILER_PASSWORD"],
    :domain => "www.bioisis.net",
    #  :enable_starttls_auto => true,
    :ssl => true
}