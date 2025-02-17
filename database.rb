require 'sqlite3'
require 'json'

module BookDatabase
  DB_FILE = "books.db"

  # Initialize database and create books table if it doesn't exist.
  def self.init
    @db = SQLite3::Database.new(DB_FILE)
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS books (
        id INTEGER PRIMARY KEY,
        isbn TEXT,
        title TEXT,
        authors TEXT,
        publisher TEXT,
        published_date TEXT,
        description TEXT,
        industry_identifiers TEXT,
        page_count INTEGER,
        categories TEXT,
        average_rating REAL,
        ratings_count INTEGER,
        maturity_rating TEXT,
        language TEXT,
        preview_link TEXT,
        info_link TEXT,
        image_links TEXT,
        sale_info TEXT,
        access_info TEXT,
        search_info TEXT
      );
    SQL
  end

  def self.db
    @db
  end

  # Insert new book record into database.
  def self.insert_book(data)
    db.execute(
      "INSERT INTO books (isbn, title, authors, publisher, published_date, description, industry_identifiers, page_count, categories, average_rating, ratings_count, maturity_rating, language, preview_link, info_link, image_links, sale_info, access_info, search_info) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [ data[:isbn], data[:title], data[:authors], data[:publisher], data[:published_date], data[:description],
        data[:industry_identifiers], data[:page_count], data[:categories], data[:average_rating],
        data[:ratings_count], data[:maturity_rating], data[:language], data[:preview_link], data[:info_link],
        data[:image_links], data[:sale_info], data[:access_info], data[:search_info] ]
    )
  end

  # Return all books to appear in listbox
  def self.all_books
    db.execute("SELECT id, isbn, title, authors FROM books")
  end

  # Delete a book by id.
  def self.delete_book(id)
    db.execute("DELETE FROM books WHERE id = ?", [id])
  end

  # Update a given TkListbox with the current list of books.
  def self.update_listbox(listbox)
    listbox.clear
    books = all_books
    if books.empty?
      listbox.insert('end', "No books in the database.")
    else
      books.each do |row|
        id, isbn, title, authors = row
        listbox.insert('end', "ID: #{id} | #{isbn} | #{title} | #{authors}")
      end
    end
  end
end
