require 'json'

def load_secret
  f = File.open('google-10000-english-no-swears.txt')

  words = []
  while line = f.gets
    line = line.chomp
    words.push(line) if line.length in (5..12)
  end
  words.sample
end

def play(state: [], round: 1, secret: load_secret)
  puts 'Game starts!'
  puts 'Enter p datayour guess, a single letter or "save" to save the game'
  secret.each_char { state.push('_') } if state.empty?

  (round..8).each do |current_round|
    user_guess = nil
    until user_guess =~ /\A[a-zA-Z]+\z/
      print "#{state.join(' ')}\tguess #{current_round}/8: "
      user_guess = gets.chomp
    end

    if user_guess.downcase == secret
      puts "Correct! The secret was \"#{user_guess}\""
      break
    elsif user_guess == 'save'
      save(secret, state, current_round)
      raise SystemExit
    elsif user_guess.length == 1
      secret.each_char.with_index { |char, index| state[index] = user_guess if user_guess == char }
    end
  end
end

def save(secret, state, round)
  fname = "hangman-#{Time.now.to_i}"
  data = JSON.dump({ secret: secret, state: state, round: round })
  File.open(fname, 'w') { |f| f.puts data }
end

def load_save(fname)
  JSON.parse(File.read(fname), { symbolize_names: true })
end

def list_saves
  files = Dir.entries('.')
  files.filter { |fname| fname.start_with?('hangman-') }
end

load_saved_game = false
unless list_saves.empty?
  answer = ''
  until answer =~ /(y|n)/
    print 'Do you want to load saved game? (y/n): '
    answer = gets.chomp
  end
  load_saved_game = answer == 'y'
end

if load_saved_game
  puts 'You chose to load the game'
  list_saves.each_with_index do |fname, index|
    puts "#{index}: #{fname}"
  end
  print 'Select file: '
  fname_index = gets.chomp.to_i
  data = load_save(list_saves[fname_index])
  play(**data)
else
  play
end
