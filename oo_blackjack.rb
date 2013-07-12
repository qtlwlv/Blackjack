
module Deal
  def deal_one
    deck.cards.pop
  end

  def add_card(new_card)
    hand << new_card
  end
end

module Rules
  DEALER_MUST_STAY = 17
  BLACKJACK_AMOUNT = 21

  def blackjack
    total == BLACKJACK_AMOUNT
  end

  def bust
    total > BLACKJACK_AMOUNT
  end
end



class Card
  attr_accessor :suit, :face

  def initialize(s, f)
    @suit = s
    @face = f
  end

  def output
    "#{face} of #{suit}"
  end

  def to_s
    output
  end

end



class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['Hearts', 'Diamonds', 'Spades', 'Clubs'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', 'Jack', 'Queen', 'King', 'Ace'].each do |face|
        @cards << Card.new(suit, face)
      end
    end

    shuffle
  end

  def shuffle
    cards.shuffle!
  end

end



class Dealer
  include Deal
  include Rules

  attr_accessor :name, :hand

  def initialize
    @name = 'Dealer'
    @hand = Array.new
  end

  def total
    face = hand.map{|card| card.face }

    total = 0
    face.each do |value|
      if value == "Ace"
        total += 11
      elsif value.to_i == 0 # J, Q, K
        total += 10
      else
        total += value.to_i
      end
    end

    face.select{|value| value == "Ace"}.count.times do
      total -= 10 if total > 21   #correct for Aces
    end

    total
  end

  def show_flop
    puts "#{name}'s Hand"
    puts "First card is face down"
    puts "#{hand[1]}"
  end


  def show_hand
    puts "#{name}'s Hand"
    hand.each do|card|
      puts "#{card}"
    end
    puts "#{name}'s total is #{total}"
  end

end



class Player < Dealer
  attr_accessor :name, :hand

  def initialize(n)
    @name = n
    @hand = Array.new
  end

  def show_flop
    show_hand
  end

end



class Blackjack
  include Deal
  include Rules

  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new('Travis')
    @dealer = Dealer.new
  end

  def set_player
    puts "What's your name"
    player.name = gets.chomp.capitalize
  end

  def deal_cards
    player.add_card(deal_one)
    dealer.add_card(deal_one)
    player.add_card(deal_one)
    dealer.add_card(deal_one)
  end

  def show_flop
    player.show_flop
    dealer.show_flop
  end

  def initial_card_sum
    if player.blackjack and dealer.blackjack
      puts "It's a push, both #{dealer.name} and #{player.name} have blackjack."
      dealer.show_hand
      play_again?
    elsif player.blackjack
      puts "Congratulations! Blackjack! #{player.name} wins!"
      play_again?
    elsif dealer.blackjack
      puts "Sorry, dealer hit blackjack. #{player.name} loses."
      dealer.show_hand
      play_again?
    end
  end

  def player_turn
    while true
      puts "What would you like to do #{player.name}? 1) Hit 2) Stay"
      response = gets.chomp
      if response == '1'
        hit_card = deal_one
        player.add_card(hit_card)
        puts "New card is #{hit_card}."
        puts "#{player.name}'s total is now #{player.total}"
      end

      if player.bust
        puts "Bust, #{player.name} loses."
        play_again?
      end

      if response == '2'
        puts "#{player.name} is staying on #{player.total}"
        break
      end
    end
  end

  def dealer_turn
    dealer.show_hand
    while true
      if dealer.total < DEALER_MUST_STAY
        puts "#{dealer.name} hits"
        hit_card = deal_one
        dealer.add_card(hit_card)
        puts "#{dealer.name}'s new card is #{hit_card}"
        puts "#{dealer.name}'s' total is now #{dealer.total}"
      elsif dealer.bust
        puts "#{dealer.name} busts.  #{player.name} wins!"
        play_again?
      else
        puts "#{dealer.name} is staying on #{dealer.total}"
        break
      end
    end
  end

  def who_won
    if player.total > dealer.total
      puts "Congratulations, #{player.name} wins!"
    elsif player.total < dealer.total
      puts "Sorry, #{player.name} loses."
    else
      puts "It's a push!"
    end
    play_again?
  end

  def play_again?
    puts "Would you like to play again? 1) yes 2) no, exit"
    if gets.chomp == '1'
      puts "Starting new game..."
      puts ""
      deck = Deck.new
      player.hand = Array.new
      dealer.hand = Array.new
      start
    else
      puts "Thank you for playing, goodbye."
      exit
    end
  end

  def start
    set_player
    deal_cards
    show_flop
    initial_card_sum
    player_turn
    dealer_turn
    who_won
  end

end



g = Blackjack.new
g.start


