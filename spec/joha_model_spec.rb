require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'json'


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
                     :history => ["created from rspec"] }

    @node_ids_in_different_graphs = ["a", "c"]

   #delete new nodes
  end

  it "can select a particular digraph" do
   node1_id = @node_ids_in_different_graphs.first
   first_graph = @jm.set_current_digraph(node1_id)
   first_graph.should == @jm.current_digraph
   first_graph.vertices.should include node1_id

   node2_id = @node_ids_in_different_graphs.last
   last_graph = @jm.set_current_digraph(node1_id)
   last_graph.should == @jm.current_digraph
   last_graph.vertices.should include node1_id 
  end

  it "can find all descendant data" do
    desc_data1 = @jm.find_all_descendant_data("c", :id)
    desc_data1.should == {:id=>{"c"=>"c", "cc"=>"cc"}}

    desc_data2 = @jm.find_all_descendant_data("c", :label)
    desc_data2.should == {:label=>{"c"=>"label_c", "cc"=>"label_cc"}}
    
    desc_data3 = @jm.find_all_descendant_data("cc", :id)
    desc_data3.should == {:id=>{}}

    desc_data4 = @jm.find_all_descendant_data("a", :parents)
    desc_data4.should == {:parents => {"a"=>["aa"], 
                                       "ac"=>["a"],
                                       "ab"=>["a", "aaa", "bb", "just_a_label2"],
                                       "aa"=>["a"],
                                       "ba"=>["b", "ab"],
                                       "aaa"=>["aa", "just_a_label"],
                                       "bbb"=>["bb", "aaa"],
                                       "bc"=>["b", "bbb", "just_a_label2"],
                                       "bcc"=>["bc"]}}

  end

  it "has jsivt grapher when initialized" do
    @jm.jsgrapher.should_not == nil
    @jm.jsgrapher.should be_a JsivtGrapher
  end

  it "guesses at best tree roots" do
    @jm.digraphs.size.should == 2
    @jm.digraphs_with_roots.keys.should == @best_tree_roots
  end

  it "returns tree graph" do
    @best_tree_roots.each do |root|
      js_graph = JSON.parse(@jm.tree_graph(root))
      puts "Need to develop test for expected result"
    end
  end

  it "can create a new node" do
    new_node = @jm.create_node(@node1_params)
    new_node._user_data.should == @node1_params
  end

  it "can get an existing node" do
    #@jm.create_node(@node1_params)
    new_node = @jm.select_node(@node1_params[:id])
    new_node._user_data.should == @node1_params
  end

 it "can delete a node" do
   new_node = @jm.select_node(@node1_params[:id])
   new_node._user_data.should == @node1_params
   @jm.destroy_node(@node1_params[:id])
   no_node = @jm.select_node(@node1_params[:id])
   no_node.should == nil
   puts "Need test to ensure deleting node deletes attachments"
 end


end
