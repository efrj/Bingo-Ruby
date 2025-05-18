MAX_WINNERS_FILE = 'data/max_winners.txt'.freeze

def initialize_settings_files
  Dir.mkdir('data') unless Dir.exist?('data')
  File.write(MAX_WINNERS_FILE, '5') unless File.exist?(MAX_WINNERS_FILE)
end

def get_max_winners
  initialize_settings_files
  File.read(MAX_WINNERS_FILE).to_i
end

def set_max_winners(value)
  initialize_settings_files
  value = [1, [value.to_i, 20].min].max  # Garantir que o valor esteja entre 1 e 20
  File.write(MAX_WINNERS_FILE, value.to_s)
end
