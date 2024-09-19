require "rails_helper"

RSpec.describe EntriesController, type: :controller do
  let(:member) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :attach_image, :reindex,
                      member_id: member.id, heading: "entry title", vote_weight: 5)
  }
  let(:valid_attributes) {
    { entry_images: [fixture_file_upload(Rails.root.join(
      "spec", "support", "test_image.jpg"
      ))],
      heading: "entry title",
      category: "Electric-Solid-Body-Guitar" }
  }

  describe "public access" do
    it "get index" do
      get :index
      expect(response).to have_http_status(200)
      expect(assigns(:entries)).to eq [entry]
    end

    it "get show" do
      get :show, params: { id: entry.to_param }
      expect(response).to have_http_status(200)
      expect(assigns(:entry)).to eq entry
      expect(CheckIpJob.jobs.size).to eq 1
    end

    it "get new" do
      get :new
      expect(response).to have_http_status(302)
    end
  end

  describe "authenticate access" do
    before { sign_in member }

    it "get new" do
      get :new
      expect(response).to have_http_status(200)
    end

    it "get edit" do
      get :edit, params: { id: entry.to_param }
      expect(response).to have_http_status(200)
      expect(assigns(:entry)).to eq entry
    end

    it "post create" do
      post :create, params: { entry: valid_attributes }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(Entry.last)
      expect(TranslateJaEntryJob.jobs.size).to eq 1
    end

    it "patch update" do
      patch :update, params: { id: entry.to_param, entry: { heading: "update" } }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(entry)
      expect(TranslateJaEntryJob.jobs.size).to eq 1
    end

    it "delete destroy" do
      delete :destroy, params: { id: entry.to_param }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(manages_my_entries_path)
    end
  end
end
