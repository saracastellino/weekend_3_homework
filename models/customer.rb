require_relative("../db/sql_runner")


class Customer

  attr_reader :id
  attr_accessor :name, :funds

  def initialize( customers )
    @id = customers['id'].to_i if customers['id']
    @name = customers['name']
    @funds = customers['funds']
  end

  def save
    sql = "INSERT INTO customers (name, funds) VALUES ($1, $2) RETURNING id"
    values = [@name, @funds]
    customer = SqlRunner.run(sql, values).first
    @id = customer['id'].to_i
  end

  def self.all
    sql = "SELECT * FROM customers"
    customers = SqlRunner.run(sql)
    customers.map {|customer| Customer.new(customer)}
  end

  def update
    sql = "UPDATE customers SET (name, funds) = ($1, $2) WHERE id = $3"
    values = [@name, @funds, @id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all
    sql = "DELETE FROM customers"
    SqlRunner.run(sql)
  end

  def films
    sql = "SELECT films.* FROM films INNER JOIN tickets ON films.id = tickets.film_id WHERE customer_id = $1"
    value = [@id]
    films = SqlRunner.run(sql, value)
    return films.map {|film| Film.new(film)}
  end

  def number_of_films
    sql = "SELECT films.* FROM films INNER JOIN tickets ON films.id = tickets.film_id WHERE customer_id = $1"
    value = [@id]
    films = SqlRunner.run(sql, value)
    films_per_customer = films.map {|film| Film.new(film)}
    return films_per_customer.length
  end

  def tickets
    sql = "SELECT * FROM tickets WHERE customer_id = $1"
    values = [@id]
    tickets_info = SqlRunner.run(sql, values)
    tickets_info.map {|ticket| Ticket.new(ticket)}
  end

  def funds_left
    films = self.films
    film_price = films.map{|film| film.price.to_i}
    total_price = film_price.sum
    return @funds -= total_price
  end

  # movie_found = Casting.get_movie_by_id(@movie_id)
  #   # binding.pry
  #   if(movie_found.budget >= @fee)
  #     movie_found.budget -= @fee
  #   else
  #     p "Sorry, out of budget"
  #   end
  #   movie1.update
  #
  #
  #
  #   def remaining_budget()
  #     castings = self.castings()
  #     casting_fees = castings.map{|casting| casting.fee}
  #     combined_fees = casting_fees.sum
  #     return @budget - combined_fees
  #   end
end
