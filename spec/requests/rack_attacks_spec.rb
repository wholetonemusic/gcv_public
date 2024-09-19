require "rails_helper"

describe Rack::Attack do
  include Rack::Test::Methods

  let(:member) { FactoryBot.create(:member) }
  let(:entries) {
    FactoryBot.create_list(:entry, 12, :attach_image, :reindex,
                           member_id: member.id, heading: "entry title", vote_weight: 5)
  }

  describe "throttle excessive requests by IP address" do
    before(:each) do
      Rack::Attack.enabled = true
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    end
    after(:each) do
      Rack::Attack.reset!
    end
    let(:limit240) { 240 }
    let(:limit20) { 20 }

    #  this test is passed, but spends a lot of time while running spec, comment out there
    #
    # context "number of requests is lower or higher than the limit" do
    #   before { entries }
    #   it "does not change the request status 200" do
    #     limit240.times do
    #       get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
    #     end
    #     expect(last_response.status).to_not eq(429)
    #   end

    #   it "changes the request status to 429" do
    #     (limit240 + 1).times do |i|
    #       get "/", {}, "REMOTE_ADDR" => "1.2.3.5"
    #     end
    #     expect(last_response.status).to eq(429)
    #   end
    # end

    context "number of member login requests is lower or higher than the limit" do
      it "change the request status to 429 by bot access" do
        6.times do |i|
          post "/members/sign_in?locale=en",
            { email: "example1#{i}@gmail.com",
              password: "password", password_confirmation: "password" },
              "REMOTE_ADDR" => "1.2.3.10"
        end
        expect(last_response.status).to eq(429)
      end

      it "does not change the request status 200 with slow access" do
        limit20.times do |i|
          post "/members/sign_in?locale=en",
            { email: "example1#{i}@gmail.com",
              password: "password", password_confirmation: "password" },
              "REMOTE_ADDR" => "1.2.3.6"
          sleep 1
        end
        expect(last_response.status).to_not eq(429)
      end

      it "change the request status to 429 with slow access" do
        (limit20 + 1).times do |i|
          post "/members/sign_in?locale=en",
            { email: "example2#{i}@gmail.com",
              password: "password", password_confirmation: "password" },
              "REMOTE_ADDR" => "1.2.3.7"
          sleep 1
        end
        expect(last_response.status).to eq(429)
      end
    end

    context "throttle excessive POST requests to sign in by email address" do
      it "change the request status to 429 for admin" do
        (limit20 + 1).times do |i|
          post "/admin/login?locale=en",
            { email: "example4@gmail.com",
              password: "password", password_confirmation: "password" },
              "REMOTE_ADDR" => "1.2.3.9"
          sleep 1
        end
        expect(last_response.status).to eq(429)
      end
    end
  end
end
