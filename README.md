SerializedAttrAccessors
=======================
A gem to provide attributes(accessors) from a serialized column of ActiveRecord::Base

How to use
----------
* 1. Include it in gem file.
* 2. Add a text column named "serialized_options".
* 3. In active_record based model add attributes.
    
>    `sattr_accessor :name, :string, "some name"`

>    `sattr_accessor :roll_no, :integer, 111`

>    `sattr_accessor :is_admin, :boolean, true`

>    `sattr_accessor :second_name, "kumar"`

>    `sattr_accessor :address`

* 4. In case want to use other attribute instead of "serialized_options", use it like this.

>        for_serialized_field :workspaces do
>            sattr_accessor :name, :string, "some name"
>            sattr_accessor :roll_no, :integer, 111
>            sattr_accessor :is_admin, :boolean, true
>            sattr_accessor :second_name, "kumar"
>            sattr_accessor :address
>        end

* 5. Enjoy!

