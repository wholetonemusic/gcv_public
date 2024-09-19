require "rails_helper"

RSpec.describe Contact, :type => :mailer do
  describe "contact message" do
    let(:mail) { Contact.new(name: 'user name', email: 'user@example.com', message: 'message') }

    it "renders the headers" do
      expect(mail.headers[:subject]).to eq("GCV contact message")
      expect(mail.headers[:to]).to eq("webmaster@guitar-cv.com")
    end

    it "renders the body" do
      expect(mail.message).to match("message")
    end
  end
end
