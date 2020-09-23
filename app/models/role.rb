class Role < ApplicationRecord
#  has_many :roles_users
#  has_many :users, :through => :roles_users
# roles :: Admin, User, Reviewer, Author - must be added to database manually
#   SCHEMA
#     t.string "role", default: "user", null: false
#     t.datetime "created_at", precision: 6, null: false
#     t.datetime "updated_at", precision: 6, null: false
  has_and_belongs_to_many :users
end
