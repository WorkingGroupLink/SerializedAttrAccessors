Gem::Specification.new do |s|
  s.name = "serialized_attr_accessors"
  s.version = "1.0.3"
  s.date = '2021-03-04'
  s.summary = "DEPRECATED: SerializedAttrAccessors generates multiple attr_accessors in a Rails mode. Consolidates them to a single, serialized column per-model"
  s.description = "Deprecated: Attribute accessor generator using 'sattr_accessor' to add 'pseudo-columns' to a model. Consolidates multiple attributes to a single columner per-model. Default storage column is :serialized_options, or a different serialized field using `for_serialized_field` with ablock."
  s.authors = ["Praveen Kumar Sinha", "Mike Bijon NRS", "Michal Kracik NRS"]
  s.email = ["praveen.kumar.sinha@gmail.com", "mbijon@netroadshow.com"]
  s.files = ["lib/serialized_attr_accessors.rb"]
  s.homepage = "https://github.com/WorkingGroupLink/SerializedAttrAccessors/"
end
