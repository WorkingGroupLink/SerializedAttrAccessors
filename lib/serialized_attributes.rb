module SerializedAttributes
  def self.included(base)
    base.extend(ClassMethods)

    def unserialized_options
      @so_hash ||= (self.send(self.class.send(:get_serialized_attr)) || {})
    end

    def populate_serialized_options
      self.send("#{self.class.send(:get_serialized_attr)}=", @so_hash) if @so_hash
    end

    base.send(:before_validation, :populate_serialized_options)
  end

  module ClassMethods
    #Sets serialized attribute, Default serialized attribute name is "serialized_options" until and unless set manually
    def set_serialized_attribute(attribute_name)
      @ser_attr = attribute_name
    end

    def get_serialized_attr
      @ser_attr ||= "serialized_options"
    end

    #Generates getter and setter method with field_name and default_value (if provided else nil)
    #Example:
    # sattr_accessor :second_name, "kumar"
    # sattr_accessor :address
    def sattr_accessor(filed_name, default_value = nil)

      define_method filed_name do
        (unserialized_options[filed_name.to_sym] || default_value)
      end

      define_method "#{filed_name}=" do |field_value|
        unserialized_options.merge!(filed_name.to_sym => field_value)
        field_value
      end
    end

  end

end

ActiveRecord::Base.send(:include, SerializedAttributes)
