# require "rails_helper"
#
# describe Members::OmniauthCallbacksController do
#   stub_omni_env
#   before { get :twitter }
#
#   it "when twitter uid exist in the system" do
#     member = Member.find_by(provider: "twitter", uid: "12345678")
#     expect(member.present?).to eq true
#   end
# end
