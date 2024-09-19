# frozen_string_literal: true

# contact message mail deliver
class Contact < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: URI::MailTo::EMAIL_REGEXP
  attribute :message, validate: true
  attribute :nickname, captcha: true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: 'GCV contact message',
      to: 'webmaster@guitar-cv.com',
      from: %("#{name}" <#{email}>)
    }
  end
end
