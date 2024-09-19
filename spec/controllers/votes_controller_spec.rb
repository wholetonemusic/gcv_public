require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }

  describe 'follow and unfollow' do
    before { sign_in member }

    it 'should post follow' do
      post :follow, params: { follow_id: member2.id }
      expect(response).to have_http_status(302)
    end

    it 'should patch unfollow' do
      post :follow, params: { follow_id: member2.id }
      patch :unfollow, params: { follow_id: member2.id }
      expect(response).to have_http_status(302)
    end
  end

  describe 'block and unblock' do
    before { sign_in member }

    it 'should pach block' do
      patch :block, params: { follow_id: member2.id }
      expect(response).to have_http_status(302)
    end

    it 'should delete unblock' do
      patch :block, params: { follow_id: member2.id }
      delete :unblock, params: { follow_id: member2.id }
      expect(response).to have_http_status(302)
    end
  end

  describe 'entry colloection' do
    before { sign_in member2 }
    let(:entry) {
      FactoryBot.create(:entry, :skip_validate,
                        member_id: member.id, heading: 'entry title')
    }

    it 'should post collection' do
      post :entry_collection, params: { entry_id: entry.id }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(entry)
    end

    it 'should delete collection' do
      post :entry_collection, params: { entry_id: entry.id }
      delete :entry_uncollection, params: { entry_id: entry.id }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(entry)
    end

    it 'should delete collection from mamber manages' do
      post :entry_collection, params: { entry_id: entry.id }
      delete :entry_uncollection, params: { entry_id: entry.id, manage: 'member' }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(manages_entry_collections_path)
    end
  end

  describe 'entry favorite' do
    before { sign_in member2 }
    let(:entry) {
      FactoryBot.create(:entry, :skip_validate,
                        member_id: member.id, heading: 'entry title')
    }

    it 'should post favorite' do
      post :entry_favorite, params: { entry_id: entry.id }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(entry)
    end

    it 'should delete favorite' do
      post :entry_favorite, params: { entry_id: entry.id }
      delete :entry_unfavorite, params: { entry_id: entry.id }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(entry)
    end
  end

  describe 'entry like' do
    before { sign_in member2 }
    let(:entry) {
      FactoryBot.create(:entry, :skip_validate,
                        member_id: member.id, heading: 'entry title')
    }

    it 'should post like' do
      post :entry_like, params: { entry_id: entry.id }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(entry)
    end

    it 'should delete like' do
      post :entry_like, params: { entry_id: entry.id }
      delete :entry_unlike, params: { entry_id: entry.id }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(entry)
    end
  end
end
