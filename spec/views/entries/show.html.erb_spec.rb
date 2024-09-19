require "rails_helper"

RSpec.describe "entries/show", type: :view do
  let(:member) { FactoryBot.create(:member) }
  let(:member2) { FactoryBot.create(:member) }
  let(:entry) {
    FactoryBot.create(:entry, :attach_image,
                      member_id: member.id,
                      heading: "entry title",
                      vote_weight: 5)
  }

  describe "public access" do
    before do
      assign(:entry, entry)
      assign(:similars, [entry])
      assign(:features, [entry])
      render
    end

    it "page include entry heading" do
      expect(rendered).to include(entry.heading)
    end

    it "collection button" do
      expect(rendered).to include("collection")
      expect(rendered).not_to include("uncollection")
    end
  end

  describe "private access" do
     before do
      sign_in member2
      entry.collect_by(member2)
      assign(:entry, entry)
      assign(:similars, [entry])
      assign(:features, [entry])
      render
    end

    it "uncollect button if entry collected" do
      expect(rendered).to include("entry_uncollection")
      expect(rendered).not_to include("entry_collection")
    end
  end
end
