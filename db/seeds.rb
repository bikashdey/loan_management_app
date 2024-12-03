# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb

AdminUser.create(
  email: 'admin@example.com',
  password: 'password123',  # Devise will handle the encryption of this password
  password_confirmation: 'password123',  # Make sure both match
  role: 1,  # Assuming 1 is for admin, adjust based on your enum if necessary
  wallet: 0.0  # Set initial wallet value
) if Rails.env.development? && AdminUser.find_by(email: "admin@example.com").present?

User.create(
  email: "user@example.com", 
  password: "password", 
  role: "user", 
  wallet: 10_000
) unless User.find_by(email: "bka@gmail.com").present?
