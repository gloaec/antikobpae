require 'spec_helper'

describe SimilarityController do

  describe "GET 'is_exception'" do
    it "returns http success" do
      get 'is_exception'
      response.should be_success
    end
  end

  describe "GET 'is_validated'" do
    it "returns http success" do
      get 'is_validated'
      response.should be_success
    end
  end

end
