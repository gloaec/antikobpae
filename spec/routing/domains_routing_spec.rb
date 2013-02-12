require "spec_helper"

describe DomainsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/domains" }.should route_to(:controller => "domains", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/domains/new" }.should route_to(:controller => "domains", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/domains/1" }.should route_to(:controller => "domains", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/domains/1/edit" }.should route_to(:controller => "domains", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/domains" }.should route_to(:controller => "domains", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/domains/1" }.should route_to(:controller => "domains", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/domains/1" }.should route_to(:controller => "domains", :action => "destroy", :id => "1")
    end

  end
end
