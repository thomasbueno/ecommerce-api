FactoryBot.define do
  factory :coupon do
    code { Faker::Commerce.unique.promotion_code(digits: 6) }
    status { [:active, :inactive].sample }
    discount_value { rand(1..99) }
    due_date { Time.zone.now + 1.day }
  end
end