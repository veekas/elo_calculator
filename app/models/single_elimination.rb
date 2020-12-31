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

class SingleElimination < Tournament
  has_many :brackets, -> { order 'tournament_sequence asc' }, foreign_key: :tournament_id

  def build_matchups!
    gen = BracketGenerator.new(players)
    counter = gen.first_round.count
    gen.matches.each_with_index do |match, index|
      seq       = index + 1
      primary   = match.first
      secondary = match.last

      counter +=1 if seq.odd?
      winner_child = counter if counter < gen.balance_point
      loser_child  = gen.total_matches if gen.semis.include?(seq)

      if match.include?(0)
        bye = true
        winner_id = match.first
      else
        match_id = matchups.create(primary_id: primary,
                                   secondary_id: secondary,
                                   series_max: series_max).id
      end

      bracket_type = seq == gen.total_matches ? 'losers' : 'winners'

      brackets.create matchup_id: match_id,
                      winner_id: winner_id,
                      winner_child: winner_child,
                      loser_child: loser_child,
                      tournament_sequence: seq,
                      bracket_type: bracket_type,
                      bye: bye
    end

    brackets.each(&:update_children!)
  end

  def places
    @places ||= [rank_1, rank_2, rank_3, rank_4]
  end

  def rank_for(player)
    (places.find_index(player) + 1).ordinalize if places.include? player
  end

  def rank_1
    winners_bracket.last&.winner
  end

  def rank_2
    winners_bracket.last&.loser
  end

  def rank_3
    losers&.winner
  end

  def rank_4
    losers&.loser
  end

  def single_bracket_by_round
    SingleEliminationPresenter.present winners_bracket
  end

  def winners_bracket
    brackets.where(bracket_type: 'winners')
  end

  def losers
    brackets.where(bracket_type: 'losers').first
  end
end

class BracketGenerator
  attr_reader :players, :count
  def initialize(players)
    raise 'No Players' if players.nil?
    @players = players.sort_by(&:rating).reverse.map(&:id)
  end

  def matches
    first_round + Array.new(remaining_matches, [nil, nil])
  end

  def semis
    (1..matches.count).to_a[-4..-3]
  end

  def remaining_matches
    total_matches - first_round.count
  end

  def first_round
    @first_round ||= recursive_order_matches(first_byes + first_matches)
  end

  def number_of_rounds
    Math.log(balance_point, 2)
  end

  def total_matches
    balance_point
  end

  def first_matches
    order_matches players.last(count - byes)
  end

  def order_matches(matches)
    pairings = matches.each_slice(matches.size/2).to_a
    return pairings if pairings.one?
    pairings.first.zip pairings.last.reverse
  end

  def recursive_order_matches(matches)
    return matches.flatten.each_slice(2).to_a if matches.size == 2
    recursive_order_matches order_matches matches
  end

  def first_byes
    players.first(byes).zip Array.new(byes, 0)
  end

  def balance_point
    2**Math.log(count, 2).ceil
    #return count if count.to_s(2).count('1') == 1
    #('1' + ('0' * count.to_s(2).size)).to_i(2)
  end

  def byes
    balance_point - count
  end

  def count
    @count ||= players.count
  end
end

