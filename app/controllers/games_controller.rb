class GamesController < ApplicationController
  def new
    @players = Player.all.sort_by(&:name)
  end

  def create
    winner = Player.find_by_name(game_params[:winner_name])
    loser = Player.find_by_name(game_params[:loser_name])

    @game = Game.new(winner_name: winner.name,
                     winner_rating: winner.rating,
                     loser_name: loser.name,
                     loser_rating: loser.rating)
    new_rating = RatingUpdater.new(winner, loser)
    winner.rating += new_rating.change_in_rating
    loser.rating -= new_rating.change_in_rating+1
    winner.save
    loser.save

    @game.save 
    redirect_to :root
  end
  
  private
    def game_params
      params.require(:game).permit(:winner_name, :loser_name)
    end
end
