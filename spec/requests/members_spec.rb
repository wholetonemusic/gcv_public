require "rails_helper"

RSpec.describe "/members", type: :request do
  let(:member) { FactoryBot.create(:member) }

  context "with invalid parameters" do
    it "does create a new member which devise/registration/create" do
      post member_registration_url, # POST /members
           params: { member: { email: "some@email.com",
                              password: "123456", password_confirmation: "123456" } }
      expect(response).to redirect_to(member_root_path(locale: :en))
    end
  end

  context "login member" do
    before { sign_in member }

    it "does go a member email or password edit page" do
      get edit_member_registration_url # GET /members/edit
      expect(response).to render_template("members/registrations/edit")
    end

    it "does update a member email which devise/registrations/update" do
      patch member_registration_url, # PATCH /members
            params: { member: { email: "edit@email.com",
                                password: "editpassword",
                                password_confirmation: "editpassword",
                                current_password: "password" } }
      expect(response).to redirect_to(member_root_path(locale: :en))
    end

    it "does not update fill in fail current password which devise/registrations/update" do
      patch member_registration_url, # PATCH /members
            params: { member: { email: "edit@email.com",
                                password: "editpassword",
                                password_confirmation: "editpassword",
                                current_password: "failpassword" } }
      expect(response).to render_template("members/registrations/edit") # /members/edit
    end

    it "does destroy a member self registration" do
      delete member_registration_url # DELETE /members
      expect(response).to redirect_to(root_path(locale: :en))
    end
  end
end
