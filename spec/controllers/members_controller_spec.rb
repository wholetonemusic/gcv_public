require "rails_helper"

RSpec.describe MembersController, type: :controller do
  login_member
  let(:member2) { FactoryBot.create(:member) }

  it "should have a current_member" do
    expect(subject.current_member).to_not eq(nil)
  end

  it "should get home" do
    get "home"
    expect(response).to be_successful
  end
end
