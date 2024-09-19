require "rails_helper"

RSpec.describe Profile, type: :model do
  let(:member) { FactoryBot.create(:member) }

  describe 'create profile' do
    it "is valid if image is attached" do
      profile_parm = Profile.new(member_id: member.id, login: "helter")
      expect(profile_parm.valid?).to eq true
    end

    it "when create member do create profile" do
      profile = member.profile
      expect(profile.login).to eq "guest#{member.id}member"
    end
  end

  describe 'translate Ja to En all profiles' do
    before { member.profile.update(login: '名前') }
    it 'translate romaji' do
      Profile.translate_ja_attributes_all
      expect(TranslateJaProfile.where(profile_id: member.profile.id).last.login).to eq 'Namae'
    end
  end

  describe 'translate Ja to En' do
    before { member.profile.update(login: '富士山') }
    it 'if login is kanji, do translate romaji' do
      member.profile.translate_ja_login
      expect(member.profile.translate_ja_profile.login).to eq 'Fujisan'
    end
  end

  # when Miyabi to_kanhira method rise 404 error
  describe 'translate Ja to En with handling exception' do
    before { member.profile.update(login: '原雑新') }
    it 'ensure translate any kanji' do
      member.profile.translate_ja_login
      expect(member.profile.translate_ja_profile.login).to eq 'Harazatsushin'
    end
  end

  describe 'translate Ja to En of attributes' do
    before { member.profile.update(
      login: '佐藤', about_me: 'こんにちは', play_field: '', youtube: nil
    ) }
    it 'by google translate api (ignore :login)' do
      member.profile.translate_ja_attributes
      expect(member.profile.translate_ja_profile.login).to eq 'Satou'
      expect(member.profile.translate_ja_profile.about_me).to eq 'Hello'
    end
  end

  describe 'translate Ja to En of attributes when login english' do
    before { member.profile.update(
      login: 'satou', about_me: 'こんにちは', play_field: '', youtube: nil
    ) }
    it 'by google translate api (ignore :login)' do
      member.profile.translate_ja_attributes
      expect(member.profile.translate_ja_profile.login).to eq 'Satou'
      expect(member.profile.translate_ja_profile.about_me).to eq 'Hello'
    end
  end

  describe 'when translate Ja to En of attributes blank' do
    before { member.profile.update(
      about_me: '', play_field: '', youtube: nil
    ) }
    it 'do not translate' do
      member.profile.translate_ja_attributes
      expect(member.profile.about_me).to eq ''
      expect(member.profile.translate_ja_profile).to eq nil
    end
  end

end
