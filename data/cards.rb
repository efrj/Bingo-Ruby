CARDS_FILE = 'data/cards.json'.freeze
require 'json'

def initialize_cards_file
  unless File.exist?(CARDS_FILE)
    cards = generate_initial_cards(20)
    save_cards(cards)
  end
end

def generate_initial_cards(count)
  cards = {}
  count.times do |i|
    card_id = (i + 1).to_s
    player_index = rand(@player_names.length)
    avatar_index = rand(@avatar_icons.length)
    
    b_numbers = card_numbers(1, 15)
    i_numbers = card_numbers(16, 30)
    n_numbers = card_numbers(31, 45)
    g_numbers = card_numbers(46, 60)
    o_numbers = card_numbers(61, 75)
    
    card_data = {
      "id" => card_id,
      "player" => @player_names[player_index],
      "avatar" => @avatar_icons[avatar_index],
      "numbers" => {
        "b" => b_numbers,
        "i" => i_numbers,
        "n" => n_numbers,
        "g" => g_numbers,
        "o" => o_numbers
      }
    }
    
    cards[card_id] = card_data
  end
  cards
end

def load_cards
  initialize_cards_file
  JSON.parse(File.read(CARDS_FILE))
end

def save_cards(cards)
  File.write(CARDS_FILE, JSON.pretty_generate(cards))
end
