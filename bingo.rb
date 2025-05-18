require 'erb'
require 'webrick'
require 'rack'
require 'securerandom'
require 'json'

DRAWN_NUMBERS_FILE = 'data/drawn_numbers.txt'.freeze
WINNERS_FILE = 'data/winners.txt'.freeze
MAX_WINNERS_FILE = 'data/max_winners.txt'.freeze
CARDS_FILE = 'data/cards.json'.freeze

def initialize_data_files
  Dir.mkdir('data') unless Dir.exist?('data')
  File.write(DRAWN_NUMBERS_FILE, '') unless File.exist?(DRAWN_NUMBERS_FILE)
  File.write(WINNERS_FILE, '') unless File.exist?(WINNERS_FILE)
  File.write(MAX_WINNERS_FILE, '5') unless File.exist?(MAX_WINNERS_FILE)
  initialize_cards_file
end

def card_numbers(start_number, end_number)
  (start_number..end_number).to_a.shuffle[0, 5]
end

def get_drawn_numbers
  File.exist?(DRAWN_NUMBERS_FILE) ? File.read(DRAWN_NUMBERS_FILE).split(',').map(&:to_i) : []
end

def get_max_winners
  initialize_data_files
  File.read(MAX_WINNERS_FILE).to_i
end

def set_max_winners(value)
  initialize_data_files
  value = [1, [value.to_i, 20].min].max
  File.write(MAX_WINNERS_FILE, value.to_s)
end

def draw_number
  winners = File.exist?(WINNERS_FILE) ? File.read(WINNERS_FILE).split("\n").map(&:strip).reject(&:empty?) : []
  max_winners = get_max_winners

  if winners.length >= max_winners
    return false, "Limite de vencedores atingido! Jogo finalizado."
  end
  
  drawn_numbers = get_drawn_numbers
  available_numbers = (1..75).to_a - drawn_numbers

  if available_numbers.empty?
    return false, "Todos os números já foram sorteados!"
  end

  new_number = available_numbers.sample
  File.write(DRAWN_NUMBERS_FILE, (drawn_numbers + [new_number]).join(','))
  
  return new_number, nil
end

def reset_game
  File.write(DRAWN_NUMBERS_FILE, '')
  File.write(WINNERS_FILE, '')
  # If you want to generate new cards at each reset, uncomment the line below
  # File.delete(CARDS_FILE) if File.exist?(CARDS_FILE)
end

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

def check_winner(card_id, player_name)
  File.write(WINNERS_FILE, '') unless File.exist?(WINNERS_FILE)

  winners = File.exist?(WINNERS_FILE) ? File.read(WINNERS_FILE).split("\n").map(&:strip).reject(&:empty?) : []

  max_winners = get_max_winners
  if winners.length >= max_winners
    return false
  end
  
  if winners.any? { |winner| winner.include?("Card ##{card_id} - #{player_name}") }
    return true 
  end

  winner_entry = "Card ##{card_id} - #{player_name} - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  File.write(WINNERS_FILE, (winners + [winner_entry]).push('').join("\n"))
  return true
end

def bingo_card(card_id)
  cards = load_cards
  card_data = cards[card_id.to_s]
  
  player_name = card_data["player"]
  avatar_icon = card_data["avatar"]
  
  b_numbers = card_data["numbers"]["b"]
  i_numbers = card_data["numbers"]["i"]
  n_numbers = card_data["numbers"]["n"]
  g_numbers = card_data["numbers"]["g"]
  o_numbers = card_data["numbers"]["o"]
  
  drawn_numbers = get_drawn_numbers

  html = "<div class='bingo-card' id='card-#{card_id}' data-player='#{player_name}'>"
  html += "<div class='player-info'>"
  html += "<i class='fas fa-#{avatar_icon}'></i> "
  html += "<span class='player-name'>#{player_name}</span>"
  html += "</div>"
  html += "<table class='table'>"
  html += "<thead><tr><th>B</th><th>I</th><th>N</th><th>G</th><th>O</th></tr></thead>"
  html += "<tbody>"

  card_all_numbers = []
  
  # Row 1
  html += "<tr>"
  html += "<td class='#{drawn_numbers.include?(b_numbers[0]) ? 'marked' : ''}' data-number='#{b_numbers[0]}'>#{format('%02d', b_numbers[0])}</td>"
  html += "<td class='#{drawn_numbers.include?(i_numbers[0]) ? 'marked' : ''}' data-number='#{i_numbers[0]}'>#{format('%02d', i_numbers[0])}</td>"
  html += "<td class='#{drawn_numbers.include?(n_numbers[0]) ? 'marked' : ''}' data-number='#{n_numbers[0]}'>#{format('%02d', n_numbers[0])}</td>"
  html += "<td class='#{drawn_numbers.include?(g_numbers[0]) ? 'marked' : ''}' data-number='#{g_numbers[0]}'>#{format('%02d', g_numbers[0])}</td>"
  html += "<td class='#{drawn_numbers.include?(o_numbers[0]) ? 'marked' : ''}' data-number='#{o_numbers[0]}'>#{format('%02d', o_numbers[0])}</td>"
  html += "</tr>"
  
  # Row 2
  html += "<tr>"
  html += "<td class='#{drawn_numbers.include?(b_numbers[1]) ? 'marked' : ''}' data-number='#{b_numbers[1]}'>#{format('%02d', b_numbers[1])}</td>"
  html += "<td class='#{drawn_numbers.include?(i_numbers[1]) ? 'marked' : ''}' data-number='#{i_numbers[1]}'>#{format('%02d', i_numbers[1])}</td>"
  html += "<td class='#{drawn_numbers.include?(n_numbers[1]) ? 'marked' : ''}' data-number='#{n_numbers[1]}'>#{format('%02d', n_numbers[1])}</td>"
  html += "<td class='#{drawn_numbers.include?(g_numbers[1]) ? 'marked' : ''}' data-number='#{g_numbers[1]}'>#{format('%02d', g_numbers[1])}</td>"
  html += "<td class='#{drawn_numbers.include?(o_numbers[1]) ? 'marked' : ''}' data-number='#{o_numbers[1]}'>#{format('%02d', o_numbers[1])}</td>"
  html += "</tr>"
  
  # Row 3 (with free space in the middle)
  html += "<tr>"
  html += "<td class='#{drawn_numbers.include?(b_numbers[2]) ? 'marked' : ''}' data-number='#{b_numbers[2]}'>#{format('%02d', b_numbers[2])}</td>"
  html += "<td class='#{drawn_numbers.include?(i_numbers[2]) ? 'marked' : ''}' data-number='#{i_numbers[2]}'>#{format('%02d', i_numbers[2])}</td>"
  html += "<td class='free-space marked' data-number='free'>@</td>"
  html += "<td class='#{drawn_numbers.include?(g_numbers[2]) ? 'marked' : ''}' data-number='#{g_numbers[2]}'>#{format('%02d', g_numbers[2])}</td>"
  html += "<td class='#{drawn_numbers.include?(o_numbers[2]) ? 'marked' : ''}' data-number='#{o_numbers[2]}'>#{format('%02d', o_numbers[2])}</td>"
  html += "</tr>"
  
  # Row 4
  html += "<tr>"
  html += "<td class='#{drawn_numbers.include?(b_numbers[3]) ? 'marked' : ''}' data-number='#{b_numbers[3]}'>#{format('%02d', b_numbers[3])}</td>"
  html += "<td class='#{drawn_numbers.include?(i_numbers[3]) ? 'marked' : ''}' data-number='#{i_numbers[3]}'>#{format('%02d', i_numbers[3])}</td>"
  html += "<td class='#{drawn_numbers.include?(n_numbers[2]) ? 'marked' : ''}' data-number='#{n_numbers[2]}'>#{format('%02d', n_numbers[2])}</td>"
  html += "<td class='#{drawn_numbers.include?(g_numbers[3]) ? 'marked' : ''}' data-number='#{g_numbers[3]}'>#{format('%02d', g_numbers[3])}</td>"
  html += "<td class='#{drawn_numbers.include?(o_numbers[3]) ? 'marked' : ''}' data-number='#{o_numbers[3]}'>#{format('%02d', o_numbers[3])}</td>"
  html += "</tr>"
  
  # Row 5
  html += "<tr>"
  html += "<td class='#{drawn_numbers.include?(b_numbers[4]) ? 'marked' : ''}' data-number='#{b_numbers[4]}'>#{format('%02d', b_numbers[4])}</td>"
  html += "<td class='#{drawn_numbers.include?(i_numbers[4]) ? 'marked' : ''}' data-number='#{i_numbers[4]}'>#{format('%02d', i_numbers[4])}</td>"
  html += "<td class='#{drawn_numbers.include?(n_numbers[3]) ? 'marked' : ''}' data-number='#{n_numbers[3]}'>#{format('%02d', n_numbers[3])}</td>"
  html += "<td class='#{drawn_numbers.include?(g_numbers[4]) ? 'marked' : ''}' data-number='#{g_numbers[4]}'>#{format('%02d', g_numbers[4])}</td>"
  html += "<td class='#{drawn_numbers.include?(o_numbers[4]) ? 'marked' : ''}' data-number='#{o_numbers[4]}'>#{format('%02d', o_numbers[4])}</td>"
  html += "</tr>"

  html += "</tbody></table>"

  card_all_numbers = b_numbers + i_numbers + n_numbers + g_numbers + o_numbers

  is_winner = check_winning_pattern(card_all_numbers, drawn_numbers, card_id, player_name)
  html += "<div class='winner-badge'>BINGO!</div>" if is_winner

  html += "</div>"
  html
end

def check_winning_pattern(card_numbers, drawn_numbers, card_id = nil, player_name = nil)
  drawn_numbers << 'free'

  complete_card = card_numbers.all? { |num| drawn_numbers.include?(num) }

  return false unless complete_card

  return true if card_id.nil? || player_name.nil?

  winners_data = File.read(WINNERS_FILE) rescue ''
  existing_winners = winners_data.split("\n").map(&:strip).reject(&:empty?)

  return true if existing_winners.any? { |winner| winner.include?("Card ##{card_id}") }

  current_winners_count = existing_winners.length
  max_winners = get_max_winners

  if current_winners_count < max_winners
    check_winner(card_id, player_name)
    return true
  end

  return false
end

class BingoServlet < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server, *options)
    super
    
    @player_names = [
      'Ana Silva', 'Bruno Oliveira', 'Carlos Santos', 'Débora Lima',
      'Eduardo Pereira', 'Fátima Costa', 'Gabriel Martins', 'Helena Cruz',
      'Igor Almeida', 'Juliana Souza', 'Kleber Ramos', 'Larissa Gomes',
      'Marcelo Dias', 'Natália Ferreira', 'Otávio Ribeiro', 'Paula Barbosa',
      'Quentin Tarantino', 'Roberta Carvalho', 'Sérgio Mendes', 'Talita Rocha'
    ]

    @avatar_icons = [
      'user', 'user-tie', 'user-graduate', 'user-ninja', 'user-astronaut',
      'user-secret', 'user-md', 'user-nurse', 'user-shield', 'user-alt'
    ]
    
    initialize_data_files
  end
  
  def do_GET(request, response)
    initialize_data_files

    @max_winners = get_max_winners

    template = ERB.new(File.read('view/template/index.erb'))
    response.body = template.result(binding)
    response.status = 200
    response['Content-Type'] = 'text/html'
  end
  
  def do_POST(request, response)
    initialize_data_files
    
    result_html = ""
    
    if request.query['winner_card'] && request.query['winner_name']
      card_id = request.query['winner_card']
      player_name = request.query['winner_name']
      success = check_winner(card_id, player_name)
      if success
        result_html = "Vencedor registrado com sucesso"
      else
        result_html = "<div class='alert alert-warning mt-3'>Limite de ganhadores atingido!</div>"
      end
    elsif request.query['draw']
      if request.query['max_winners'] 
        set_max_winners(request.query['max_winners'])
      end
      
      new_number, error_msg = draw_number
      if new_number
        result_html = "<div class='alert alert-success mt-3'>Número sorteado: <strong>#{new_number}</strong></div><script>setTimeout(function(){ location.reload(); }, 2000);</script>"
      else
        alert_class = error_msg.include?("Limite de vencedores") ? "alert-info" : "alert-warning"
        result_html = "<div class='alert #{alert_class} mt-3'>#{error_msg}</div>"
      end
    elsif request.query['reset']
      reset_game
      result_html = "<div class='alert alert-info mt-3'>Jogo reiniciado!</div><script>setTimeout(function(){ location.reload(); }, 1000);</script>"
    elsif request.query['update_settings']
      if request.query['max_winners']
        set_max_winners(request.query['max_winners'])
        result_html = "<div class='alert alert-success mt-3'>Configurações atualizadas!</div>"
      end
    end

    @max_winners = get_max_winners

    template = ERB.new(File.read('view/template/index.erb'))
    
    @message = result_html
    response.body = template.result(binding)
    response.status = 200
    response['Content-Type'] = 'text/html'
  end
end

server = WEBrick::HTTPServer.new(Port: 3001)
server.mount('/', BingoServlet)

server.mount('/public', WEBrick::HTTPServlet::FileHandler, 'public')

trap('INT') { server.shutdown }

puts "Bingo server iniciado em http://localhost:3001"
server.start
