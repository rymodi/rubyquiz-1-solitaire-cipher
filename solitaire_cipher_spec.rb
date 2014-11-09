require './solitaire_cipher'

RSpec.describe SolitaireCipher do

  describe SolitaireCipher::Cipher, '#encrypt' do
    it 'encrypts a message' do
      sc = SolitaireCipher::Cipher.new
      message = 'Code in Ruby, live longer!'

      encrypted = sc.encrypt(message)

      expect(encrypted).to eq('GLNCQ MJAFF FVOMB JIYCB')
    end

    it 'encrypts a message that needs "X" padding' do
      sc = SolitaireCipher::Cipher.new
      message = 'Welcome to RubyQuiz!'

      encrypted = sc.encrypt(message)

      expect(encrypted).to eq('ABVAW LWZSY OORYK DUPVH')
    end

  end

  describe SolitaireCipher::Cipher, '#decrypt' do
    it 'decrypts a message' do
      sc = SolitaireCipher::Cipher.new
      encrypted_message = 'GLNCQ MJAFF FVOMB JIYCB'

      decrypted = sc.decrypt(encrypted_message)

      expect(decrypted).to eq('CODEI NRUBY LIVEL ONGER')
    end
  end
end
