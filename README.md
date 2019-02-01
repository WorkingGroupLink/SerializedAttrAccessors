SerializedAttrAccessors
=======================

# Do NOT use this: Tweaked to get working in Rails 4.2, but Rails5 will REMOVE `sattr_accessor`

This gem extends ActiveRecord to consolidate multiple `sattr_accessor` values to a single RDB column.

...let's be honest though, this is a #reallybadidea. It prevents using SQL `WHERE` to filter data & confuses most (ALL) analysis & ML-from-RDBBMS packages. The ONLY reasons to use this gem are if your host charges per-column (it wastes storage GB, BTW), or you really like the idea of Doc DB's but really want to run MySQL anyway...


Setup: (just don't...)
----------
1. `bundle install "SerializedAttrAccessors"`
1. Add a migration for the targeted model, with a TEXT column named `serialized_options`
1. Use like `attr_accessor` in ActiveRecord models:

>    `sattr_accessor :name, :string, "some name"`
>    `sattr_accessor :roll_no, :integer, 111`
>    `sattr_accessor :is_admin, :boolean, true`
>    `sattr_accessor :second_name, "kumar"`
>    `sattr_accessor :address`


To use a different column name than `serialized_options`:

>        for_serialized_field :workspaces do
>            sattr_accessor :name, :string, "some name"
>            sattr_accessor :roll_no, :integer, 111
>            sattr_accessor :is_admin, :boolean, true
>            sattr_accessor :second_name, "kumar"
>            sattr_accessor :address
>        end
