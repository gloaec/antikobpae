require 'spec_helper'

describe DuplicateRangeController do

  describe "GET 'from_word'" do
    it "returns http success" do
      get 'from_word'
      response.should be_success
    end
  end

  describe "GET 'to_word'" do
    it "returns http success" do
      get 'to_word'
      response.should be_success
    end
  end

  describe "GET 'from_char'" do
    it "returns http success" do
      get 'from_char'
      response.should be_success
    end
  end

  describe "GET 'to_char'" do
    it "returns http success" do
      get 'to_char'
      response.should be_success
    end
  end

end
