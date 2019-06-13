require 'features_helper'

RSpec.describe 'List games' do
  let(:repository) { GameRepository.new }
  before do
    repository.clear

    repository.create(title: 'Game One')
    repository.create(title: 'Game Two')
  end

  it 'displays each game on the page' do
    visit '/games'

    within '#games' do
      expect(page).to have_selector('.game', count: 2), 'Expected to find 2 games'
    end
  end
end