require "rails_helper"

RSpec.describe "/profiles", type: :request do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }

  describe "GET /show" do
    it "renders a not successful response for every visitor (no login)" do
      get profile_url(member.profile, locale: I18n.locale)
      expect(response).not_to be_successful
    end

    it "renders a successful response for sign in member" do
      sign_in member
      get profile_url(member.profile, locale: I18n.locale)
      expect(response).to be_successful
      sign_out member
    end
  end

  describe "GET /edit" do
    it "render a not successful response for visitor" do
      get edit_profile_url(member.profile, locale: I18n.locale)
      expect(response).not_to be_successful
      expect(response).to redirect_to(new_member_session_path(locale: :en))
    end

    it "render a successful response for sign in member whose profile" do
      sign_in member
      get edit_profile_url(member.profile, locale: I18n.locale)
      expect(response).to be_successful
      expect(response.body).to include("guest#{member.id}member")
      sign_out member
    end

    it "render a not successful response for another member page" do
      sign_in member
      get edit_profile_url(member2.profile, locale: I18n.locale)
      expect(response).not_to be_successful
      expect(response).to redirect_to(root_path)
      sign_out member
    end
  end

  describe "PATCH /update" do
    it "bad updates the requested profile by visitor requested" do
      patch profile_url(member.profile, params: { profile: { about_me: "guitarist" } }, locale: I18n.locale )
      expect(response).not_to be_successful
      expect(response).to redirect_to(new_member_session_path(locale: :en))
    end

    it "updates the requested profile and redirects to the profile" do
      sign_in member
      patch profile_url(member.profile, params: { profile: { login: "guitarist" } }, locale: I18n.locale)
      member.profile.reload
      expect(response).to redirect_to(profile_url(member.profile, locale: I18n.locale))
      sign_out member
    end

    it "bad updates the requested profile by another member" do
      sign_in member
      patch profile_url(member2.profile, params: { profile: { about_me: "guitarist" } }, locale: I18n.locale)
      expect(response).not_to be_successful
      expect(response).to redirect_to(root_path)
      sign_out member
    end

    it "validates to uniqueness login name" do
      sign_in member
      patch profile_url(member.profile, params: { profile: { login: "guest#{member2.id}member" } }, locale: I18n.locale)
      expect(response).not_to be_successful
      expect(response).to render_template(:edit)
      sign_out member
    end
  end
end
