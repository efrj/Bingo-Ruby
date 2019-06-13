RSpec.describe Web::Views::Games::Index do
  let(:exposures) { Hash[games: []] }
  let(:template)  { Hanami::View::Template.new('apps/web/templates/games/index.html.erb') }
  let(:view)      { described_class.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #games' do
    expect(view.games).to eq(exposures.fetch(:games))
  end

  context 'when there are no games' do
    it 'shows a placeholder message' do
      expect(rendered).to include('<p class="placeholder">There are no games yet.</p>')
    end
  end

  context 'when there are games' do
    let(:game1)     { Game.new(title: 'Game One') }
    let(:game2)     { Game.new(title: 'Game Two') }
    let(:exposures) { Hash[games: [game1, game2]] }

    it 'lists them all' do
      expect(rendered.scan(/class="game"/).length).to eq(2)
      expect(rendered).to include('Game One')
      expect(rendered).to include('Game Two')
    end

    it 'hides the placeholder message' do
      expect(rendered).to_not include('<p class="placeholder">There are no games yet.</p>')
    end
  end
end