FactoryBot.define do
  factory :game do
    mode { [:pvp, :pve, :both].sample }
    release_date { "2020-11-07 18:12:57" }
    developer { Faker::Company.name }
    system_requirement
  end
end
