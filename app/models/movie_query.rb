class MovieQuery < ActiveRecord::Base

  belongs_to :movie

  def self.search(movie_title)
    movie_title = movie_title || ''
    movie_title.gsub!(' ', '%20')
    movie_title.downcase!

    unless query = self.find_by(term: movie_title)
      query = self.create({term: movie_title})

      url = "http://www.omdbapi.com/?t=#{movie_title}&r=json"
      movie = HTTParty.get(url)

      if movie['Response'] == "False"
        query.success = false
        query.save!
      else
        query.success = true
        movie = Movie.create({
          title: movie["Title"],
          genre: movie["Genre"],
          director: movie["Director"],
          released: movie["Released"],
          plot:movie["Plot"],
          runtime: movie["Runtime"],
          imdb_id: movie["imdbID"],
        })
        query.movie_id = movie.id
        query.save!
      end
    end

    return query
  end

end
