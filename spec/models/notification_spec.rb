require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:member1) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :skip_validate,
                      member_id: member2.id, heading: "entry title")
  }

  it 'collection notice to member2' do
    vote = { heading: 'your new follower', profile_id: member1.profile.id }
    VoteNotification.with(vote).deliver(member2)
    expect(member2.notifications.last.sender.login).to eq member1.profile.login
    expect(member2.notifications.last.params[:heading]).to eq 'your new follower'
  end

end
