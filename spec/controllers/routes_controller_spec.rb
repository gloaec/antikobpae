require 'spec_helper'

describe RoutesController do

  def mock_route(stubs={})
    (@mock_route ||= mock_model(Route).as_null_object).tap do |route|
      route.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all routes as @routes" do
      Route.stub(:all) { [mock_route] }
      get :index
      assigns(:routes).should eq([mock_route])
    end
  end

  describe "GET show" do
    it "assigns the requested route as @route" do
      Route.stub(:find).with("37") { mock_route }
      get :show, :id => "37"
      assigns(:route).should be(mock_route)
    end
  end

  describe "GET new" do
    it "assigns a new route as @route" do
      Route.stub(:new) { mock_route }
      get :new
      assigns(:route).should be(mock_route)
    end
  end

  describe "GET edit" do
    it "assigns the requested route as @route" do
      Route.stub(:find).with("37") { mock_route }
      get :edit, :id => "37"
      assigns(:route).should be(mock_route)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created route as @route" do
        Route.stub(:new).with({'these' => 'params'}) { mock_route(:save => true) }
        post :create, :route => {'these' => 'params'}
        assigns(:route).should be(mock_route)
      end

      it "redirects to the created route" do
        Route.stub(:new) { mock_route(:save => true) }
        post :create, :route => {}
        response.should redirect_to(route_url(mock_route))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved route as @route" do
        Route.stub(:new).with({'these' => 'params'}) { mock_route(:save => false) }
        post :create, :route => {'these' => 'params'}
        assigns(:route).should be(mock_route)
      end

      it "re-renders the 'new' template" do
        Route.stub(:new) { mock_route(:save => false) }
        post :create, :route => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested route" do
        Route.should_receive(:find).with("37") { mock_route }
        mock_route.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :route => {'these' => 'params'}
      end

      it "assigns the requested route as @route" do
        Route.stub(:find) { mock_route(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:route).should be(mock_route)
      end

      it "redirects to the route" do
        Route.stub(:find) { mock_route(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(route_url(mock_route))
      end
    end

    describe "with invalid params" do
      it "assigns the route as @route" do
        Route.stub(:find) { mock_route(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:route).should be(mock_route)
      end

      it "re-renders the 'edit' template" do
        Route.stub(:find) { mock_route(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested route" do
      Route.should_receive(:find).with("37") { mock_route }
      mock_route.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the routes list" do
      Route.stub(:find) { mock_route }
      delete :destroy, :id => "1"
      response.should redirect_to(routes_url)
    end
  end

end
