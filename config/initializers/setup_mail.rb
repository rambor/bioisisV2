ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    #  :address => "smtp.live.com",
    #  :port    => 587,
    :port => 465,
    :authentication => :login,
    :user_name =>"robertprambo@gmail.com",
    :password => "e_ml69=8rpr",
    :domain => "www.bioisis.net",
    #  :enable_starttls_auto => true,
    :ssl => true
}