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

    # Book keeping of any value changed for any sattr
    def sattr_change_set
      @attr_change_set ||= {}
    end

    # Re-sets sattr_change_set
    def reset_sattr_change_set
      self.sattr_change_set.clear
    end

    base.send(:before_validation, :populate_serialized_attributes)
    base.send(:after_save, :reset_sattr_change_set)
  end

  module ClassMethods
    def s_datatypes
      [:integer, :string, :boolean]
    end

    # Stores list of attributes serialized
    def serialized_attribute_list
      @@parent_attribute_list ||= {:serialized_options => []}
    end

    # Gets serialized attribute currenly in use
    def current_serialized_attr
      @@curr_ser_attr ||= serialized_attribute_list.keys.first
    end

    # Generates getter and setter method with field_name (datatype and) default_value (if provided else nil)
    # Example:
    # sattr_accessor :name, :string, "some name"
    # sattr_accessor :roll_no, :integer, 111
    # sattr_accessor :is_admin, :boolean, true
    # sattr_accessor :second_name, "kumar"
    # sattr_accessor :address
    def sattr_accessor(*arg)
      field_name = arg[0]
      if s_datatypes.include?(arg[1])
        datatype = arg[1]
        default_value = arg[2]
      else
        datatype = nil
        default_value = arg[1]
      end


      field_name = field_name.to_sym unless field_name.is_a?(Symbol)

      serialized_attribute_list[current_serialized_attr] ||= []
      serialized_attribute_list[current_serialized_attr] << field_name

      # If attributes are not serialized then here is serialization done
      self.serialize(current_serialized_attr) unless self.serialized_attributes.keys.include?(current_serialized_attr.to_s)

      # Defining method to fetch serialzed parent attribute (gives last found)
      define_method :fetch_parent_attribute do |filed_name|
        parent_attr = nil
        self.class.serialized_attribute_list.each do |attr_key, fields_val|
          parent_attr = attr_key if fields_val.include?(filed_name)
        end
        raise "UnableToFindParentAttribute" if parent_attr.nil?
        parent_attr
      end

      define_method field_name do
        field_value = unserialized_options(fetch_parent_attribute(field_name))[field_name]
        final_value = (field_value.nil? ? default_value : field_value)

        # Updates sattr_change_set if field_name is not already present in it
        send(:sattr_change_set)[field_name.to_s] = final_value unless send(:sattr_change_set).include?(field_name.to_s)
        final_value
      end

      define_method "#{field_name.to_s}=" do |field_value|
        if datatype.nil? # If no datatype then take value as it is
          field_value = field_value
        elsif datatype == :integer # If integer then convert to integer and also accept nil
          field_value = field_value.to_i unless field_value.nil?
        elsif datatype == :string # If string then convert to string and also accept nil
          field_value = field_value.to_s unless field_value.nil?
        elsif datatype == :boolean # If boolean then convert to true or false and also accept nil
          unless field_value.nil?
            if [true, false].include?(field_value)
              field_value = field_value
            elsif (field_value.is_a?(Fixnum) or field_value.is_a?(Bignum)) #Todo: Use a regexp instead
              field_value = ((field_value.to_i <= 0) ? false : true)
            elsif field_value.is_a?(String)
              temp_f = field_value.downcase.strip
              field_value = if temp_f == "false"
                              false
                            elsif temp_f == "true"
                              true
                            elsif temp_f.to_i > 0
                              true
                            else
                              false
                            end
            else
              raise "InvalidValue"
            end
          end
        end

        # Recording sattr value if it is able to respond to ActiveModel::Dirty's changed_attributes
        if send("respond_to?", "changed_attributes")
          send(field_name)
          if send(:sattr_change_set)[field_name.to_s] == field_value
            changed_attributes.delete(field_name.to_s)
          else
            # ActiveRecord:Dirty 4.2+: `changed_attributes` is frozen
            # Dupe & replace to continue functionality support
            # But ... TO-DO: Should replace this gem && `sattr_accessor` BEFORE Rails 5!
            @changed_attributes = changed_attributes.dup
            @changed_attributes[field_name.to_s] = send(:sattr_change_set)[field_name.to_s]
          end
        end

        unserialized_options(fetch_parent_attribute(field_name)).merge!(field_name => field_value)
        field_value
      end
    end

    # Implements column re-naming to something different from: 'serialized_options'
    ###
    # To use a column named "workspaces":
    #
    # for_serialized_field :workspaces do
    #   sattr_accessor(:wfield_one, "Some String One")
    #   sattr_accessor(:wfield_two, {})
    #   sattr_accessor(:wfield_three, [])
    # end
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
