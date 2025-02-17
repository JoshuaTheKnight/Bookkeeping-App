# google_books.rb
require 'open-uri'
require 'json'
require 'uri'

module GoogleBooks
  # Lookup the book info from the Google Books API using the given ISBN.
  def self.lookup_isbn(isbn)
    isbn.strip!
    query = URI.encode_www_form_component("isbn:#{isbn}")
    url = "https://www.googleapis.com/books/v1/volumes?q=#{query}"
    response = URI.open(url).read
    JSON.parse(response)
  end

  # Extract the entire volume data (all API data) from the result.
  def self.extract_book_data(result)
    if result['totalItems'] > 0 && result['items'] && !result['items'].empty?
      result['items'].first
    else
      nil
    end
  end
end
