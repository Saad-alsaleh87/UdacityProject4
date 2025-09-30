import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_MOVIE_API_URL || 'http://localhost:3000';

function App() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchMovies();
  }, []);

  const fetchMovies = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/movies`);
      setMovies(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch movies');
      console.error('Error fetching movies:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Movie Collection</h1>
        <p>API URL: {API_URL}</p>
      </header>
      
      <main className="App-main">
        {loading && <p>Loading movies...</p>}
        {error && <p className="error">Error: {error}</p>}
        
        {!loading && !error && (
          <div className="movies-container">
            <h2>Movies ({movies.length})</h2>
            <div className="movies-grid">
              {movies.map(movie => (
                <div key={movie.id} className="movie-card">
                  <h3>{movie.title}</h3>
                  <p><strong>Year:</strong> {movie.year}</p>
                  <p><strong>Director:</strong> {movie.director}</p>
                  <p><strong>Genre:</strong> {movie.genre}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
