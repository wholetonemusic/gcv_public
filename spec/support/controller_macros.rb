module ControllerMacros
  #    def login_admin
  #      before(:each) do
  #        @request.env["devise.mapping"] = Devise.mappings[:admin]
  #        admin = FactoryBot.create(:admin)
  #        sign_in admin
  #      end
  #    end

  def login_member
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:member]
      member = FactoryBot.create(:member)
      sign_in member
    end
  end

  def stub_omni_env
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter] = nil
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      provider: "twitter",
      uid: "12345678",
      info: { email: "foofighter@example.jp" },
    })
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:member]
      @request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
    end
  end
end
