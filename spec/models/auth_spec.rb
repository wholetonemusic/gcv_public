require "rails_helper"

RSpec.describe Member, type: :model do
  before do
    ActiveRecord::Base.connection.execute("
      INSERT INTO gcv6_test.members (id, email, legacy_password, 
        legacy_salt, remember_created_at, sign_in_count, 
        last_sign_in_at, current_sign_in_ip, last_sign_in_ip, 
        created_at, updated_at) 
      SELECT id, email, encrypted_password, 
        password_salt, remember_created_at, sign_in_count, 
        last_sign_in_at, current_sign_in_ip, last_sign_in_ip, 
        created_at, updated_at
      FROM gcv3_test.members 
      WHERE id = 1
    ")
  end

  describe "RestfulAuth encryptor create password-hash" do
    it "as gcv3 password, gcv6 legacy password" do
      ActiveRecord::Base.connected_to(role: :writing) do
        @member = Member.find 1
      end
      legacy_password = @member.legacy_password
      salt = @member.legacy_salt
      re_legacy_password = Devise::Encryptable::Encryptors::RestfulAuthenticationSha1.
        digest("396239", 1, salt, "")
      expect(re_legacy_password).to eq legacy_password
    end
  end

  describe "Devise default encryptor create password-hash" do
    it "restful_auth-has to bcrypt-hash that new hash" do
      ActiveRecord::Base.connected_to(role: :writing) do
        @member = Member.find 1
      end
      @member.valid_password?("396239")
      expect(@member.encrypted_password).not_to eq @member.legacy_password
    end
  end
end
