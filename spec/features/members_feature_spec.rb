require 'rails_helper'

RSpec.describe '/members', type: :feature do
  let(:member) { FactoryBot.create(:member) }

  describe 'member account' do
    before { sign_in member }
    before { visit edit_member_registration_path }

    it 'change password' do
      fill_in(:member_password, with: 'newpassword')
      fill_in(:member_password_confirmation, with: 'newpassword')
      page.all(:fillable_field, 'member_current_password')[1].set('password')
      page.all(:button, 'Save Changes')[1].click
      expect(page).to have_content('Your account has been updated successfully.')
      expect(page).to have_current_path(member_root_path(locale: :en))
    end

    it 'delete' do
      click_on('delete my account')
      expect(page).to have_current_path(root_path(locale: :en))
    end

    it 'disable change password' do
      fill_in(:member_password, with: 'newpassword')
      fill_in(:member_password_confirmation, with: 'newpassword')
      page.all(:fillable_field, 'member_current_password')[1].set('failpassword')
      page.all(:button, 'Save Changes')[1].click
      expect(page).to have_content('Current password is invalid')
    end
  end

  describe 'member cannot login,' do
    before do
      clear_emails
      visit new_member_password_path
    end

    it 'then reset password' do
      fill_in(:member_email, with: member.email)
      click_on('commit')
      expect(page).to have_current_path(new_member_session_path(locale: :en))
      expect(page).to have_content('You will receive an email')
      open_email(member.email)
      current_email.click_link 'Change my password'
      fill_in('New password', with: 'newpassword')
      fill_in('Confirm new password', with: 'newpassword')
      click_on('Change my password')
      expect(page).to have_current_path(member_root_path(locale: :en))
    end

    it 'then not saved db member email' do
      fill_in(:member_email, with: 'disable@email.com')
      click_on('commit')
      expect(page).to have_content('Email not found')
    end
  end

end
