# frozen_string_literal: true

# notice for member tests
require 'rails_helper'

RSpec.describe 'notifications', type: :feature do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) do
    FactoryBot.create(
      :entry, :attach_image, :reindex,
      member_id: member2.id,
      heading: 'entry title',
      category: 'Electric-Solid-Body-Guitar',
      vote_weight: 5
    )
  end

  describe 'when collected,favorite,liked entry' do
    before do
      sign_in member
      visit entry_path(entry, locale: I18n.locale)
      click_on 'collection'
      click_on 'favorite_border'
      click_on 'thumb_up_alt'
      sign_out member
    end

    it 'that notice member2' do
      sign_in member2
      visit member_root_path
      expect(page).to have_content('collected entry title')
      expect(page).to have_content('added favorite entry title')
      expect(page).to have_content('liked entry title')
    end
  end

  describe 'when follow member' do
    before do
      sign_in member
      visit profile_path(member2, locale: I18n.locale)
      click_on 'Follow'
      sign_out member
    end

    it 'that notice member2' do
      sign_in member2
      visit member_root_path
      expect(page).to have_content('followed guest')
    end
  end

  describe 'redirect profile page after readed notice' do
    before do
      sign_in member
      visit profile_path(member2, locale: I18n.locale)
      click_on 'Follow'
      sign_out member
    end

    it 'click notice link do that read notice' do
      sign_in member2
      visit member_root_path
      click_on "#{member.profile.login} followed #{member2.profile.login}", match: :first
      expect(page).to have_current_path(profile_path(member.profile, locale: I18n.locale))
      expect(page).not_to have_content("#{member.profile.login} followed #{member2.profile.login}")
    end
  end

  describe 'comment notice within entry' do
    before do
      sign_in member
      visit entry_path(entry, locale: I18n.locale)
      fill_in "commontator-thread-#{Commontator::Thread.last.id}-new-comment-body", with: 'awaesome'
      click_on 'Post Comment'
      sign_out member
    end

    it 'for member' do
      sign_in member2
      visit member_root_path
      expect(page).to have_content('commented on entry title')
    end
  end
end
