require 'spec_helper'

describe "routes/new.html.erb" do
  before(:each) do
    assign(:route, stub_model(Route,
      :domain => nil
    ).as_new_record)
  end

  it "renders new route form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => routes_path, :method => "post" do
      assert_select "input#route_domain", :name => "route[domain]"
    end
  end
end
