# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  rating     :integer          default(0), not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_players_on_name    (name)
#  index_players_on_rating  (rating)
#

require 'rails_helper'

describe Player do
  #it { should have_many(:won_games).with_foreign_key('winner_id').class_name('Game') }
  #it { should have_many(:lost_games).with_foreign_key('loser_id').class_name('Game') }

  #it { should validate_presence_of :name }
  #it { should validate_presence_of :rating }

  let(:id) { 1 }
  let(:name) { 'player name' }
  let(:rating) { 50 }

  subject { described_class.new(id: id, name: name, rating: rating) }

  describe 'updating rating methods' do
    let(:change_in_rating) { 25 }

    describe '#add_rating!' do
      let(:new_rating) { rating + change_in_rating }

      it 'adds rating to user' do
        subject.add_rating!(change_in_rating)
        expect(subject.reload.rating).to eq(new_rating)
      end
    end

    describe '#subtract_rating!' do
      let(:new_rating) { rating - change_in_rating }

      it 'subtracts rating from user' do
        subject.subtract_rating!(change_in_rating)
        expect(subject.reload.rating).to eq(new_rating)
      end
    end
  end

  describe '#games' do
    let(:games) { double 'games' }
    let(:ordered_games) { double 'ordered games' }

    before do
      allow(Game).to receive(:for_player).with(id) { games }
      allow(games).to receive(:most_recent) { ordered_games }
    end

    it 'should know its played games' do
      expect(subject.games).to eq(ordered_games)
    end
  end
end
