# frozen_string_literal: true

# follow vote, collection vote and more
require 'rails_helper'

RSpec.describe '/votes', type: :feature do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) do
    FactoryBot.create(
      :entry, :attach_image, :reindex,
      member_id: member2.id, heading: 'entry title',
      category: 'Electric-Solid-Body-Guitar',
      vote_weight: 5
    )
  end
  before { sign_in member }

  describe 'follow member' do
    before { visit profile_path(member2, locale: I18n.locale) }

    it 'visit member profile page' do
      expect(page).to have_content(member2.profile.login)
      expect(page).to have_button('Follow')
    end

    it 'follow and redirect profile page' do
      click_button 'Follow'
      expect(page).to have_button('Unfollow')
    end
  end

  describe 'unfollow member' do
    before do
      member2.follow_by(member)
      visit profile_path(member2, locale: I18n.locale)
    end

    it 'visit followed member profile page' do
      expect(page).to have_button('Unfollow')
    end

    it 'unfollow and redirect profile page' do
      click_button 'Unfollow'
      expect(page).to have_button('Follow')
      expect(page).to have_no_button('Unfollow')
    end
  end

  describe 'block member' do
    before { visit profile_path(member2, locale: I18n.locale) }

    it 'block and redirect profile page' do
      click_on 'more_horiz'
      click_on 'Block'
      expect(page).to have_link('Unblock')
      expect(page).to have_no_link('Block')
      expect(page).to have_no_button('Follow')
    end
  end

  describe 'collection entry' do
    before { visit entry_path(entry, locale: I18n.locale) }

    it 'collection and redirect to entry page' do
      click_button 'collection'
      expect(page).to have_button('uncollection')
    end

    it 'after collection ando that uncollection' do
      click_button 'collection'
      click_button 'uncollection'
      expect(page).to have_button('collection')
    end
  end

  describe 'blocked member' do
    before do
      member2.block_to(member)
      visit entry_path(entry, locale: I18n.locale)
    end

    it 'cannot comment' do
      expect(page).to have_no_button('Post Comment')
    end

    it 'cannot collection' do
      expect(page).to have_no_button('collection')
    end
  end

  describe 'no login member' do
    before { sign_out member }

    it 'render entry page' do
      visit entry_path(entry, locale: I18n.locale)
      expect(page).to have_content(entry.heading)
      expect(page).to have_button('collection')
    end
  end
end
