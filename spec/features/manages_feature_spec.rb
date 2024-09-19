require 'rails_helper'

RSpec.describe '/manages', type: :feature do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) {
      FactoryBot.create(:entry, :skip_validate,
                        member_id: member2.id, heading: 'entry title')
    }
  before { sign_in member }

  describe 'management members collection' do
    before { entry.collect_by(member) }
    it 'uncollection' do
      visit manages_entry_collections_path
      click_on('Delete from Collection')
      expect(page).to have_current_path(manages_entry_collections_path(locale: :en))
    end
  end

  describe 'management members follow' do
    before { member2.follow_by(member) }
    before { visit manages_member_follows_path }

    it 'rendering member2' do
      expect(page).to have_content(member2.profile.login)
    end

    it 'not rendering member2 after unfollow' do
      click_on('unfollow')
      expect(page).to have_current_path(manages_member_follows_path(locale: :en))
      expect(page).to have_no_content(member2.profile.login)
    end
  end

  describe 'management members follower' do
    before { member.follow_by(member2) }
    before { visit manages_member_followers_path }

    it 'rendering member2' do
      expect(page).to have_content(member2.profile.login)
    end

    it 'not rendering member2 after block' do
      click_on('block')
      expect(page).to have_current_path(manages_member_followers_path(locale: :en))
      expect(page).to have_content('0 followers')
    end

    it 'not rendering member on follow page of member2' do
      member.block_to(member2)
      sign_out member
      sign_in member2
      visit manages_member_follows_path
      expect(page).to have_no_content(member.profile.login)
    end
  end

end
