require "rails_helper"
require "cancan/matchers"

RSpec.describe Member, type: :model do
  let(:ability) { Ability.new(member) }
  let(:member) { FactoryBot.create(:member) }

  it "define ability" do
    expect(ability.can?(:update, Entry)).to be true
    expect(ability.can?(:read, Entry.new.collector_votes)).to be false
    expect(ability.can?(:destroy, Profile)).to be false
  end
end
