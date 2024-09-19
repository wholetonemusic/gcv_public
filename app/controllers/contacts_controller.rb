# frozen_string_literal: true

# contact message mail deliver
class ContactsController < ApplicationController
  layout "entry_layout"

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request

    respond_to do |format|
      if verify_recaptcha(action: 'contact') && @contact.deliver
        format.html { redirect_to message_sent_path }
      else
        format.html { render :new }
      end
    end
  end

  def message_sent
    respond_to do |format|
      format.html
    end
  end
end
