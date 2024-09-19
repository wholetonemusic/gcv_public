require 'rails_helper'

RSpec.describe 'profiles', type: :feature do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }

  describe 'cancan abilities show following, followers' do
    before { member2.follow_by(member) }
    before { member.follow_by(member2) }

    it 'show for a login member' do
      sign_in member
      visit profile_path(member2, locale: I18n.locale)
      expect(page).to have_current_path(profile_path(member2, locale: I18n.locale))
    end

    it 'not show for a no login visitor' do
      visit profile_path(member2, locale: I18n.locale)
      expect(page).to have_current_path(new_member_session_path(locale: :en))
    end

    it 'profile_show_following for a login member' do
      sign_in member
      visit profile_show_followers_path(member2.id)
      expect(page).to have_current_path(profile_show_followers_path(member2.id))
    end

    it 'not show for a no login visitor' do
      visit profile_show_followers_path(member2.id)
      expect(page).to have_current_path(new_member_session_path(locale: :en))
    end
  end

  describe 'cancan abilities update' do
    it 'render edit' do
      sign_in member
      visit edit_profile_path(member, locale: I18n.locale)
      expect(page).to have_current_path(edit_profile_path(member, locale: I18n.locale))
    end

    it 'not render edit for visitor' do
      visit edit_profile_path(member, locale: I18n.locale)
      expect(page).to have_current_path(new_member_session_path(locale: :en))
    end

    it 'not render edit for another member' do
      sign_in member
      visit edit_profile_path(member2, locale: I18n.locale)
      expect(page).to have_current_path(root_path(locale: :en))
    end
  end

  describe 'views' do
    before do
      member.profile.update(login: '佐藤', about_me: 'こんにちは')
      member.profile.translate_ja_attributes
      sign_in member
    end

    it 'rendering ja when locale is ja' do
      Capybara.current_session.driver.header('Accept-Language', 'ja')
      visit profile_path(member, locale: :ja)
      expect(page).to have_content('佐藤')
      expect(page).to have_content('こんにちは')
    end

    it 'rendering en when locale is en' do
      Capybara.current_session.driver.header('Accept-Language', 'en')
      visit profile_path(member, locale: I18n.locale)
      expect(page).to have_content('Satou')
      expect(page).to have_content('Hello')
    end

    it 'rendering en when locale is fr' do
      Capybara.current_session.driver.header('Accept-Language', 'fr')
      visit profile_path(member, locale: I18n.locale)
      expect(page).to have_content('Satou')
      expect(page).to have_content('Hello')
    end
  end
end

