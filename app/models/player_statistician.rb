class PlayerStatistician
  attr_reader :player

  def initialize(player)
    @player = player
  end

  def win_percentage
    return 0 if games_won_count.zero?
    (games_won_count.to_f / games.count.to_f).round(2) * 100.0
  end

  def daily_rating_change
    rating - start_rating_on(Date.current)
  end

  def highest_rating_achieved
    lost_games.pluck(:loser_rating).push(rating).max
  end

  def rating
    player.rating
  end

  def average_rating
    return 1000 if games.empty?
    games.inject(rating){ |sum, game| sum += game.rating_for(player) } / (games.count + 1)
  end

  def ratings_over_time(limit=nil)
    sessions = limit || 999999
    days_played.reverse.map do |day|
      { x: day, y: start_rating_on(day)}
    end.last(sessions.to_i)
  end

  def days_played
    games.pluck(:created_at).map{|t| t.to_date }.uniq
  end

  def rating_change_on(day)
    next_rating_from(day) - start_rating_on(day)
  end

  def todays_games
    @games.where('created_at >= ?', Date.current.beginning_of_day)
  end

  def games_won_today
    todays_games.where(winner_id: player.id)
  end

  def todays_opponents
    Player.find (todays_games.pluck(:winner_id, :loser_id).flatten - [player.id])
  end

  def games_played_today_against(opponent)
    todays_games.where("winner_id = #{opponent.id} or loser_id = #{opponent.id}")
  end

  def games_won_today_against(opponent)
    todays_games.where(winner_id: player.id, loser_id: opponent.id)
  end

  def opponents_by_games_played
    Player.find opponents.inject(Hash.new(0)){|h, p| h[p] +=1;h }.sort_by{|_, v| v}.reverse.to_h.keys
  end

  private

  def games
    @games ||= player.games
  end

  def opponents
    games.pluck(:winner_id, :loser_id).flatten - [player.id]
  end

  def average_rating_change
    ratings = days_played.map { |day| rating_change_on day }
    ratings.present? ? ratings.sum / ratings.count : 0
  end

  def start_rating_on(day)
    game = games.played_on(day).first || next_game_from(day)
    return rating unless game
    game.rating_for player
  end

  def next_game_from(day)
    played_games = games.played_on(day)
    return nil if played_games.empty?
    played_games.last.next_game_for player
  end

  def next_rating_from(day)
    game = next_game_from(day)
    return rating if game.nil?
    game.rating_for player
  end

  def games_won_count
    @games_won_count ||= player.won_games.count
  end

  def lost_games
    player.lost_games
  end
end
