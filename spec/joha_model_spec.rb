require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "JohaModel" do
  before(:each) do
    @joha_class_name = "JohaTestClass"
    @joha_user = "joha_test_user"
    @jm = JohaModel.new(@joha_class_name, @joha_user)
  end

  it "initializes" do
    @jm.should_not == nil
    @jm.tinkit_class.should respond_to :myGlueEnv
    @jm.tinkit_class.name.should == "Tinkit::#{@joha_class_name}"
  end
end

describe "Using Sample Data" do
  before(:each) do
    @joha_class_name = "JohaTestClass"
    @joha_user = "joha_test_user"
    @jm = JohaModel.new(@joha_class_name, @joha_user)
    @best_tree_roots = ["just_a_label", "c"]
    @node1_params = {:id => "new1", :label => "new1 node",
                     :description => "A new1 description",
                     :links => {"http://some.url" => "Url Label"},
                     :parents => ["c"],
                     :notes => ["new1 note"],
                     :update_log => ["created from rspec"] }

   #delete new nodes
  end

  it "has grapher when initialized" do
    @jm.grapher.should_not == nil
    @jm.grapher.should be_a JsivtGrapher
  end

  it "guesses at best tree roots" do
    @jm.graphs.size.should == 2
    @jm.graphs_with_roots.keys.should == @best_tree_roots
  end

  it "returns tree graph" do
    @best_tree_roots.each do |root|
     p @jm.tree_graph(root)
    end
  end

  it "can create a new node" do
    @jm.create_node(@node1_params)
  end
end
