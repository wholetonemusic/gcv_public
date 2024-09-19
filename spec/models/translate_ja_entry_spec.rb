require 'rails_helper'

RSpec.describe TranslateJaEntry, type: :model do
  let(:member) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :skip_validate,
                      member_id: member.id, heading: "entry title")
  }

  describe 'check translated ja' do
    before { entry.update(heading: '題名') }
    it 'attributes' do
      entry.translate_ja_attributes
      expect(entry.heading).to eq 'Title'
      expect(entry.translate_ja_entry.translated).to eq true
    end
  end

  describe 'check translated en' do
    before { entry.update(heading: 'Title') }
    it 'attributes' do
      entry.translate_ja_attributes
      expect(entry.heading).to eq 'Title'
      expect(entry.translate_ja_entry.nil?).to eq true
    end
  end

  describe 'check translated all' do
    before do
      entry.update(heading: '題名')
      entry.translate_ja_attributes
    end

    it 'attributes' do
      Entry.check_translated_all
      expect(entry.translate_ja_entry.translated).to eq true
    end
  end
end
