require_relative 'google_books'

module AutomaticEntry
  # Look up a book by ISBN using Google Books API and extract data hash for insertion.
  # Returns a hash with the book details or nil if no data was found.
  def self.lookup_and_extract(isbn)
    # Use the methods in the GoogleBooks module to fetch data.
    result = GoogleBooks.lookup_isbn(isbn)
    book_data = GoogleBooks.extract_book_data(result)
    return nil if book_data.nil?
    
    volume_info = book_data['volumeInfo'] || {}

    # Determine a primary ISBN from Google API's Industry Identifiers.
    isbn_extracted = nil
    if volume_info['industryIdentifiers']
      volume_info['industryIdentifiers'].each do |identifier|
        if identifier["type"] == "ISBN_13"
          isbn_extracted = identifier["identifier"]
          break
        elsif identifier["type"] == "ISBN_10" && isbn_extracted.nil?
          isbn_extracted = identifier["identifier"]
        end
      end
    end
    #ChatGPT helped me learn this shorthand notation
    isbn_extracted ||= "Unknown"

    # Build a data hash to be inserted into database.
    {
      isbn: isbn_extracted,
      title: volume_info['title'] || "Unknown Title",
      authors: volume_info['authors'] ? volume_info['authors'].join(", ") : "Unknown Authors",
      publisher: volume_info['publisher'] || "Unknown Publisher",
      published_date: volume_info['publishedDate'] || "Unknown Date",
      description: volume_info['description'] || "No description available",
      industry_identifiers: volume_info['industryIdentifiers'] ? volume_info['industryIdentifiers'].to_json : nil,
      page_count: volume_info['pageCount'] || 0,
      categories: volume_info['categories'] ? volume_info['categories'].join(", ") : "Unknown Categories",
      average_rating: volume_info['averageRating'] || nil,
      ratings_count: volume_info['ratingsCount'] || 0,
      maturity_rating: volume_info['maturityRating'] || "Not Specified",
      language: volume_info['language'] || "Unknown",
      preview_link: volume_info['previewLink'] || "",
      info_link: volume_info['infoLink'] || "",
      image_links: volume_info['imageLinks'] ? volume_info['imageLinks'].to_json : nil,
      sale_info: book_data['saleInfo'] ? book_data['saleInfo'].to_json : nil,
      access_info: book_data['accessInfo'] ? book_data['accessInfo'].to_json : nil,
      search_info: book_data['searchInfo'] ? book_data['searchInfo'].to_json : nil
    }
  end
end