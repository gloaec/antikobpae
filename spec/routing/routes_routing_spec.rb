require "spec_helper"

describe RoutesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/routes" }.should route_to(:controller => "routes", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/routes/new" }.should route_to(:controller => "routes", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/routes/1" }.should route_to(:controller => "routes", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/routes/1/edit" }.should route_to(:controller => "routes", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/routes" }.should route_to(:controller => "routes", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/routes/1" }.should route_to(:controller => "routes", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/routes/1" }.should route_to(:controller => "routes", :action => "destroy", :id => "1")
    end

  end
end
