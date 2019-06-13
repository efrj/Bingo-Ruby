RSpec.describe Game do
  it 'can be initialized with attributes' do
    game = Game.new(title: 'Game One')
    expect(game.title).to eq('Game One')
  end
end