class RearGearType < ActiveRecord::Base
  include FriendlySlugFindable

  validates_presence_of :name, :count
  validates_uniqueness_of :name
  has_many :bikes

  scope :standard, -> { where(standard: true) }
  scope :internal, -> { where(internal: true) }

  def self.fixed
    where(name: "Fixed", count: 1, internal: false).first_or_create
  end
end
