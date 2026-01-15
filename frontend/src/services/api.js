const API_KEY = '2349aad820a3651ef45a5996c67b2616'
const BASE_URL_MOVIES = 'https://api.themoviedb.org/3'
const BASE_URL_VIS_NOVELS = 'https://api.vndb.org/kana/vn'

const withPoster = (item) => ({
  ...item,
  poster: item.poster_path
    ? `https://image.tmdb.org/t/p/w500${item.poster_path}`
    : null,
});

const ProcessVnResults = (vnResults) => {
  return vnResults.map((item) => ({
    id: `vn_${item.id}`,
    title: item.title,
    poster: item.image?.url,
    release_date: item.released,
  }));
};

export const getPopularContent = async () => {
  const response = await fetch(`${BASE_URL_MOVIES}/movie/popular?api_key=${API_KEY}`);
  const data = await response.json();

  const results = data.results.map(withPoster);

  return results;
};

export const searchContent = async (query) => {
    const response = await fetch(
        `${BASE_URL_MOVIES}/search/movie?api_key=${API_KEY}&query=${encodeURIComponent(query)}&include_adult=true&primary_release_year=2011`
    );
    const data = await response.json();
    const results1 = data.results.map(withPoster);
    console.log('Search results1:', results1); // Debugging line

    
    const vnpayload = {
        "fields": "title, image.url, released, description",
        "filters": ["search", "=", query]
    };
    const vnResponse = await fetch(BASE_URL_VIS_NOVELS, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(vnpayload)
    });
    const vnData = await vnResponse.json();
    console.log('VN API response:', vnData); // Debugging line
    const results2 = ProcessVnResults(vnData?.results);
    console.log('Search results2:', results2); // Debugging line

    
    const results = [...results1, ...results2];
    console.log('Combined results:', results); // Debugging line

  
  return results;
};
