require 'tk'
require_relative 'database'

module Visualizations

  # Draws a histogram for review scores from the completed_books table.
  def self.show_review_score_histogram(root)
    #Grabs data from database and stores it in float format
    scores = BookDatabase.db.execute("SELECT review_score FROM completed_books").map { |row| row.first.to_f }
    
    histogram = Hash.new(0)
    scores.each do |score|
      bin = score.round
      histogram[bin] += 1
    end
    #This ensures that there is a key for every hash from 1 to 10.
    #This is because before, my visualization would not display anything that wasn't populated by data
    #This caused there to only be a range from 8-10 on my graph.
    (0..10).each { |i| histogram[i] = 0 unless histogram.key?(i) }
    max_freq = histogram.values.max
    max_freq = 1 if max_freq == 0

    win = TkToplevel.new(root) do
      title "Review Score Histogram"
      minsize(400, 300)
    end

    canvas = TkCanvas.new(win) do
      width 400
      height 300
      background "white"
      pack('padx' => 10, 'pady' => 10)
    end

    bin_count = 11
    bar_width = (400 - 20).to_f / bin_count

    histogram.sort.each_with_index do |(score, freq), i|
      x0 = 10 + i * bar_width
      x1 = x0 + bar_width - 4
      #This determines bar height. Fixed issue where all my bars were the same height
      bar_height = (freq.to_f / max_freq) * (300 - 40)
      y1 = 300 - 20
      y0 = y1 - bar_height
      canvas.create('rectangle', x0, y0, x1, y1, '-fill', 'blue')
      canvas.create('text', (x0 + x1)/2, y1 + 10, '-text', score.to_s)
      canvas.create('text', (x0 + x1)/2, y0 - 10, '-text', freq.to_s)
    end
  end

  def self.show_page_range_pie_chart(root)
    bins = {
      "Under 100" => 0,
      "100-199" => 0,
      "200-299" => 0,
      "300-399" => 0,
      "400+"    => 0
    }
    results = BookDatabase.db.execute("SELECT b.page_count FROM completed_books cb JOIN books b ON cb.book_id = b.id")
    results.each do |row|
      pages = row.first.to_i
      if pages < 100
        bins["Under 100"] += 1
      elsif pages < 200
        bins["100-199"] += 1
      elsif pages < 300
        bins["200-299"] += 1
      elsif pages < 400
        bins["300-399"] += 1
      else
        bins["400+"] += 1
      end
    end
    total = bins.values.sum
    win = TkToplevel.new(root) do
      title "Page Range Pie Chart"
      minsize(400, 400)
    end

    canvas = TkCanvas.new(win) do
      width 400
      height 400
      background "white"
      pack('padx' => 10, 'pady' => 10)
    end

    start_angle = 0.0
    colors = ["red", "green", "blue", "orange", "purple"]
    center_x = 200
    center_y = 200
    radius = 150

    bins.each_with_index do |(range, count), i|
      #Calculates what fraction of the circle an element should take
      #ABSOLUTELY RIDICULOUS THAT I HAVE TO DO THIS. I COULD DO THIS WHOLE THING WITH LIKE 1 PYTHON LINE
      angle = total > 0 ? (count.to_f / total) * 360 : 0
      #Draw the circle
      canvas.create('arc',
                    center_x - radius, center_y - radius,
                    center_x + radius, center_y + radius,
                    '-start', start_angle,
                    '-extent', angle,
                    '-fill', colors[i % colors.size],
                    '-style', 'pieslice')
      mid_angle = start_angle + angle/2.0
      #Label the slice (pain)
      label_x = center_x + (radius/2) * Math.cos(mid_angle * Math::PI/180)
      label_y = center_y - (radius/2) * Math.sin(mid_angle * Math::PI/180)
      canvas.create('text', label_x, label_y, '-text', "#{range}: #{count}")
      start_angle += angle
    end
  end

  def self.show_books_per_month_bar_chart(root)
    results = BookDatabase.db.execute("SELECT date_completed FROM completed_books")
    counts = Hash.new(0)
    results.each do |row|
      date_completed = row.first.to_s.strip  # Remove any leading/trailing whitespace
      if !date_completed.empty? && date_completed =~ /^(\d{4}-\d{2})-/
        month = $1
        counts[month] += 1
      end
    end
  
    sorted_months = counts.keys.sort
    max_books = counts.values.max || 1
  
    win = TkToplevel.new(root) do
      title "Books Completed Per Month"
      minsize(500, 300)
    end
  
    canvas = TkCanvas.new(win) do
      width 500
      height 300
      background "white"
      pack('padx' => 10, 'pady' => 10)
    end
  
    bar_width = (500 - 40).to_f / sorted_months.size
    sorted_months.each_with_index do |month, i|
      count = counts[month]
      x0 = 20 + i * bar_width
      x1 = x0 + bar_width - 4
      bar_height = (count.to_f / max_books) * (300 - 40)
      y1 = 300 - 20
      y0 = y1 - bar_height
  
      canvas.create('rectangle', x0, y0, x1, y1, '-fill', 'teal')
      canvas.create('text', (x0 + x1)/2, y1 + 10, '-text', month)
      canvas.create('text', (x0 + x1)/2, y0 - 10, '-text', count.to_s)
    end
  end
  
  # Show all visualizations via a simple button panel.
  def self.show_all_visualizations(root)
    win = TkToplevel.new(root) do
      title "Visualizations"
      minsize(500, 400)
    end

    frame = TkFrame.new(win) do
      pack('padx' => 10, 'pady' => 10, 'fill' => 'x')
    end

    TkButton.new(frame) do
      text "Review Score Histogram"
      command proc { Visualizations.show_review_score_histogram(root) }
      pack('side' => 'left', 'padx' => 5)
    end

    TkButton.new(frame) do
      text "Page Range Pie Chart"
      command proc { Visualizations.show_page_range_pie_chart(root) }
      pack('side' => 'left', 'padx' => 5)
    end

    TkButton.new(frame) do
      text "Books Per Month"
      command proc { Visualizations.show_books_per_month_bar_chart(root) }
      pack('side' => 'left', 'padx' => 5)
    end
  end
end