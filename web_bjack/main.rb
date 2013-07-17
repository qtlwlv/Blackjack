require 'rubygems'
require 'sinatra'


set :sessions, true

helpers do
  def total(hand)
    arr = hand.map{|face| face[1]}

    total = 0
    arr.each do |face|
      if face == "A"
        total += 11
      elsif face.to_i == 0
        total += 10
      else
        total += face.to_i
      end
    end

    arr.select{|face| face == "A"}.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def jpgcard(hand)
    arr0 = hand.map{|suit| suit[0]}

    arr0.each do |suit|
      if suit == "H"
        suit.replace "hearts_"
      elsif suit == "C"
        suit.replace "clubs_"
      elsif suit == "D"
        suit.replace "diamonds_"
      elsif suit == "S"
        suit.replace "spades_"
      end
    end

    arr1 = hand.map{|face| face[1]}

    arr1.each do |face|
      if face == "A"
        face.replace "ace.jpg"
      elsif face == "K"
        face.replace "king.jpg"
      elsif face == "Q"
        face.replace "queen.jpg"
      elsif face == "J"
        face.replace "jack.jpg"
      else
        face.replace face.to_s + ".jpg"
      end
    end

  end
end

before do
  @show_hit_or_stay_buttons = true
  @show_play_again_or_exit_buttons = false
  @hand_compare = false
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  suit = ['H', 'D', 'C', 'S']
  face = ['2', '3', '4', '5', '6', '7', '8', '9', 'J', 'Q', 'K', 'A']
  session[:deck] = suit.product(face).shuffle!

  session[:d_hand] = Array.new
  session[:p_hand] = Array.new

  session[:d_hand] << session[:deck].pop
  session[:p_hand] << session[:deck].pop
  session[:d_hand] << session[:deck].pop
  session[:p_hand] << session[:deck].pop

  if total(session[:p_hand]) == 21 and total(session[:d_hand]) == 21
    @success = "Push, both Dealer and Player have Blackjack"
    @show_hit_or_stay_buttons = false
    @hand_compare = true
    @show_play_again_or_exit_buttons = true
  elsif total(session[:p_hand]) == 21
    @success = "You hit Blackjack! You win!"
    @show_hit_or_stay_buttons = false
    @hand_compare = true
    @show_play_again_or_exit_buttons = true
  elsif total(session[:d_hand]) == 21
    @error = "Sorry, Dealer hit Blackjack. You lose."
    @show_hit_or_stay_buttons = false
    @hand_compare = true
    @show_play_again_or_exit_buttons = true
  end

  erb :game
end


post '/game/player/hit' do
  session[:p_hand] << session[:deck].pop
  if total(session[:p_hand]) > 21
    @error = "Sorry, you bust."
    @show_hit_or_stay_buttons = false
    @show_play_again_or_exit_buttons = true
  end

  erb :game
end


get '/game/dealer' do
  @show_hit_or_stay_buttons = false
  @hand_compare = true
  while true
    if total(session[:d_hand]) < 17
      session[:d_hand] << session[:deck].pop
      @hand_compare = true
    elsif total(session[:d_hand]) > 21
      @success = "Dealer Busts! You Win!"
      @show_play_again_or_exit_buttons = true
      break
    else
      break
    end
  end

  redirect '/game/hand_compare'
  erb :game
end


get '/game/hand_compare' do
  @show_hit_or_stay_buttons = false
  @hand_compare = true
    if total(session[:d_hand]) > 21
      @success = "Dealer Busts! You Win!"
      @show_play_again_or_exit_buttons = true
    elsif total(session[:d_hand]) > total(session[:p_hand])
      @error = "Sorry, you lose. Dealer has greater hand."
      @show_play_again_or_exit_buttons = true
    elsif total(session[:d_hand]) == total(session[:p_hand])
      @success = "Its a push"
      @show_play_again_or_exit_buttons = true
    else
      @success = "You Win!"
      @show_play_again_or_exit_buttons = true
    end

  erb :game
end

