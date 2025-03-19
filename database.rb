require 'sqlite3'
require 'json'

module BookDatabase
  DB_FILE = "books.db"

  def self.init
    @db = SQLite3::Database.new(DB_FILE)
    # Create the main books table if it doesn't exist.
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

    # Create a table for books currently being read.
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS current_books (
        id INTEGER PRIMARY KEY,
        book_id INTEGER,
        start_date TEXT,
        progress INTEGER DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
      );
    SQL

    # Create a table for completed books.
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS completed_books (
        id INTEGER PRIMARY KEY,
        book_id INTEGER,
        date_completed TEXT,
        review_score INTEGER,
        FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
      );
    SQL
  end

  def self.db
    @db
  end

  # Existing methods for the books table
  def self.insert_book(data)
    db.execute(
      "INSERT INTO books (isbn, title, authors, publisher, published_date, description, industry_identifiers, page_count, categories, average_rating, ratings_count, maturity_rating, language, preview_link, info_link, image_links, sale_info, access_info, search_info) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        data[:isbn],
        data[:title],
        data[:authors],
        data[:publisher],
        data[:published_date],
        data[:description],
        data[:industry_identifiers],
        data[:page_count],
        data[:categories],
        data[:average_rating],
        data[:ratings_count],
        data[:maturity_rating],
        data[:language],
        data[:preview_link],
        data[:info_link],
        data[:image_links],
        data[:sale_info],
        data[:access_info],
        data[:search_info]
      ]
    )
  end

  def self.all_books
    db.execute("SELECT id, isbn, title, authors FROM books")
  end

  def self.delete_book(id)
    db.execute("DELETE FROM books WHERE id = ?", [id])
  end

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

  # Methods for the current_books table
  def self.add_current_book(book_id, start_date, progress = 0)
    db.execute("INSERT INTO current_books (book_id, start_date, progress) VALUES (?, ?, ?)", [book_id, start_date, progress])
  end

  def self.current_books
    db.execute("SELECT cb.id, b.title, b.authors, cb.start_date, cb.progress, b.page_count
                FROM current_books cb
                JOIN books b ON cb.book_id = b.id")
  end

  def self.current_books_details
    db.execute("SELECT cb.id, b.id as book_id, b.title, b.authors, cb.start_date, cb.progress, b.page_count
                FROM current_books cb
                JOIN books b ON cb.book_id = b.id")
  end
  
  def self.update_current_book_listbox(listbox)
    listbox.clear
    books = current_books_details
    if books.empty?
      listbox.insert('end', "No books currently being read.")
    else
      books.each do |row|
        # row format: [current_books.id, book_id, title, authors, start_date, progress, page_count]
        current_book_id, book_id, title, authors, start_date, progress, page_count = row
        listbox.insert('end', "ID: #{current_book_id} | Book ID: #{book_id} | Title: #{title} | Authors: #{authors} | Start Date: #{start_date} | Progress: #{progress}/#{page_count}")
      end
    end
  end

  def self.add_completed_book(book_id, date_completed, review_score)
    db.execute("INSERT INTO completed_books (book_id, date_completed, review_score) VALUES (?, ?, ?)", [book_id, date_completed, review_score])
  end

  def self.completed_books
    db.execute("SELECT cb.id, b.title, b.authors, cb.date_completed, cb.review_score
                FROM completed_books cb
                JOIN books b ON cb.book_id = b.id")
  end

  def self.mark_current_book_complete(current_book_id)
    db.execute("DELETE FROM current_books WHERE id = ?", [current_book_id])
  end

  def self.update_completed_listbox(listbox)
    listbox.clear
    books = completed_books
    if books.empty?
      listbox.insert('end', "No completed books.")
    else
      books.each do |row|
        id, title, authors, date_completed, review_score = row
        listbox.insert('end', "ID: #{id} | Title: #{title} | Authors: #{authors} | Completed: #{date_completed} | Review Score: #{review_score}/10")
      end
    end
  end

  def self.completed_books_stats
    db.get_first_row(<<-SQL)
      SELECT COUNT(*) AS total_books,
             COALESCE(SUM(b.page_count), 0) AS total_pages,
             COALESCE(AVG(b.page_count), 0) AS average_pages,
             COALESCE(AVG(cb.review_score), 0) AS average_review
      FROM completed_books cb
      JOIN books b ON cb.book_id = b.id
    SQL
  end
  
end
