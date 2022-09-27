# frozen_string_literal: true

class Survivor < ApplicationRecord
  validates :name, :age, :gender, :latitude, :longitude, :water, :soup, :firstAid, :ak47, presence: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :name, format: { with: /\A[a-zA-Z\s]+\Z/i }
  validates :name, length: { minimum: 1, maximum: 40 }
  validates :gender, inclusion: { in: %w[male female other] }
  validates :latitude, :longitude, numericality: true
  validates :water, :soup, :firstAid, :ak47, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
