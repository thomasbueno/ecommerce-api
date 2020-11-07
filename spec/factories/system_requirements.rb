FactoryBot.define do
  factory :system_requirement do
    sequence(:name) { |n| "Recommended #{n}" }
    operational_system { Faker::Computer.os }
    storage { "90 GB" }
    processor { "Intel i5 9400F" }
    memory { "16 GB" }
    video_board { "Geforce RTX 2060 Super" }
  end
end
