FactoryBot.define do
  factory :member do
    email { "#{SecureRandom.hex(6)}@email.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end
