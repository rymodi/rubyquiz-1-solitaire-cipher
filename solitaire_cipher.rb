#!/usr/bin/env ruby

module SolitaireCipher
  
  class Cipher
    attr_reader :keystream_generator

    def initialize(keystream_generator: nil)
      @keystream_generator = keystream_generator || DeckKeystreamGenerator.new
    end

    def encrypt(message)
      combine_with_keystream(message) do |c, k|
        sum = c + k - 128
        ((sum % 26 if sum > 26) || sum) + 64
      end
    end

    def decrypt(message)
      combine_with_keystream(message) do |c, k|
        diff = c - k
        ((diff + 26 if diff < 1) || diff) + 64
      end
    end

    def prepare(message)
      # Remove non-alpha and convert to all caps
      prepared = message.upcase.tr('^A-Z', '')

      # Group into 5 character blocks with 'X' padding at the end if needed
      i = 5
      while i < (prepared.length - 1)
        prepared.insert(i, ' ')
        i += 6
      end
      prepared << 'X' * (5 - prepared.split(' ').last.size)
    end

  private

    # Takes +combiner+, a block that should take bytes for a message letter
    # (when A-Z) and return the value for the character to be appended to
    # the output string
    # 
    # @note Credit to Niklas Frykholm for the idea behind the +combiner+ block
    # abstraction, which allows for the DRYing up of #encrypt and #decrypt
    def combine_with_keystream(message, &combiner)
      prepared = prepare(message)
      
      keystream_generator.reset!
      processed = ""
      prepared.each_char do |c|
        if c =~ /[A-Z]/
          keystream_letter = keystream_generator.generate_letter 
          processed << combiner.call(c.ord, keystream_letter.ord)
        else
          processed << c
        end
      end

      processed
    end

  end
    
  class DeckKeystreamGenerator
    attr_reader :keyed_deck
    attr_reader :deck
    
    def initialize(keyed_deck=nil)
      @keyed_deck = keyed_deck || Deck.new
      reset!
    end

    def reset!
      @deck = keyed_deck.dup
    end

    def generate_letter
      deck.move_card!('A', 1)
      deck.move_card!('B', 2)
      deck.joker_triple_cut!
      deck.bottom_count_cut!
      output_card = deck.output_card
      # Run again if card was joker, i.e., has no letter value
      card_to_letter(output_card) || generate_letter
    end

  private
    
    # @note Returns nil for Jokers
    def card_to_letter(card)
      (((card - 1) % 26) + 65).chr rescue nil
    end

  end

  class Deck
    attr_reader :cards
    
    def initialize
      @cards = (1..52).to_a << 'A' << 'B'
    end
    
    def move_card!(card, n)
      n.times do
        i = cards.index(card)
        cards.delete_at(i)
        i_new = i == cards.size ? 1 : i + 1
        cards.insert(i_new, card)
      end
    end

    def joker_triple_cut!
      i1, i2 = *[cards.index("A"), cards.index("B")].sort
      # @note Credit Thomas Leitner for #replace and range wrangling
      @cards.replace( [cards[(i2 + 1)..-1], 
                       cards[i1..i2],
                       cards[0...i1]].flatten )
    end

    def bottom_count_cut!
      bottom_card_value = card_value(cards.last)
      cut_cards = cards.slice!(0, bottom_card_value)
      cards.insert(cards.size - 1, *cut_cards)
    end

    def output_card
      top_card_value = card_value(cards.first)
      cards[top_card_value]
    end
    
  private

    def card_value(card)
      non_integer_card_to_value_map = {'A' => 53, 'B' => 53}
      card.is_a?(Integer) ? card : non_integer_card_to_value_map[card]
    end

  end

end
