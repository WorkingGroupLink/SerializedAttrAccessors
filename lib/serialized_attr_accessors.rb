module SerializedAttrAccessors
  def self.included(base)
    base.extend(ClassMethods)

    def unserialized_options(serialized_attr)
      @so_hash ||= {}
      (@so_hash[serialized_attr] ||= (self.send(serialized_attr) || {}))
    end

    def populate_serialized_attributes
      self.class.serialized_attribute_list.each do |parent_attr_key, value|
        self.send("#{parent_attr_key.to_s}=", @so_hash[parent_attr_key]) if @so_hash and @so_hash[parent_attr_key]
      end
    end

    base.send(:before_validation, :populate_serialized_attributes)
  end

  module ClassMethods
    #Stores list of attributes serialized
    def serialized_attribute_list
      @@parent_attribute_list ||= {:serialized_options => []}
    end

    #Gets serialized attribute currenly in use
    def current_serialized_attr
      @@curr_ser_attr ||= serialized_attribute_list.keys.first
    end

    #Generates getter and setter method with field_name and default_value (if provided else nil)
    #Example:
    # sattr_accessor :second_name, "kumar"
    # sattr_accessor :address
    def sattr_accessor(field_name, default_value = nil)
      field_name = field_name.to_sym unless field_name.is_a?(Symbol)

      serialized_attribute_list[current_serialized_attr] ||= []
      serialized_attribute_list[current_serialized_attr] << field_name

      #If attributes are not serialized then here is serialization done
      self.serialize(current_serialized_attr) unless self.serialized_attributes.keys.include?(current_serialized_attr.to_s)

      #Defining method to fetch serialzed parent attribute (gives last found)
      define_method :fetch_parent_attribute do |filed_name|
        parent_attr = nil
        self.class.serialized_attribute_list.each do |attr_key, fields_val|
          parent_attr = attr_key if fields_val.include?(filed_name)
        end
        raise "UnableToFindParentAttribute" if parent_attr.nil?
        parent_attr
      end

      define_method field_name do
        (unserialized_options(fetch_parent_attribute(field_name))[field_name] || default_value)
      end

      define_method "#{field_name.to_s}=" do |field_value|
        unserialized_options(fetch_parent_attribute(field_name)).merge!(field_name => field_value)
        field_value
      end
    end

    #for_serialized_field :workspaces do
    #  sattr_accessor(:wfield_one, "Some String One")
    #  sattr_accessor(:wfield_two, {})
    #  sattr_accessor(:wfield_three, [])
    #end
    def for_serialized_field(fieldname)
      if block_given?
        @@curr_ser_attr = fieldname
        yield
        @@curr_ser_attr = serialized_attribute_list.keys.first
      else
        raise "ExpectedBlockWithAttributes"
      end
    end

  end

end

ActiveRecord::Base.send(:include, SerializedAttrAccessors)