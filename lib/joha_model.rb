require 'couchrest'
require 'tinkit'
require 'burp'
require 'kinkit'
require 'jsivt_grapher'

class JohaModel
  VERSION = "0.0.1"
  CouchDB_BaseUrl = "http://127.0.0.1:5984/"
  CouchDB_Prefix = "joha_model_"
  #CouchDB = CouchRest.database!("http://127.0.0.1:5984/joha_test_data/")
  
  #data operations are defined in tinkit/node_element/operations
  #ToDo: Reconcile the App data definitions with the Model data definitions
  #For example, :links => :link_data for the app, but :key_list_ops for model
  #also app supports nested and arbitrarily complex data types, but not the model
  JohaModelDataDefn = {:id => :static_ops,
                  :label => :replace_ops,
                  :description => :replace_ops,
                  :links => :key_list_ops,
                  :parents => :list_ops,
                  :notes => :list_ops,
                  :history => :list_ops,
                  :user_data => :key_list_ops}   

  attr_reader :tinkit_class, :jsgrapher, :digraphs, :joha_data, :node_list, :orphans
  attr_accessor :current_digraph, :model_name

  #ToDo: BaseClass that can support old Bufs Model and new Joha Model
  #Bufs Model should be backwards compatible
  #Joha Model should be able to be drop and replace
  #Though won't work with Bufs formatted persistent storage
  
  #Security ToDo: Have to ensure that the user is authenticated.
  #Current thought. Have security module that has an authentication function
  #and authorization function, with components calling back to it at critical
  #points. One critical point is this one where the user is bound to their datastore
  def initialize(model_name, tinkit_class_name, user_datastore_id, tinkit_id)
    #ToDo: validate user_datastore_id is proper format for datastores (no illegal characters)
    #Data Store is on a per user basis, with each user able to have multiple tinkit classes
    #within their store
    #CouchDB Data Store
    @model_name = model_name
    datastore_id = CouchDB_Prefix + user_datastore_id
    @user_db = CouchRest.database!(CouchDB_BaseUrl + datastore_id)
    @key_field = :id
    @parents_field = :parents
    @attachments_field = :attachments
    @user_data_field = :user_data
    #TODO, need to fix formatter to accept custom field ops
    joha_env = TinkitNodeFactory.env_formatter("couchrest",
                                               tinkit_class_name,
                                               tinkit_id,
                                               @user_db.uri,
                                               @user_db.host)

    #hack until formatter is fixed
    joha_env[:data_model][:field_op_set] = JohaModelDataDefn

    @tinkit_class = TinkitNodeFactory.make(joha_env)
    
    #TODO Figure out approach to deal with subsets of records
    #to handle huge data repositories
    all_joha_tinkits = @tinkit_class.all

    #I've given up on native tinkit class into burp for now
    all_joha_node_data = all_joha_tinkits.map{|node| node._user_data}
  
    #transforms an array of hashes to a hash with key field
    #pointing to hashed data of node
    burped_tinkits = Burp.new(all_joha_node_data, @key_field)

    #finds relationships between nodes
    tinkit_kins = Kinkit.new(burped_tinkits, @parents_field)

    @node_list = tinkit_kins

    @digraphs = tinkit_kins.uniq_digraphs
    @orphans = tinkit_kins.orphans
    
    @current_digraph = nil
    #parent child relationship data  #adds field :children
    joha_relationships = tinkit_kins.parent_child_maps
    @joha_data = joha_relationships

    joha_relationship_structure = {:id => @key_field, 
                                  :name_key => :label,
                                  :children =>:children }

     #p full_data.methods

    @jsgrapher = JsivtGrapher.new(joha_relationships, joha_relationship_structure)
  end

  def find_digraph_with_node(node_id)
    #nodes must unique across all digraphs in a domain
    ret_digraph = nil
    @digraphs.each do |digraph|
      if digraph.vertices.include? node_id
        ret_digraph = digraph
        break
      end
    end
    ret_digraph
  end

  def set_current_digraph(node_id)
     @current_digraph = find_digraph_with_node(node_id)
  end

  def find_all_descendant_data(node_id, field)
    field = field.to_sym
    refresh
    graph = @current_digraph || find_digraph_with_node(node_id)
    raise "No graph found for node id: #{node_id.inspect}" unless graph
    desc_graph = graph.bfs_search_tree_from(node_id)
    #p desc_graph
    desc_data = {}
    desc_graph.vertices.each do |sub_node_id|
      sub_node = @joha_data[sub_node_id]
      desc_data[sub_node_id] = sub_node[field]
    end
    return {field => desc_data}
  end
  
  def tree_graph(top_node, depth=4)
    #check if node exists?
    @jsgrapher.to_tree(top_node, depth)
  end
  
    #TODO: DRY up init now that refresh exists
  def refresh
     all_joha_tinkits = @tinkit_class.all

    #I've given up on native tinkit class into burp for now
    all_joha_node_data = all_joha_tinkits.map{|node| node._user_data}

    #transforms an array of hashes to a hash with key field
    #pointing to hashed data of node
    burped_tinkits = Burp.new(all_joha_node_data, @key_field)

    #finds relationships between nodes
    tinkit_kins = Kinkit.new(burped_tinkits, @parents_field)

    @node_list = tinkit_kins
    @orphans = tinkit_kins.orphans
    
    @digraphs = tinkit_kins.uniq_digraphs
    @current_digraph = nil
    #parent child relationship data  #adds field :children
    joha_relationships = tinkit_kins.parent_child_maps
    @joha_data = joha_relationships

    joha_relationship_structure = {:id => @key_field,
                                  :name_key => :label,
                                  :children =>:children }

     #p full_data.methods

    @jsgrapher = JsivtGrapher.new(joha_relationships, joha_relationship_structure)
  end

  
  #TODO Move to forforf_rgl_adjacency
  #list unique graphs with a guess
  #as to the best top node as an id
  #each node is unique so any node
  #will uniquely identify a given graph
  #The model uses this to let the user choose
  #which graph to browse, and since each node
  #is unique, the graph can be selected using that
  #top node.
  def digraphs_with_roots
    graphs_with_roots = {}
    #sort_graphs = @graphs.sort {|a,b| a.size <=> b.size }
    @digraphs.each do |graph|
      best_top_nodes = graph.best_top_vertices
      best_top_node = best_top_nodes.min{ |n1,n2| graph.in_degree(n1) <=> graph.in_degree(n2) }
      graphs_with_roots[best_top_node] = graph
    end
    #@orphans.each do |ok, od|
    #  graphs_with_roots[ok] = [{ok => od}]
    #end
    return graphs_with_roots
  end

  #Former borg.ify
  #based on node, find all sub nodes (rgl.vertices)
  #based on field return all equal sub node fields
  #{node_id => {field_name => field_data}}
  def descendant_data(top_node_id, field_name)
    
  end

  #Method maps (TODO: I'm sure there's a better way)
  def create_node(params)
    node = @tinkit_class.new(params)
    node.__save
    node
    #TODO: What if params includes attachments?
  end

  #this is a bit dangerous as it can screw up the expected data structure
  #if the params passed in don't conform to the original data structure
  def update_node(params)
    node = @tinkit_class.get(params[@key_field])
    raise "No node to update for #{@key_field} => #{params[@key_field]}."\
          "Maybe you wanted to create a new node instead?" unless node
    #TODO: What if params includes attachments?
    
    joha_fields = JohaDataModelDefn.keys
    param_keys = params.keys
    param_keys.delete(@key_field)
    param_keys.each do |key|
      next unless joha_fields.include? key
      new_data = params[key]
      node._user_data[key] = new_data
      param_keys.delete(key)
    end
    

    if param_keys.size > 0
      node_user_data[@user_data_field] ||= {}
      param_keys.each do |key|
        node._user_data[@user_data_field][key] = params[key]
      end
    end   
  end

  def select_node(id)
    @tinkit_class.get(id)
  end

  def destroy_node(id)
    node = @tinkit_class.get(id)
    node.__destroy_node if node
  end

  def download_attachment(node_id, att_name)
    node = @tinkit_class.get(node_id)
    node.get_raw_data(att_name)
  end

  #private
  def list_attachments(id)
    node = @tinkit_class.get(id)
    node.attached_files
  end

  def list(id, param)
    if param == :attachments
      list_attachments(id)
    else
      node = @tinkit_class.get(id)
      data = node.__send__(:param)
      data.respond_to?(:each) ? data : [data]
    end
  end

  #The data definition defines what 
  #'subtract' means in the conext of that data item
  #item_ids can be singular or plural
  #But if data item is singular, use singular
  # param_data_item = ['a', 'b', 'c']
  # param_data_item_subtract('a') = ['b', 'c']
  # param_data_item_subtract(['a']) = ['b', 'c']
  # param_data_item_subtract(['a', 'b', 'c']) = nil
  # param_data_item = :foo
  # param_data_item_subtract(:foo) = nil
  # param_data_item_subtract([:foo]) = :foo
  def remove_item(id, param, item_ids)
    remove_command = "#{param}_subtract".to_sym
    node = @tinkit_class.get(id)
    node.__send__(remove_command, item_ids)
  end    
 
  #similar to remove above, TODO: Extensive testing needed
  #to ensure all parameter items behave as expected
  def add_item(id, param, item_ids)
    add_command = "#{param}_add".to_sym
    node = @tinkit_class.get(id)
    node.__send__(add_command, item_ids)
  end
  
  def replace_item(id, param, old_item_ids, new_item_ids)
    remove_item(id, param, old_item_ids)
    add_item(id, param, new_item_ids)
  end

end
