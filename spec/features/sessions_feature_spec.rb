require 'rails_helper'

RSpec.describe '/members/auth', type: :feature do

  describe 'member account', js:true do

    it 'desable sign up without email' do
      visit new_member_registration_path
      click_button 'Sign up'
      expect(page).to have_title(/^Member Sign Up/)
      expect(page).to have_content("Email can't be blank")
    end

    it 'desable login without email' do
      visit new_member_session_path
      click_button 'Login'
      expect(page).to have_title('Login')
    end

    it 'desable password new without email' do
      visit new_member_password_path
      click_button 'Send instructions'
      expect(page).to have_title('Forgot Password?')
      expect(page).to have_content("Email can't be blank")
    end


#     it 'with twitter login include email' do
#       visit new_member_registration_path
#       mock_auth_hash
#       click_button 'Continue with Twitter'
#       expect(page).to have_current_path(member_root_path(locale: I18n.locale))
#     end
# 
#     it 'with twitter login exclude email' do
#       visit new_member_registration_path
#       mock_auth_hash_nil_email
#       click_button 'Continue with Twitter'
#       expect(page).to have_current_path(member_root_path(locale: I18n.locale))
#     end
#   end
  end

  describe 'member login', js:true do
    let(:member) { FactoryBot.create(:member) }

    it 'enable' do
      visit new_member_session_path
      fill_in(:member_email, with: member.email)
      fill_in(:member_password, with: 'password')
      click_button 'Login'
      expect(page).to have_current_path(member_root_path(locale: I18n.locale))
    end

   end
# def mock_auth_hash
#   OmniAuth.config.test_mode = true
#   OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
#     provider: "twitter",
#     uid: "12345678",
#     info: { email: "foofighter@example.jp" },
#     credentials: { token: "mock_token", secret: "mock_secret" }
#   })
# end
# 
# def mock_auth_hash_nil_email
#   OmniAuth.config.test_mode = true
#   OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
#     provider: "twitter",
#     uid: "12345678",
#     info: { email: '' },
#     credentials: { token: "mock_token", secret: "mock_secret" }
#   })
end

