require 'spec_helper'

describe "routes/edit.html.erb" do
  before(:each) do
    @route = assign(:route, stub_model(Route,
      :new_record? => false,
      :domain => nil
    ))
  end

  it "renders the edit route form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => route_path(@route), :method => "post" do
      assert_select "input#route_domain", :name => "route[domain]"
    end
  end
end
