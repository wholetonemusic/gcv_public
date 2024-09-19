require "rails_helper"

RSpec.describe "profiles/show", type: :view do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :attach_image,
                      member_id: member.id,
                      heading: "entry title",
                      vote_weight: 5)
  }

  before(:each) do
    sign_in member
    assign(:entries, [entry])
    assign(:collections, [entry])
    allow(view).to receive_messages(paginate: nil)
  end

  it "member login name" do
    assign(:profile, member.profile)
    render
    expect(rendered).to include(member.profile.login)
  end

  it "follow button" do
    assign(:profile, member2.profile)
    render
    expect(rendered).to include("follow")
    expect(rendered).to include("block")
    expect(rendered).not_to include("unfollow")
  end

  it "unfollow button if member followed" do
    member2.follow_by(member)
    assign(:profile, member2.profile)
    render
    expect(rendered).to include("unfollow")
    expect(rendered).to include("block")
  end

  it "invisible follow button in self profile page" do
    assign(:profile, member.profile)
    render
    expect(rendered).not_to include("unfollow")
    expect(rendered).not_to include("block")
  end

  it "visible block button if not blocked" do
    assign(:profile, member2.profile)
    render
    expect(rendered).to include("block")
  end

  it "invisible block,follow,unfollow button if blocked" do
    member.block_to(member2)
    assign(:profile, member2.profile)
    render
    expect(rendered).to include("unblock")
    expect(rendered).not_to include("unfollow")
  end

  it "visible unblock button if blocked" do
    member.block_to(member2)
    member.unblock_to(member2)
    assign(:profile, member2.profile)
    render
    expect(rendered).to include("block")
    expect(rendered).to include("follow")
    expect(rendered).not_to include("unblock")
  end
end

def current_user
  current_member
end
