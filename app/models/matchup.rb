# == Schema Information
#
# Table name: matchups
#
#  id            :integer          not null, primary key
#  primary_id    :integer
#  secondary_id  :integer
#  winner_id     :integer
#  tournament_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  series_max    :integer
#
# Indexes
#
#  index_matchups_on_tournament_id  (tournament_id)
#

class Matchup < ApplicationRecord
  belongs_to :tournament, optional: true
  belongs_to :winner, class_name: 'Player', optional: true
  belongs_to :primary, class_name: 'Player', optional: true
  belongs_to :secondary, class_name: 'Player', optional: true
  has_many :games

  def self.for_players(*players)
    where(primary_id: players, secondary_id: players).first
  end

  def ready?
    (primary && secondary) && !winner
  end

  def bracket_matchup
    Bracket.find_by matchup_id: id
  end

  def can_undo?
    games.include? Game.last
  end

  def add_game_results(game_results)
    return false if game_results.nil?
    MatchupCreator.new(matchup_id: id, game_results: game_results).save
  end

  def opponent_of(challenger)
    challenger == primary ? secondary : primary
  end

  def players
    [primary, secondary]
  end
end
