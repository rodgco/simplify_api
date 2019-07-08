# frozen_string_literal: false

require 'simplify_api'

describe SimplifyApi do
  describe 'without attributes' do
    before(:all) do
      class Test
        include SimplifyApi
      end
    end

    subject { Test.new }

    it 'should work with no attributes' do
      expect(subject.class).to eq Test
    end

    it 'should accept adhoc parameters' do
      subject.name = 'João da Silva'

      expect(subject.name).to eq 'João da Silva'
      expect(subject).to respond_to :name 
      expect(Test.attributes).to include(:name)
    end
  end

  describe 'with attributes' do
    before(:all) do
      class Test
        include SimplifyApi
        attribute :name, String, mandatory: true
        attribute :surname, String
        attribute :country, String, default: 'Brazil'
        attribute :is_admin, values: [true, false], default: false
        attribute :groups, [String]
      end
    end

    it 'should fullfil class description' do
      subject = Test.new(name: 'João da Silva')

      expect(Test.new.valid?).to be false
      expect(subject).to respond_to :name
      expect(subject).to respond_to :surname
      expect(subject).to respond_to :country
      expect(subject.name).to eq 'João da Silva'
      expect(subject.surname).to eq nil
      expect(subject.country).to eq 'Brazil'
    end

    it 'should not accept value out of list' do
      subject = Test.new(name: 'João da Silva')

      expect{ Test.new(name: 'João da Silva', is_admin: 1) }.to raise_error ArgumentError
      expect{ subject.is_admin = 1 }.to raise_error ArgumentError
    end

    it 'should accept adhoc parameters' do
      subject = Test.new(name: 'João da Silva')
      subject.email = 'joao@mailinator.com'

      expect(subject).to respond_to :email
      expect(subject.email).to eq 'joao@mailinator.com'
      expect(Test.attributes).to include(:email)
    end


    it 'should accept array of parameters' do
      subject = Test.new(name: 'João da Silva', groups: ['Leadership', 'Apprentice'])
      subject.languages = ['Portuguese', 'English', 'Spanish']

      expect(subject.groups).to have(2).groups
      expect(subject.languages).to have(3).languages
    end

    it 'should be instatiated with json' do
      json_value = JSON.parse('{ "name": "John Doe", "country": "USA", "email": "joedoe@mailinator.com" }')
      subject = Test.new(json_value)

      expect(subject.name).to eq 'John Doe'
      expect(subject.country).to eq 'USA'
      expect(subject.email).to eq 'joedoe@mailinator.com'
    end

    it 'should be instatiated with json (even complex ones)' do
      json_value = JSON.parse('{
        "name": "John Doe",
        "country": "USA",
        "email": "joedoe@mailinator.com",
        "languages": [
          "English",
          "German" ]
      }')
      subject = Test.new(json_value)

      expect(subject.name).to eq 'John Doe'
      expect(subject.country).to eq 'USA'
      expect(subject.email).to eq 'joedoe@mailinator.com'
      expect(subject.languages).to have(2).languages
    end
  end

  describe 'with nested classes' do
    before(:all) do
      class Location
        include SimplifyApi
        attribute :title, String, mandatory: true
        attribute :address, String
        attribute :city, String
      end

      class User
        include SimplifyApi
        attribute :name, String, mandatory: true
        attribute :locations, [Location]
      end
    end

    it 'should instatiate nested classes from JSON' do
      json_value = JSON.parse('{
        "name": "John Doe",
        "locations": [
          { "title": "Home", "address": "Elm Street", "city": "New York" },
          { "title": "Office", "address": "House Street", "city": "Washington DC" }
        ]
      }')
      subject = User.new(json_value)

      expect(subject.name).to eq 'John Doe'
      expect(subject.locations).to have(2).locations
      expect(subject.locations[0].class).to be Location
      expect(subject.locations[0].title).to eq 'Home'
      expect(subject.locations[1].title).to eq 'Office'
    end
  end
end
