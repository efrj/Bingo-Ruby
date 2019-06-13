RSpec.describe Web::Controllers::Games::Index do
  let(:action) { described_class.new }
  let(:params) { Hash[] }
  let(:repository) { GameRepository.new }

  before do
    repository.clear

    @game = repository.create(title: 'Game One')
  end

  it 'is successful' do
    response = action.call(params)
    expect(response[0]).to eq(200)
  end

  it 'exposes all games' do
    action.call(params)
    expect(action.exposures[:games]).to eq([@game])
  end
end