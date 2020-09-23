class NotifierMailer < ApplicationMailer
  default :from => "no-reply@bioisis.net"
  helper ApplicationHelper

  def registration
    @submission = params[:submission]
    #@submission = Submission.find_by(:id => params[:id])
    puts "Params for submission --- #{@submission.id}"
    puts params.inspect
    puts @submission.email

    file = "#{Rails.root}/public/bioisis_deposit.pdf"

    @link = "http://www.bioisis.net/deposition/#{@submission.data_directory.split(/\//)[@submission.data_directory.split(/\//).size - 1]}"
    @start_date = Time.now.strftime("%d %B %Y")
    attachments['bioisis_deposit.pdf'] = File.read(file)
    mail(:to => @submission.email, :subject => "New BioIsis Submission Link", :bcc => 'robert_p_rambo@hotmail.com')

  end

  def save_and_exit

    @submission = params[:submission]
    @link = "http://www.bioisis.net/deposition/#{@submission.data_directory.split(/\//)[@submission.data_directory.split(/\//).size - 1]}"
    # @start_date = nice_date(@submission.created_at)
    # @remaining = nice_date(@submission.created_at + 7.days)

    mail(:to => @submission.email, :subject => "BioIsis Deposit Saved for #{nice_date(@submission.created_at)}: Use Link To Return", :bcc => 'robert_p_rambo@hotmail.com')
  end

end
