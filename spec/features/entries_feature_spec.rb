require "rails_helper"

RSpec.describe "/entries", type: :feature do
  let(:member) { FactoryBot.create(:member) }
  before { sign_in member }

  describe "member have a entry", js:true do
    it "that create" do
      visit new_entry_path
      attach_file(:entry_entry_images, Rails.root.join(
        "spec", "support", "test_image.jpg"
      ))
      select 'Electric-Solid-Body-Guitar', from: 'entry_category'
      fill_in(:entry_heading, with: "my guitar")
      fill_in(:entry_vote_weight, with: "0.5")
      first('input[name="commit"]').click
      expect(page).to have_content("my guitar")
      expect(page).to have_current_path(entry_path(Entry.last, locale: :en))
    end

    it "that edit" do
      visit new_entry_path
      attach_file(:entry_entry_images, Rails.root.join(
        "spec", "support", "test_image.jpg"
      ))
      select 'Electric-Solid-Body-Guitar', from: 'category'
      fill_in(:entry_heading, with: "my guitar")
      fill_in(:entry_vote_weight, with: "0")
      first('input[name="commit"]').click
      visit edit_entry_path(Entry.last, locale: :en)
      fill_in(:entry_heading, with: "my edit guitar")
      first('input[name="commit"]').click
      expect(page).to have_content("my edit guitar")
      expect(page).to have_current_path(entry_path(Entry.last, locale: :en))
    end
  end

  describe 'comment notice within entry' do
    let(:member) { FactoryBot.create(:member) }
    let(:member2) { FactoryBot.create(:member) }
    let(:entry) do
      FactoryBot.create(
        :entry, :attach_image, :reindex,
        member_id: member2.id,
        heading: 'entry title',
        category: 'Electric-Solid-Body-Guitar',
        vote_weight: '3'
      )
    end

    before do
      sign_in member
      visit entry_path(entry, locale: :en)
      fill_in "commontator-thread-#{Commontator::Thread.last.id}-new-comment-body", with: '素晴らしい'
      click_on 'Post Comment'
      sleep 2
      sign_out member
    end

    it 'for member' do
      Capybara.current_session.driver.header('Accept-Language', 'en')
      sign_in member2
      visit entry_path(entry, locale: :en)
      expect(page).to have_content('素晴らしい')
    end

    it 'for search' do
      visit entries_path(locale: :en)
      fill_in 'search_q', with: 'nothing'
      click_on 'commit'
      expect(page).not_to have_content('entry title')
    end

    it 'for search fill in nil' do
      visit entries_path(locale: :en)
      fill_in 'search_q', with: nil
      click_on 'commit'
      expect(page).not_to have_content('entry title')
    end
  end
end
