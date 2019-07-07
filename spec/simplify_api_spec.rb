# frozen_string_literal: false

require 'simplify_api'

describe SimplifyApi do
  describe "without attributes" do
    before(:all) do
      class Test
        include SimplifyApi
      end
    end

    subject { Test.new }

    it "should work with no attributes" do
      expect(subject.class).to eq Test
    end

    it "should accept adhoc parameters" do
      subject.name = "João da Silva"

      expect(subject.name).to eq "João da Silva"
      expect(subject).to respond_to :name 
      expect(Test.attributes).to include(:name)
    end
  end

  describe "with attributes" do
    before(:all) do
      class Test
        include SimplifyApi
        attribute :name, String, mandatory: true
        attribute :surname, String
        attribute :country, String, default: "Brazil"
        attribute :is_admin, values: [true, false], default: false
        attribute :groups, [String]
      end
    end

    it "should fullfil class description" do
      subject = Test.new(name: "João da Silva")

      expect{ Test.new }.to raise_error ArgumentError
      expect(subject).to respond_to :name
      expect(subject).to respond_to :surname
      expect(subject).to respond_to :country
      expect(subject.name).to eq "João da Silva"
      expect(subject.surname).to eq nil
      expect(subject.country).to eq "Brazil"
    end

    it "should not accept value out of list" do
      subject = Test.new(name: "João da Silva")

      expect{ Test.new(name: "João da Silva", is_admin: 1) }.to raise_error ArgumentError
      expect{ subject.is_admin = 1 }.to raise_error ArgumentError
    end

    it "should accept adhoc parameters" do
      subject = Test.new(name: "João da Silva")
      subject.email = "joao@mailinator.com"

      expect(subject).to respond_to :email
      expect(subject.email).to eq "joao@mailinator.com"
      expect(Test.attributes).to include(:email)
    end


    it "should accept array of parameters" do
      subject = Test.new(name: "João da Silva", groups: ["Leadership", "Apprentice"])
      subject.languages = ["Portuguese", "English", "Spanish"]

      expect(subject.groups).to have(2).groups
      expect(subject.languages).to have(3).languages
    end

    it "should be instatiated with json" do
      json_value = JSON.parse(%q({ "name": "John Doe", "country": "USA", "email": "joedoe@mailinator.com" }))
      subject = Test.new(json_value)

      expect(subject.name).to eq "John Doe"
      expect(subject.country).to eq "USA"
      expect(subject.email).to eq "joedoe@mailinator.com"
    end

    it "should be instatiated with json (even complex ones)" do
      json_value = JSON.parse(%q({ 
        "name": "John Doe", 
        "country": "USA", 
        "email": "joedoe@mailinator.com",
        "languages": [
          "English",
          "German" ]
      }))

      puts "JSON: #{json_value}"
      subject = Test.new(json_value)

      expect(subject.name).to eq "John Doe"
      expect(subject.country).to eq "USA"
      expect(subject.email).to eq "joedoe@mailinator.com"
      expect(subject.languages).to have(2).languages
    end
  end
end
