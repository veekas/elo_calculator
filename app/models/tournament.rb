# == Schema Information
#
# Table name: tournaments
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#  end_date   :datetime
#  type       :string
#  series_max :integer
#
# Indexes
#
#  index_tournaments_on_type  (type)
#

class Tournament < ApplicationRecord
  TYPES = %w( RoundRobin SingleElimination )
  SERIES_MAXES = [1, 3, 5, 7, 9]
  has_many :entries
  has_many :players, -> { order('rating desc') }, through: :entries
  has_many :matchups

  scope :active, -> { where('end_date >= ?', Date.current).order(end_date: :desc) }
  scope :expired, -> { where('end_date < ?', Date.current).order(end_date: :desc) }

  validates :name, presence: true
  validates :end_date, presence: true
  validates :type, presence: true
  validates :series_max, presence: true

  def started?
    matchups.any?
  end

  def has_playable_matches(player)
    matchups.where("primary_id = #{player.id} or secondary_id = #{player.id}")
            .select(&:ready?)
            .any?
  end

  def matchups_for(player)
    matchups.where("primary_id = #{player.id} or secondary_id = #{player.id}")
  end

  def match_points_for(player)
    matchups.where(winner: player).count
  end

  def complete?
    matchups.where(winner_id: nil).empty?
  end

  def expired?
    end_date < Date.current if end_date
  end
end
